//
//  UIAlertController+Extension.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/12/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import UIKit

extension UIAlertController {
    func show() {
        DispatchQueue.main.async {
            guard let topController = UIApplication.shared.keyWindow?.rootViewController?.getTopMostController() else {
                self.showInNewWindow()
                return
            }
            
            if let alert = topController as? UIAlertController {
                guard let presenter = alert.presentingViewController else { return }
                presenter.dismiss(animated: true, completion: {
                    presenter.present(self, animated: false, completion: nil)
                })
                return
            }
            topController.present(self, animated: false, completion: nil)
        }
    }
    
    func showInNewWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.windowLevel = UIWindow.Level.alert
        window.makeKeyAndVisible()
        window.rootViewController?.present(self, animated: false, completion: nil)
    }
    
    static func show(error: Error) {
        let alert = UIAlertController(title: "Error".localized,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK".localized, style: .default, handler: nil)
        alert.addAction(okAlertAction)
        
        alert.show()
    }
}
