//
//  Constants.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/12/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import UIKit

enum Constants: Double {
    case debounceInterval = 1.0
    case animationInterval = 0.3
}

enum SpinnerHeight: CGFloat {
    case `default` = 40.0
    case hidden = 0.0
}

enum Placeholder: String {
    case title = "n/a"
    case place = "Somewhere"
    case date = "Soon"
}

enum DateFormat: String {
    case source = "yyyy-MM-dd'T'HH:mm:ss"
    case readable = "EEE, dd MMM yyyy hh:mm a"
    case readableTBD = "EEE, dd MMM yyyy"
}

enum Credentials: String {
    case clientId = "MTUyNzg0ODF8MTU0OTk2OTA4My4xOA"
    case secret = "fa70ec1ac69e31074bbbdd05153548f463f498302ec6445b511567a536b9866d"
}

enum QueryItemName: String {
    case clientID = "client_id"
    case query = "q"
}

enum API: String {
    case `protocol` = "https"
    case host = "api.seatgeek.com"
    case eventsPath = "/2/events"
    case httpMethod = "GET"
}

enum SegueID: String {
    case showDetailFromList = "ShowDetailController"
}

enum ErrorCode: Int {
    case cancelled = -999
}
