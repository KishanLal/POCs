//
//  WKWebViewAlertHandler.swift
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 Kishan. All rights reserved.
//

import UIKit

class WKWebViewAlertHandler: NSObject {
    
    class func presentAlert(on parentController: UIViewController, title: String?, message: String?, handler completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
            completionHandler()
        }))
        parentController.present(alertController, animated: true) {
        }
    }
    
    class func presentConfirm(on parentController: UIViewController, title: String?, message: String?, handler completionHandler: @escaping (_ result: Bool) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completionHandler(false)
        }))
        parentController.present(alertController, animated: true) {
        }
    }
    
    class func presentPrompt(on parentController: UIViewController, title: String?, message: String?, defaultText: String?, handler completionHandler: @escaping (_ result: String?) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            textfield.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            let input = (alertController.textFields?.first)?.text
            completionHandler(input)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completionHandler(nil)
        }))
        parentController.present(alertController, animated: true) {
        }
    }
}
