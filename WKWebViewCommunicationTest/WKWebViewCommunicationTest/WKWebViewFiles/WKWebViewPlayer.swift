//
//  WKWebViewPlayer.swift
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 KISHAN LAL. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewPlayer: UIViewController {
    
    //MARK:- IBOutlets
    
    let CONTENTPLAYER_REQUEST_TYPE_LOAD = 1
    let CONTENTPLAYER_REQUEST_TYPE_UNLOAD = 2
    let CONTENTPLAYER_REQUEST_TYPE_CHANGE_SCO = 3
    
    static let kJSOverrideWindowCloseForScorm = "window.close = function () { parent.adaptor.currentlyUsedAPI.FrameworkTerminate('') }"
    
    static let kAdaptorTerminateFrameWorkScript = "parent.adaptor.currentlyUsedAPI.FrameworkTerminate('')"
    
    static let kAboutBlankInFrameScript = "parent.frames[0].location = 'about:blank';"
    
    static let kWindowCloseScript = "handleWindowClose();"
    
    static let kAboutBlankScript = "about:blank"
    
    var webviewRequestType: Int?
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var tocView: UIView!
    @IBOutlet weak var tocTableView: UITableView!
    @IBOutlet weak var tocViewLeading: NSLayoutConstraint!
    
    var webView: WKWebView!
    var popupWebView: WKWebView!
        
    let IS_iPad = (UIDevice.current.userInterfaceIdiom == .pad ? true : false)
    
    //MARK:- Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Test WKWebView"
        tocView.backgroundColor = .lightGray
        
        setupTableView()
        setupWebView()
        
        guard let launchURL = PathUtil.appDocumentDirectoryPath()?.appending("/contentstore/Test1/index.html") else { return  }
        webviewRequestType = CONTENTPLAYER_REQUEST_TYPE_LOAD
        webView.loadHTMLWithScormAdaptor(htmlFilePath: launchURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let rightBarButton = UIBarButtonItem(title: NSLocalizedString("Exit", comment: ""), style: .plain, target: self, action: #selector(self.exitButtonPressed(sender:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        let leftBarButton = UIBarButtonItem(title: NSLocalizedString("TOC", comment: ""), style: .plain, target: self, action: #selector(self.showHideTOC))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        webView.stopLoading()
        webView.removeFromSuperview()
        
        super.viewWillDisappear(animated)
    }
    
    //MARK:- Helper
    
    func setupWebView(){
        if (self.webView != nil){
            self.webView.removeFromSuperview()
        }
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        let userContentController = WKUserContentController()
        
        let viewportScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let viewportScript = WKUserScript(source: viewportScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        userContentController.addUserScript(viewportScript)
        
        userContentController.add(self, name: "nativeCallback")
        
        let pref = WKPreferences()
        pref.javaScriptEnabled = true
        pref.javaScriptCanOpenWindowsAutomatically = true
        pref.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.preferences = pref
        wkWebConfig.userContentController = userContentController
        
        let wkWebSiteStore = WKWebsiteDataStore.nonPersistent()
        wkWebConfig.websiteDataStore = wkWebSiteStore
        
        self.webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.playerContainer.frame.size.width, height: self.playerContainer.frame.size.height), configuration: wkWebConfig)
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.playerContainer.addSubview(self.webView)
        
        self.constraintViewEqual(holderView: self.playerContainer, view: self.webView)
    }
    
    @objc func showHideTOC(){
        let leadingConstant = IS_iPad ? -310 : -250
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            if Int(self?.tocViewLeading.constant ?? 0) == leadingConstant{
                self?.tocViewLeading.constant = 0
            }
            else{
                self?.tocViewLeading.constant = CGFloat(leadingConstant)
            }
        }
    }
    
    func setupTableView(){
        self.tocTableView.backgroundColor = .clear
        
        tocTableView.register(UINib(nibName: "TOCCell", bundle: nil), forCellReuseIdentifier: "TOCCell")
        tocTableView.separatorStyle = .none
        tocTableView.tableFooterView = UIView()
    }
    
    func addCookies(toHeader request: URLRequest?) -> URLRequest? {
        var localRequest = request
        var headers: [String : String]? = nil
        if let shared = HTTPCookieStorage.shared.cookies {
            headers = HTTPCookie.requestHeaderFields(with: shared)
        }
        localRequest?.allHTTPHeaderFields = headers
        return localRequest
    }
    
    func setCookiesToWKWebView() {
        for cookie in HTTPCookieStorage.shared.cookies ?? [] {
            if #available(iOS 11.0, *) {
                let cookieStore = webView?.configuration.websiteDataStore.httpCookieStore
                cookieStore?.setCookie(cookie, completionHandler: {
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func exitPlayer(){
        self.dismiss(animated: true) {
            
        }
    }
    
    func constraintViewEqual(holderView: UIView, view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        //pin 100 points from the top of the super
        let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                        toItem: holderView, attribute: .top, multiplier: 1.0, constant: 0)
        let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                                           toItem: holderView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
                                         toItem: holderView, attribute: .left, multiplier: 1.0, constant: 0)
        let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
                                          toItem: holderView, attribute: .right, multiplier: 1.0, constant: 0)
        holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
    }
    
    //MARK:- Nav bar button handling
    
    @objc func exitButtonPressed(sender: UIButton){
        
        //TODO:- Move this to popup window close button
        if popupWebView != nil{
            popupWebView.removeFromSuperview()
            popupWebView = nil
            return
        }
                
        webviewRequestType = CONTENTPLAYER_REQUEST_TYPE_UNLOAD;
        webView.evaluateJavaScript(WKWebViewPlayer.kAboutBlankInFrameScript) { (result, error) in
            
        }
        
        exitPlayer()
    }
    
    func decodeURL(_ url: String?) -> String? {
        
        let result = url?.removingPercentEncoding
        return result
    }
    
    func encodeURL(_ url: String?) -> String? {
        
        let customAllowedSet =  NSCharacterSet(charactersIn:"!*'();@+$,%#[]").inverted
        let result = url?.addingPercentEncoding(withAllowedCharacters: customAllowedSet)

        return result
    }
    
    func processJSRequest(data:String, callback:String, webView:WKWebView){
        
        print("ProcessJSRequest data:: %@\ncallbackFunction:: %@", data, callback)
        let responseToJS = data.appending("WKWebView Player");
           
        print("responseToJS::%@",responseToJS )
        webView.nativeToJS(callbackFunction: callback, response: String(format: "%@", responseToJS))
    }
}

//MARK:- WKNavigationDelegate
extension WKWebViewPlayer: WKNavigationDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(navigationAction.request.url?.absoluteString ?? "decidePolicyFor")
        
        let url = navigationAction.request.url
        let urlString = decodeURL(url?.absoluteString)
        
        setCookiesToWKWebView()
        
        if (urlString == WKWebViewPlayer.kAboutBlankScript) == true{
            decisionHandler(.allow)
            return
        }
        
        if urlString?.hasPrefix("tonative:::") ?? false {
            let components = urlString?.components(separatedBy: ":::callback:::")
            guard let data = components?[1] else { return }
            
            self.processJSRequest(data: data, callback: "callback", webView: webView)
            
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(webView.url?.description ?? "Test")
        
        guard let response = navigationResponse.response as? HTTPURLResponse,
            let url = navigationResponse.response.url else {
                decisionHandler(.allow)
                return
        }
        
        if let headerFields = response.allHeaderFields as? [String: String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            cookies.forEach { cookie in
                if #available(iOS 11.0, *) {
                    webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(webView.url?.description ?? "didStartProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print(webView.url?.description ?? "didReceiveServerRedirectForProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(webView.url?.description ?? "didFailProvisionalNavigation")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(webView.url?.description ?? "didCommit")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(#function)
        completionHandler(.performDefaultHandling,nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(webView.url?.description ?? "didFinish")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        webView.evaluateJavaScript(WKWebViewPlayer.kJSOverrideWindowCloseForScorm) { (obj, error) in }
        
        if self.webviewRequestType == CONTENTPLAYER_REQUEST_TYPE_UNLOAD{
            webView.evaluateJavaScript(WKWebViewPlayer.kAdaptorTerminateFrameWorkScript) { (obj, error) in }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(webView.url?.description ?? "Test")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

//MARK:- WKUIDelegate
extension WKWebViewPlayer: WKUIDelegate{
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print(webView.url?.description ?? "Test")
        print(navigationAction.description)
                
        popupWebView = WKWebView(frame: CGRect.zero, configuration: configuration)
        popupWebView.navigationDelegate = self
        popupWebView.uiDelegate = self
        popupWebView.translatesAutoresizingMaskIntoConstraints = false

        playerContainer.addSubview(popupWebView)
        constraintViewEqual(holderView: playerContainer, view: popupWebView)

        return popupWebView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        print(webView.url?.description ?? "Test")
        
        if webView == popupWebView {
            popupWebView.removeFromSuperview()
            popupWebView = nil
        }
        
        //webView.removeFromSuperview()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        WKWebViewAlertHandler.presentAlert(on: self, title: "Alert", message: message, handler: completionHandler)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        WKWebViewAlertHandler.presentConfirm(on: self, title: "Confirm", message: message, handler: completionHandler)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        WKWebViewAlertHandler.presentPrompt(on: self, title: "Prompt", message: prompt, defaultText: defaultText, handler: completionHandler)
    }
}

//MARK:- WKScriptMessageHandler
extension WKWebViewPlayer: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if let body = message.body as? String{
            if message.name == "nativeCallback"{
                if body.hasPrefix("tonative:::") {
                    let components = body.components(separatedBy: ":::callback:::")
                    var data = components[1]
                    data = decodeURL(data) ?? "error=0"
                    self.processJSRequest(data: data, callback: "callback", webView: webView)
                }
            }
        }
    }
}

//MARK: TableViewDataSource & TableViewDelegate
extension WKWebViewPlayer: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TOCCell", for: indexPath) as? TOCCell{
            cell.containerView.backgroundColor = .clear
            cell.itemTitle.text = "Reload Test1"
            
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        webView.reload()
        self.showHideTOC()
    }
}
