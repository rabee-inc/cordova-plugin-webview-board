'use strict';

class WebviewBoard {
  constructor(params) {
    this.exec = require('cordova/exec');
    this._listener = {};
  }

  initialize(params) {
    return this.createAction('initialize', params); 
  }


  // cordova の実行ファイルを登録する
  registerCordovaExecuter(action, onSuccess, onFail, param) {
    return this.exec(onSuccess, onFail, 'CDVWebviewBoard', action, [param]);
  };

  // promise で返す。 cordova の excuter の wrapper
  createAction(action, params) {
    return new Promise((resolve, reject) => {
      // actionが定義されているかを判定したい
      if (true) {
        // cordova 実行ファイルを登録
        this.registerCordovaExecuter(action, resolve, reject, params);
      }
      else {
        // TODO: error handling
      }
    });
  };

  // イベントをバインド
  registerEvents(onSuccess, action, params) {
    this.exec(
      (data) => {
        this.trigger(onSuccess, data);
      }, 
      (error) => {
        console.log(error, 'error');
      }, 'CDVWebviewBoard', action, [params]
    );
  };
  
  trigger(event, value) {
      if (this._listener[event]) {
        this._listener[event].forEach(callback => {
          if (typeof callback === 'function') {
            callback(value);
          }
      });
    }
  };

  checkInit(params) {
    return this.createAction('checkInit', params)
  };


  // 登録関係
  on(event, callback) {
    this._listener[event] = this._listener[event] || [];
      this._listener[event].push(callback);
    };

  off(event, callback) {
    if (!this._listener[event]) this._listeners[event] = [];
    if (event && typeof callback === 'function') {
      var i = this._listener[event].indexOf(callback);
      if (i !== -1) {
        this._listener[event].splice(i, 1);
      }
    }
  };

  clearEventListner(event) {
    this._listener[event] = [];
  };

}


module.exports = new WebviewBoard();
