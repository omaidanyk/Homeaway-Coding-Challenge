//
//  SearchError.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/12/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import Foundation

enum SearchError: Error {
    case defaultError
    case emptyResponse
    case wrongURL
}

extension SearchError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .defaultError:
            return "Something went wrong".localized
        case .emptyResponse:
            return "Data was not retrieved from request".localized
        case .wrongURL:
            return "Can not create URL. API host address or search text has wrong symbols".localized
        }
    }
}

enum StorageError: Error {
    case failedSaveImage
}

extension StorageError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedSaveImage:
            return "Could not save image to file".localized
        }
    }
}
