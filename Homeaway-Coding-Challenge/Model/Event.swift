//
//  Event.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/12/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import UIKit

// completion type for handling completion of loading image from web
typealias ImageLoadingCompletion = (UIImage?, Error?) -> Void

protocol Event {
    var id: Int? { get set }
    var title: String { get set }
    var shortTitle: String { get set }
    var placeDescription: String { get set }
    var dateDescription: String { get set }
    var image: UIImage? { get }
    var imageURL: String? { get set }
    var isFavourite: Bool { get set }
    
    func loadImage(completion: ImageLoadingCompletion?)
}

class EventImp: NSObject, Codable {
    var id: Int?
    var title: String = Placeholder.title.rawValue
    var shortTitle: String = Placeholder.title.rawValue
    var placeDescription: String = Placeholder.place.rawValue
    var dateDescription: String = Placeholder.date.rawValue
    var image: UIImage?
    var imageURL: String?
    var imageFileURL: String?
    var isFavourite: Bool = false
    private var loadingCompletionHandlers = [ImageLoadingCompletion]()
    private var isLoadingImage = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case shortTitle
        case placeDescription
        case dateDescription
        case imageURL
        case imageFileURL
        case isFavourite
    }
    
    init(with source: SourceEvent) {
        super.init()
        update(with: source)
    }
    
    func update(with source: SourceEvent) {
        id = source.id
        title = source.title
        shortTitle = source.shortTitle
        placeDescription = source.venue.locationDescription
        dateDescription = readableDate(from: source.datetime, timeTBD: source.isTimeUnknown)
        
        // here we can show all images and not only the first one
        for performer in source.performers {
            if let imageLink = performer.imageLink {
                imageURL = imageLink
                break
            }
        }
        
        if imageURL == nil && imageFileURL == nil {
            image = UIImage(named: "noImage")
        }
    }
    
    private func notifyLoadingCompletionHandlers(loaded image: UIImage?, with error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let completions = self?.loadingCompletionHandlers else { return }
            for completion in completions {
                completion(image, error)
            }
            // drop completion blocks after execution
            self?.loadingCompletionHandlers = [ImageLoadingCompletion]()
        }
    }
    
    private func readableDate(from timeStamp: String, timeTBD: Bool) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = DateFormat.source.rawValue
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let date = dateFormatter.date(from: timeStamp) else { return Placeholder.date.rawValue }
        
        // change to a readable time format and local time zone
        dateFormatter.dateFormat = timeTBD ? DateFormat.readableTBD.rawValue : DateFormat.readable.rawValue
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
}

extension EventImp: Event {
    func loadImage(completion: ImageLoadingCompletion?) {
        if let completionHandler = completion {
            loadingCompletionHandlers.append(completionHandler)
        }
        
        guard let url = URL(string: imageURL ?? imageFileURL ?? ""), isLoadingImage == false else { return }
        
        // prevent multiple downloading if we already started to download
        isLoadingImage = true
        
        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, _, error) in
            
            self?.isLoadingImage = false
            
            guard let imageData = data, error == nil else {
                // notify about failure case
                self?.notifyLoadingCompletionHandlers(loaded: nil, with: error)
                return
            }
            
            let image = UIImage(data: imageData)
            self?.image = image
            // notify about successful case
            self?.notifyLoadingCompletionHandlers(loaded: image, with: nil)
            
        }).resume()
    }
}
