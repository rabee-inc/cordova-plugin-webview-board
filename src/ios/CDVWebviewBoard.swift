import UIKit
import WebKit

@objc(CDVWebviewBoard ) class CDVWebviewBoard: CDVPlugin, WKUIDelegate {
    
    var urlString:String!
    var functionCallbackId = ""
    var webview:WKWebView?
    
    struct Rect {
        var top = 0
        var left = 0
        var width = 0
        var height = 0
        
        init(data: [String: Any]) {
            guard
            let tempTop = data["top"] as? Int,
            let tempLeft = data["left"] as? Int,
            let tempWidth = data["width"] as? Double,
            let tempHeight = data["height"]as? Double else {
                return
            }
            top = tempTop
            left = tempLeft
            width = Int(tempWidth)
            height = Int(tempHeight)
        }
    }
    
    struct MessageEvent {
        var eventName: String?
        var data: Any?
        
        init(message: WKScriptMessage) {
            guard
            let body = message.body as? NSDictionary,
            let eventNameData = body["eventName"] as? String
            else {
                return
            }
            eventName = eventNameData
            data = body["data"]
        }
    }


    
    @objc override func pluginInitialize() {
//        code for inspection
//        urlString = Bundle.main.path(forResource: "www/subview", ofType: "html")
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

        guard
        let data = command.argument(at: 0) as? [String: Any],
        let urlTemp = data["url"] as? String,
        let rectData = data["rect"] as? [String : Any] else {return}
        
        if isAdded() {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "webview already added")
            commandDelegate.send(result, callbackId: command.callbackId)
            return
        }
        
//        set sizes
        let rect = Rect(data: rectData)
        
//        webview setup
        let userController = WKUserContentController()
        userController.add(self, name: "native")
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userController
        webview = WKWebView(frame: CGRect(x: rect.left, y: rect.top, width: rect.width, height: rect.height), configuration: webConfiguration)
        self.webview!.uiDelegate = self
        self.webview!.navigationDelegate = self

//        set url
        urlString = urlTemp
//        let url = URL(fileURLWithPath: urlString, isDirectory: false)
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        webview!.load(urlRequest)
        self.webView.addSubview(webview!)

        let result = CDVPluginResult(status: CDVCommandStatus_OK)
        commandDelegate.send(result, callbackId: command.callbackId)
    }
    
    @objc func show(_ command: CDVInvokedUrlCommand) {
        if isAdded() {
            let shouldShow = command.argument(at: 0) as! Bool
            webview!.isHidden = !shouldShow
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "ok")
            commandDelegate.send(result, callbackId: command.callbackId)
        } else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "webview does not exist")
            commandDelegate.send(result, callbackId: command.callbackId)
        }
    }
    
    @objc func load(_ command: CDVInvokedUrlCommand) {
        if isAdded() {
            let loadRequest = URLRequest(url: URL(string: urlString)!)
            webview!.load(loadRequest)
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "ok")
            commandDelegate.send(result, callbackId: command.callbackId)
        } else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "webview does not exist")
            commandDelegate.send(result, callbackId: command.callbackId)
        }
    }
    
    @objc func forward(_ command: CDVInvokedUrlCommand) {
        if isAdded() {
            webview!.goForward()
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "ok")
            commandDelegate.send(result, callbackId: command.callbackId)
        } else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "webview does not exist")
            commandDelegate.send(result, callbackId: command.callbackId)
        }
    }
    
    @objc func back(_ command: CDVInvokedUrlCommand) {
        if isAdded() {
            webview!.goBack()
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "ok")
            commandDelegate.send(result, callbackId: command.callbackId)
        } else {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "webview does not exist")
            commandDelegate.send(result, callbackId: command.callbackId)
        }
    }
    
    @objc func resize(_ command: CDVInvokedUrlCommand) {
        guard
        let rectData = command.argument(at: 0) as? [String: Any] else {return}
        let rect = Rect(data: rectData)
        webview!.frame = CGRect(x: rect.left, y: rect.top, width: rect.width, height: rect.height)
    }
    
    private func isAdded() -> Bool {
        return webview != nil
    }
    
    @objc func setOnFunctionCallback(_ command: CDVInvokedUrlCommand) {
        functionCallbackId = command.callbackId
    }

}



extension CDVWebviewBoard: WKScriptMessageHandler, WKNavigationDelegate  {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        self.urlString = webView.url?.absoluteString
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "native":
            let body = MessageEvent(message: message)

            
            let data = [
                "eventName": body.eventName,
                "data": body.data
            ]
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: data as [String : Any])
            result?.keepCallback = true
            commandDelegate.send(result, callbackId: functionCallbackId)
        default:
            break
        }
    }


}
