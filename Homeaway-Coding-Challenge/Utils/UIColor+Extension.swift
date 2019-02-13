//
//  UIColor+Extension.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/12/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import UIKit

extension UIColor {
    class var mainTheme: UIColor {
        return UIColor(red: 17/255.0, green: 45/255.0, blue: 65/255.0, alpha: 1.0)
    }
    
    class var mainThemeLight: UIColor {
        return UIColor(red: 38/255.0, green: 65/255.0, blue: 82/255.0, alpha: 1.0)
    }
    
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
