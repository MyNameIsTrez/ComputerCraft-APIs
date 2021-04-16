const express = require("express");

const app = express();

require("./routes/server/server")(app);
require("./routes/apis/apis")(app);
