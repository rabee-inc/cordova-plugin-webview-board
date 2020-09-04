document.addEventListener('deviceready', onDeviceReady, false);	

function onDeviceReady() {   	
    WebviewBoard.initialize().then(() => {
        window.alert('initialized');
    });
    
    const checkInitBtn = document.querySelector('.checkInitBtn');
    checkInitBtn.addEventListener('click', () => {
        WebviewBoard.checkInit().then(() => {
            window.alert('initialized!!');
        });
    });
    
    var element = document.getElementById('target');
    const addBtn = document.querySelector('.addBtn');
    addBtn.addEventListener('click', () => {
        WebviewBoard.isShown = true;
        var data = {
            url: "http://google.com",
            rect: element.getBoundingClientRect(),
        }
        WebviewBoard.add(element, data).then(() => {
            window.alert('added!!');
        });
    });
    
    window.addEventListener('resize', () => {
        WebviewBoard.resize(element.getBoundingClientRect());
    });
    
    const showBtn = document.querySelector('.showBtn');
    // var isShown = false;
    showBtn.addEventListener('click', () => {
        element.setAttribute('show', WebviewBoard.isShown);
        WebviewBoard.isShown = !WebviewBoard.isShown;
    });

    const loadBtn = document.querySelector('.loadBtn');
    loadBtn.addEventListener('click', () => {
        WebviewBoard.load();
    });

    const forwardBtn = document.querySelector('.forwardBtn');
    forwardBtn.addEventListener('click', () => {
        WebviewBoard.forward();
    });

    const backBtn = document.querySelector('.backBtn');
    backBtn.addEventListener('click', () => {
        WebviewBoard.back();
    });

    WebviewBoard.on('message', ({eventName, data}) => {
        switch(eventName) {
            case "alert":
                window.alert(data);
                break;
            default:
                break;
        }
    });
}
