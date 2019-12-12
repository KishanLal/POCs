//
//  File.swift
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 KISHAN LAL. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView{
    func loadHTMLWithScormAdaptor(htmlFilePath: String){
        let scormAdaptorPath = PathUtil.scormAdaptorPath(OfflineMode) ?? ""
        let ios_loaderPath = PathUtil.iosLoaderPath() ?? ""
        let loadingHtmlPath = PathUtil.loadingHTMLPath(OfflineMode) ?? ""
        
        let htmlString = String(format: "<html><head></head><frameset framespacing=\"0\" rows=\"*,0\" frameborder=\"0\" noresize><frame name =\"sco\" src=\"%@\"><frame name=\"adaptor\" src=\"%@?sco_url=%@\"></frameset></html>", loadingHtmlPath,scormAdaptorPath,htmlFilePath)
        
        print(htmlString)
        
        do {
                                    
            let url = URL(fileURLWithPath: ios_loaderPath)
            try htmlString.write(to: url, atomically: true, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            if url.isFileURL{
                self.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            }
            else{
                let request = URLRequest(url: url)
                self.load(request)
            }
        } catch {
            print(error)
        }
    }
    
    func nativeToJS(callbackFunction:String, response:String){
        let jsString = String(format: #"parent.adaptor.jsToNativeBridge.%@("%@");"#, callbackFunction,response)
                
        self.evaluateJavaScript(jsString as String) { (success, error) in
            //print(success,error)
        }
    }
}
