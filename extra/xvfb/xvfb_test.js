var Xvfb = require('xvfb');
var xvfb = new Xvfb();
xvfb.start(function(err, xvfbProcess) {
  // TODO: How am I supposed to use the virtual frame buffer though??:
  // code that uses the virtual frame buffer here
  console.log(err);
  console.log(xvfbProcess);
  xvfb.stop(function(err) {
    // the Xvfb is stopped
  });
});
console.log(xvfb);
