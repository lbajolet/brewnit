# Model for brewnit
module model

import db_binding

redef class Fermentable
	redef fun to_s do
		return "{class_name}: {name}, potential: {potential}, colour: {colour}"
	end
end

redef class Yeast
	redef fun to_s do
		var ret = new Buffer
		ret.append "Yeast {brand}, {name}"
		if not aliases.is_empty then ret.append "; Aliases: "
		ret.append(aliases.join(", "))
		return ret.to_s
	end
end
