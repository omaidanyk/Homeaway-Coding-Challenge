//
//  Parser.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/12/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import Foundation

protocol Parser {
    func decodeEvents(from sourceData: Data?) throws -> [Event]
}

class ParserImp: Parser {
    func decodeEvents(from sourceData: Data?) throws -> [Event] {
        guard let data = sourceData,
              let storage: Storage = Services.shared.getService()
            else {
                throw SearchError.emptyResponse
        }
        
        let decoder = JSONDecoder()
        
        let searchRespond = try decoder.decode(SourceRespond.self, from: data)
        
        var events = [Event]()
        for source in searchRespond.events {
            if let existedEvent = storage.getEvent(id: source.id) as? EventImp {
                existedEvent.update(with: source)
                events.append(existedEvent)
            } else {
                events.append(EventImp(with: source))
            }
        }
        return events
    }
}

// MARK: - Codable sources

struct SourceRespond: Codable {
    var events: [SourceEvent]
}

struct SourceEvent: Codable {
    var id: Int
    var datetime: String
    var isTimeUnknown: Bool
    var performers: [SourcePerformer]
    var title: String
    var shortTitle: String
    var venue: SourceVenue
    
    enum CodingKeys: String, CodingKey {
        case id
        case datetime = "datetime_utc"
        case isTimeUnknown = "datetime_tbd"
        case performers
        case title
        case shortTitle = "short_title"
        case venue
    }
}

struct SourcePerformer: Codable {
    var imageLink: String?
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case imageLink = "image"
        case name
    }
}

struct SourceVenue: Codable {
    var locationDescription: String
    var address: String
    
    enum CodingKeys: String, CodingKey {
        case address
        case locationDescription = "display_location"
    }
}
