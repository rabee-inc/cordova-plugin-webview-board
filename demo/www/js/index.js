document.addEventListener('deviceready', onDeviceReady, false);	
function onDeviceReady() {   	
    CordovaWebviewBoard.initialize().then(() => {
        window.alert('initialized')
    });

    const checkInitBtn = document.querySelector('.checkInitBtn');
    checkInitBtn.addEventListener('click', () => {
        CordovaWebviewBoard.checkInit().then(() => {
            window.alert('initialized!!');
        });
    });

}
