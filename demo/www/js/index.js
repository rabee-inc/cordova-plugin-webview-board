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
    
    var element = document.getElementById('target');
    const addBtn = document.querySelector('.addBtn');
    addBtn.addEventListener('click', () => {
        isShown = true;
        var show = element.getAttribute('show')
        WebviewBoard.add({show: show, rect: element.getBoundingClientRect()}).then(() => {
            window.alert('added!!');
        });
    });

    const observer = new MutationObserver(mutations => {
        mutations.forEach(mutation => {
            console.warn(mutation);
        });
    });
    observer.observe(element, { attributes: true })
    
    const showBtn = document.querySelector('.showBtn');
    var isShown = false;
    showBtn.addEventListener('click', () => {
        isShown = !isShown;
        WebviewBoard.show(isShown);
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
}
