# Base for web RESTful interface for brewnit
module api_base

#import config
import popcorn
import model

redef class HttpRequest
	# Database context of a connection
	var ctx: DBContext is lazy do return new DBContext
end

# Handles an API REST call
abstract class APIHandler
	super Handler
end

# Routes for API
class APIRouter
	super Router
end

# APIHandler which requires the use of an `id` field
class IDHandler
	super APIHandler

	# Gets the ID from request
	#
	# If none is found or id is not an int, return null and set response to 400
	fun id(req: HttpRequest, res: HttpResponse): nullable Int do
		var id = req.param("id")
		if id == null then
			res.api_error("Missing URI param `id`", 400)
			return null
		end
		if not id.is_int then
			res.api_error("Bad type for URI parameter `id`, expected Int", 400)
			return null
		end
		return id.to_i
	end
end

redef class HttpResponse

	# Return a JSON error
	#
	# Format:
	# ~~~json
	# { message: "Not found", status: 404 }
	# ~~~
	fun api_error(message: String, status: Int) do
		var obj = new JsonObject
		obj["status"] = status
		obj["message"] = message
		json_error(obj, status)
	end
end
