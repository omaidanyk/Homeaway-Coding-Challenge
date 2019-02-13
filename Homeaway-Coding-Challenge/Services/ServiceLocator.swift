//
//  ServiceLocator.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/12/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import UIKit

protocol ServiceLocator {
    func getService<T>() -> T?
    func addService<T>(service: T)
}

final class Services: ServiceLocator {
    static let shared: ServiceLocator = Services()
    
    // Service registry
    private lazy var registry = [String: Any]()
    
    private init() {
        self.addService(service: StorageImp() as Storage)
        self.addService(service: SearchEngineImp() as SearchEngine)
        self.addService(service: ParserImp() as Parser)
    }
    
    private func typeName(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
    
    func addService<T>(service: T) {
        let key = typeName(T.self)
        registry[key] = service
    }
    
    func getService<T>() -> T? {
        let key = typeName(T.self)
        return registry[key] as? T
    }
}
