var Xvfb = require('xvfb');
var xvfb = new Xvfb();
xvfb.start(function(err, xvfbProcess) {
  // code that uses the virtual frame buffer here
  console.log(err);
  console.log(xvfbProcess);
  xvfb.stop(function(err) {
    // the Xvfb is stopped
  });
});
console.log(xvfb);
