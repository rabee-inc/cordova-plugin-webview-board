import UIKit
import WebKit

@objc(CDVWebviewBoard ) class CDVWebviewBoard: CDVPlugin, WKNavigationDelegate, WKUIDelegate {
    
    var show = false
    var added = false
    var top = 0
    var left = 0
    var width = 0
    var height = 0
    var urlString:String!
    var webview:WKWebView!
    
    @objc override func pluginInitialize() {
        urlString = "http://google.com"
    }
    
    @objc func initialize(_ command: CDVInvokedUrlCommand) {
        let result = CDVPluginResult(status: CDVCommandStatus_OK)
        commandDelegate.send(result, callbackId: command.callbackId)
    }
    
    @objc func checkInit(_ command: CDVInvokedUrlCommand) {
        let result = CDVPluginResult(status: CDVCommandStatus_OK)
        commandDelegate.send(result, callbackId: command.callbackId)
    }
    
    @objc func add(_ command: CDVInvokedUrlCommand) {
        if added {return}
        guard
        let data = command.argument(at: 0) as? [String: Any],
        let rect = data["rect"] as? [String: Any] else {return}
        
        show = Bool(data["show"] as! String)!
        top = rect["top"] as! Int
        left = rect["left"] as! Int
        
        let tempWidth = rect["width"] as! Double
        let tempHeight = rect["width"] as! Double
        width = Int(tempWidth)
        height = Int(tempHeight)
        
//        webview setup
        let userController = WKUserContentController()
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userController

        
        let statusbarHeight = Int(UIApplication.shared.statusBarFrame.height)

        webview = WKWebView(frame: CGRect(x: left, y: top + statusbarHeight, width: width, height: height), configuration: webConfiguration)

        webview.uiDelegate = self
        webview.navigationDelegate = self

        let url = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
        webview.load(urlRequest)
        self.webView.addSubview(webview)

        added = true

        let result = CDVPluginResult(status: CDVCommandStatus_OK)
        commandDelegate.send(result, callbackId: command.callbackId)
    }
    
    @objc func show(_ command: CDVInvokedUrlCommand) {
        let shouldShow = command.argument(at: 0) as! Bool
        webview.isHidden = !shouldShow
    }
    
    @objc func load(_ command: CDVInvokedUrlCommand) {
        let loadRequest = URLRequest(url: URL(string: urlString)!)
        webview.load(loadRequest)
    }
    
    @objc func forward(_ command: CDVInvokedUrlCommand) {
        webview.goForward()
    }
    
    @objc func back(_ command: CDVInvokedUrlCommand) {
        webview.goBack()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        urlString = webView.url?.absoluteString
        decisionHandler(WKNavigationActionPolicy.allow)
    }

    
}

