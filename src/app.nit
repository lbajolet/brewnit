# Brewnit web server
module app

import api
import popcorn::pop_config

redef class AppConfig
	redef var app_port = 4000
end

var opts = new AppOptions.from_args(args)
var config = new AppConfig.from_options(opts)
var app = new App

app.use("/api", new APIRouter)

app.use_after("/*", new ConsoleLog)

app.listen(config.app_host, config.app_port)
