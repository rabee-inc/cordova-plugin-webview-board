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
        WebviewBoard.add(element.getBoundingClientRect()).then(() => {
            window.alert('added!!');
        });
    });
    
    window.addEventListener('resize', () => {
        WebviewBoard.resize(element.getBoundingClientRect());
    });

    const observer = new MutationObserver(mutations => {
        mutations.forEach(mutation => {
            if (mutation.type === "attributes") {
                if (mutation.attributeName === "show") {
                    WebviewBoard.show(isShown);
                }
            }
        });
    });
    observer.observe(element, { attributes: true, characterData: true})
    
    const showBtn = document.querySelector('.showBtn');
    var isShown = false;
    showBtn.addEventListener('click', () => {
        element.setAttribute('show', isShown);
        isShown = !isShown;
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
