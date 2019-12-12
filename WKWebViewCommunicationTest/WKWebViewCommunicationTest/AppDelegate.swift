//
//  AppDelegate.swift
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 KISHAN LAL. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        copySupportingFilesToDocumentDirectory()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate : FileManagerDelegate {
    class func statusBarView() -> UIView {
        
        var statusBarView : UIView!
        
        if #available(iOS 13.0,  *) {
            statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
            UIApplication.shared.keyWindow?.addSubview(statusBarView)
        } else {
            statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
        }

        return statusBarView
    }
    
    func copySupportingFilesToDocumentDirectory() {
        let fileManager = FileManager.default
        fileManager.delegate = self
        let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let docsURL = dirPaths[0]

        let folderPath = Bundle.main.resourceURL!.appendingPathComponent("SupportingFiles").path
        let docsFolder = docsURL.path
        do{
            let filePaths = try fileManager.contentsOfDirectory(atPath: docsFolder)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: docsFolder + "/" + filePath)
            }
        }
        catch{
            print("Failed to delete file")
        }
        copyFiles(pathFromBundle: folderPath, pathDestDocs: docsFolder)
    }

    func copyFiles(pathFromBundle : String, pathDestDocs: String) {
        let fileManagerIs = FileManager.default
        fileManagerIs.delegate = self

        do {
            let filelist = try fileManagerIs.contentsOfDirectory(atPath: pathFromBundle)
            try? fileManagerIs.copyItem(atPath: pathFromBundle, toPath: pathDestDocs)

            for filename in filelist {
                try? fileManagerIs.copyItem(atPath: "\(pathFromBundle)/\(filename)", toPath: "\(pathDestDocs)/\(filename)")
            }
        } catch {
            print("\nError\n")
        }
    }
}
