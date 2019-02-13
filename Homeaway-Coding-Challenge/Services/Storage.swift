//
//  Storage.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/12/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import UIKit

protocol Storage {
    var savedEvents: [Event] { get }
    func save(event: Event)
    func getEvent(id: Int) -> Event?
    func delete(event: Event)
}

class StorageImp: NSObject {
    var savedEvents = [Event]()
    
    override init() {
        super.init()
        savedEvents = loadSavedEvents()
    }
    
    private func save(image: UIImage, to fileName: String) -> String? {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(fileName).png")
            if let pngImageData = image.pngData() {
                try pngImageData.write(to: fileURL, options: .atomic)
            }
            return fileURL.absoluteString
        } catch {
            UIAlertController.show(error: StorageError.failedSaveImage)
            return nil
        }
    }
    
    private func loadSavedEvents() -> [Event] {
        let dataArray = UserDefaults.standard.array(forKey: UserDefaults.Keys.events.rawValue) as? [Data] ?? []
        var events = [Event]()
        
        let decoder = JSONDecoder()
        for data in dataArray {
            if let event = try? decoder.decode(EventImp.self, from: data) {
                events.append(event)
            }
        }
        return events
    }
    
    private func storeSavedEvents() {
        if savedEvents.isEmpty {
            UserDefaults.standard.set(nil, forKey: UserDefaults.Keys.events.rawValue)
        } else {
            var dataArray = [Data]()
            let encoder = JSONEncoder()
            for event in savedEvents {
                guard let object = event as? EventImp else { continue }
                if let data = try? encoder.encode(object) {
                    dataArray.append(data)
                }
            }
            
            UserDefaults.standard.set(dataArray, forKey: UserDefaults.Keys.events.rawValue)
        }
    }
}

extension StorageImp: Storage {
    func save(event: Event) {
        guard let object = event as? EventImp else { return }
        
        if let image = object.image, let id = object.id {
            object.imageFileURL = save(image: image, to: "\(id)")
        }
        
        if let existedIndex = savedEvents.firstIndex(where: { $0.id == object.id }) {
            savedEvents[existedIndex] = object
        } else {
            savedEvents.append(event)
        }
        
        storeSavedEvents()
    }
    
    func delete(event: Event) {
        if let existedIndex = savedEvents.firstIndex(where: { $0.id == event.id }) {
            savedEvents.remove(at: existedIndex)
            storeSavedEvents()
        }
    }
    
    func getEvent(id: Int) -> Event? {
        return savedEvents.first(where: { $0.id == id })
    }
}
