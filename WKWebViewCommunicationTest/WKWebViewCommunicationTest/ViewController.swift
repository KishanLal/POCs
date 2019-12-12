//
//  ViewController.swift
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 KISHAN LAL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func buttonClicked(_ sender: Any) {
        if let button = sender as? UIButton{
            if button.tag == 1000{
                print("Using UIWebView for investigation")
                
                let uiWebViewPlayer = UIWebViewPlayer(nibName: "UIWebViewPlayer", bundle: nil)
                let navVC = UINavigationController(rootViewController: uiWebViewPlayer)
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true) {
            
                }
            }
            else if button.tag == 2000{
                print("Using WKWebView for investigation")
                
                let wkWebViewPlayer = WKWebViewPlayer(nibName: "WKWebViewPlayer", bundle: nil)
                let navVC = UINavigationController(rootViewController: wkWebViewPlayer)
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true) {
                    
                }
            }
        }
    }
}

