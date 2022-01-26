const blue = '#2B58A1';
const red = '#C63519';

let bgToggleState = 0;
window.setInterval(
  function() {
    if (bgToggleState === 0) {
      bgToggleState = 1;
      document.body.style.backgroundColor = blue;
    } else {
      bgToggleState = 0;
      document.body.style.backgroundColor = red;
    }
  },
  800
);

let titleToggleState = 0;
window.setInterval(
  function() {
    if (titleToggleState === 0) {
      // unlit
      titleToggleState = 1;
      document.body.getElementsByTagName('h1')[0].style.color = '#AAA';
      document.body.getElementsByTagName('h1')[0].style.textShadow = '0 0 3px #111';
    } else {
      // lit
      titleToggleState = 0;
      document.body.getElementsByTagName('h1')[0].style.color = '#EEE';
      document.body.getElementsByTagName('h1')[0].style.textShadow = '0 0 20px #CCC';
    }
  },
  1100
);
