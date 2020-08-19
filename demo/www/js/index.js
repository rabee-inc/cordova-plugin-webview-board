document.addEventListener('deviceready', onDeviceReady, false);	
function onDeviceReady() {   	
    WebviewBoard.initialize().then(() => {
        window.alert('initialized')
    });

    const checkInitBtn = document.querySelector('.checkInitBtn');
    checkInitBtn.addEventListener('click', () => {
        WebviewBoard.checkInit().then(() => {
            window.alert('initialized!!');
        });
    });

}
