//
//  SearchEngine.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/12/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import Foundation

enum RequestResult<Value> {
    case success(Value)
    case failure(Error)
}

protocol SearchEngine {
    func search(for query: String, completion: ((RequestResult<[Event]>) -> Void)?)
    func cancelSearch()
}

class SearchEngineImp {
    private var requestTask: URLSessionDataTask?
    private var debounceTimer: Timer?
    
    private func getSearchResults(for query: String, completion: ((RequestResult<[Event]>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = API.protocol.rawValue
        urlComponents.host = API.host.rawValue
        urlComponents.path = API.eventsPath.rawValue
        
        let clientIdItem = URLQueryItem(name: QueryItemName.clientID.rawValue,
                                        value: Credentials.clientId.rawValue)
        let queryItem = URLQueryItem(name: QueryItemName.query.rawValue,
                                     value: query)
        urlComponents.queryItems = [clientIdItem, queryItem]
        
        guard let url = urlComponents.url else {
            completion?(.failure(SearchError.wrongURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = API.httpMethod.rawValue
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        requestTask = session.dataTask (with: request) { (responseData, _, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    if (error as NSError).code != ErrorCode.cancelled.rawValue {
                        completion?(.failure(error))
                    }
                } else {
                    do {
                        guard let parser: Parser = Services.shared.getService() else {
                            throw SearchError.defaultError
                        }
                        let events = try parser.decodeEvents(from: responseData)
                        completion?(.success(events))
                    } catch {
                        completion?(.failure(error))
                    }
                } 
            }
        }
        
        requestTask?.resume()
    }
}

extension SearchEngineImp: SearchEngine {
    func search(for query: String, completion: ((RequestResult<[Event]>) -> Void)?) {
        self.cancelSearch()

        // reset timer if it has been already run
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: Constants.debounceInterval.rawValue, repeats: false, block: { [weak self] (_) in
            
            self?.debounceTimer = nil
            
            self?.getSearchResults(for: query, completion: { [weak self] (result) in
                self?.requestTask = nil
                completion?(result)
            })
        })
    }
    
    func cancelSearch() {
        debounceTimer?.invalidate()
        debounceTimer = nil
        
        if let ongoingTask = requestTask {
            ongoingTask.cancel()
            requestTask = nil
        }
    }
}
