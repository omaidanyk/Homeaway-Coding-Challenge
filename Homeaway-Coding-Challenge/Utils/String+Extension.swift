//
//  String+Extension.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/12/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import Foundation

extension String {
    //we can easy make our app localized now
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: self, comment: "")
    }
}
