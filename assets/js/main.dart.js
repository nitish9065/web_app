
init = () => {

    console.log('Hello world');

    enterFullScreen = () => {
        window.document.body.requestFullscreen();
    }

    exitFullScreen = () => {
        window.document.exitFullscreen();
    }

    _enterFullScreen = enterFullScreen;
    _exitFullScreen = exitFullScreen;

}

window.addEventListener('load', function (event) {

    init();
});