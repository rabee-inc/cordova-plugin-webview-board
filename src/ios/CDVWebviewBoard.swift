import UIKit
import WebKit

@objc(CDVWebviewBoard ) class CDVWebviewBoard: CDVPlugin, WKUIDelegate {
    
    var urlString:String!
    var functionCallbackId = ""
    var webview:WKWebView?
    private var _observers = [NSKeyValueObservation]()
    var canGoForwardCallbackId = ""
    var canGoBackwordCallbackId = ""
    
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
        var event_name: String?
        var data: Any?
        
        init(message: [String: Any]) {
            guard
            let event_name_data = message["event_name"] as? String
            else {
                return
            }
            event_name = event_name_data
            data = message["data"]
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
        webConfiguration.allowsInlineMediaPlayback = true
//        webConfiguration.preferences.javaEnabled = true
        webview = WKWebView(frame: CGRect(x: rect.left, y: rect.top, width: rect.width, height: rect.height), configuration: webConfiguration)
        self.webview!.uiDelegate = self
        self.webview!.navigationDelegate = self
        
//        set url
        urlString = urlTemp
//        let url = URL(fileURLWithPath: urlString, isDirectory: false)
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        webview!.load(urlRequest)
        self.webview?.scrollView.delegate = self
        self.webView.addSubview(webview!)
        
        
        self.webview?.addObserver(self, forKeyPath: "canGoBack", options:.new, context: nil)
        self.webview?.addObserver(self, forKeyPath: "canGoForward", options:.new, context: nil)
                self.webview?.addObserver(self, forKeyPath: "URL", options:.new, context: nil)
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
            webview!.scrollView.zoomScale = 1
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
            webview!.scrollView.zoomScale = 1
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
    
    // callback
    @objc func setOnCanGoForwardCallbackId(_ command: CDVInvokedUrlCommand) {
        canGoForwardCallbackId = command.callbackId
    }
    
    // callback
    @objc func setOnCanGoBackCallbackId(_ command: CDVInvokedUrlCommand) {
        canGoBackwordCallbackId = command.callbackId
    }
    
    // 戻る進むの監視
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let webview = self.webview else {return}
        
        // url が
        if (keyPath == "URL") {
            guard   let webview = self.webview,
                    let view = object as? WKWebView,
                    let url = view.url else {return}
    
            urlString = url.absoluteString
            webview.scrollView.zoomScale = 1
        }
        
        if (keyPath == "canGoBack") {
            let canGoBack = webview.canGoBack
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: canGoBack)
            result?.keepCallback = true
            commandDelegate.send(result, callbackId: canGoBackwordCallbackId)
        }
        
        if (keyPath == "canGoForward") {
            let canGoForward = webview.canGoForward
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: canGoForward)
            result?.keepCallback = true
            commandDelegate.send(result, callbackId: canGoForwardCallbackId)
        }
    }
}



extension CDVWebviewBoard: WKScriptMessageHandler, WKNavigationDelegate, UIScrollViewDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        self.urlString = webView.url?.absoluteString
        self.webview?.scrollView.zoomScale = 1 // 遷移があるたびに scale を元に戻す
        decisionHandler(WKNavigationResponsePolicy.allow)
                    
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "native":
            do {
                let message_body = message.body as! String
                let json = message_body.data(using: .utf8)!
                let serialized_message = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any]
                let body = MessageEvent(message: serialized_message!)

                
                let data = [
                    "event_name": body.event_name,
                    "data": body.data
                ]
                let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: data as [String : Any])
                result?.keepCallback = true
                commandDelegate.send(result, callbackId: functionCallbackId)
            }
            catch {
                let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "json serialize error")
                result?.keepCallback = true
                commandDelegate.send(result, callbackId: functionCallbackId)

            }
        default:
            break
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
         return nil
     }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = true
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation:WKNavigation!) {
    }
}
