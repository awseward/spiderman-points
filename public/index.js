const blue = '#2B58A1';
const red = '#C63519';

let foo = 1;

window.setInterval(
  function() {
    if (foo === 0) {
      foo = 1;
      document.body.style.backgroundColor = red;
    } else {
      foo = 0;
      document.body.style.backgroundColor = blue;
    }
  },
  600
);

