import UIKit
import WebKit

@objc(CDVWebviewBoard ) class CDVWebviewBoard: CDVPlugin, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    
    var show = false
    var added = false
    var top = 0
    var left = 0
    var width = 0
    var height = 0
    var urlString:String!
    var functionCallbackId = ""
    var statusbarHeight:Int!
    var webview:WKWebView!
    
    @objc override func pluginInitialize() {
        urlString = Bundle.main.path(forResource: "www/subview", ofType: "html")
        statusbarHeight = Int(UIApplication.shared.statusBarFrame.height)
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
//        addしてたらreturn
        if added {return}
        guard
        let rect = command.argument(at: 0) as? [String: Any] else {return}
//        set sizes
        setRect(rect: rect)
        
//        webview setup
        let userController = WKUserContentController()
        userController.add(self, name: "native")
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userController
        webview = WKWebView(frame: CGRect(x: left, y: top + statusbarHeight, width: width, height: height), configuration: webConfiguration)
        self.webview.uiDelegate = self
        self.webview.navigationDelegate = self

//        set url
        let url = URL(fileURLWithPath: urlString, isDirectory: false)
        webview.loadFileURL(url, allowingReadAccessTo: url)
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
    
    @objc func resize(_ command: CDVInvokedUrlCommand) {
        guard
        let rect = command.argument(at: 0) as? [String: Any] else {return}
        setRect(rect: rect)
        webview.frame = CGRect(x: left, y: top + statusbarHeight, width: width, height: height)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        urlString = webView.url?.absoluteString
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    struct MessageEvent {
        var eventName: String?
        var data: String?
        
        init(message: WKScriptMessage) {
            guard let body = message.body as? NSDictionary else {
                return
            }
            self.eventName = body["eventName"] as? String
            self.data = body["data"] as? String
        }
    }

    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "native":
            let body = MessageEvent(message: message)

            
            let data = [
                "eventName": body.eventName!,
                "data": body.data!
            ]
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: data)
            result?.keepCallback = true
            commandDelegate.send(result, callbackId: functionCallbackId)
        default:
            break
        }
    }

    
    private func setRect(rect: [String: Any]) {
        top = rect["top"] as! Int
        left = rect["left"] as! Int
         
        let tempWidth = rect["width"] as! Double
        let tempHeight = rect["width"] as! Double
        width = Int(tempWidth)
        height = Int(tempHeight)

    }
    
    @objc func setOnFunctionCallback(_ command: CDVInvokedUrlCommand) {
        functionCallbackId = command.callbackId
    }

    
}

