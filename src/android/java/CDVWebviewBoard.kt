package jp.rabee

import android.content.Intent
import android.util.Log
import org.apache.cordova.*
import org.json.JSONArray
import android.view.WindowManager

class CDVWebviewBoard: CordovaPlugin() {
    override public fun initialize(cordova: CordovaInterface,  webView: CordovaWebView) {
        LOG.d(TAG, "hi! This is CDVWebviewBoard. Now intitilaizing ...");
    }


    override fun execute(action: String, data: JSONArray, callbackContext: CallbackContext): Boolean {
        var result = false

        when(action) {
            "initialize" -> {
                result = this.init(callbackContext)
            }
            else -> {
                // TODO error
            }
        }

        return result
    }

    private fun init(callbackContext: CallbackContext): Boolean {
        val p = PluginResult(PluginResult.Status.OK, "initialized")
        callbackContext.sendPluginResult(p)
        return true
    }

    companion object {
        private const val TAG = "CDVWebviewBoard"
    }

}