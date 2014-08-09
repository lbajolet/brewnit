import beer_lexer
import beer_parser

redef class Parser_beer

	var file: String

	init(file: String)
	do
		if not file.file_exists then
			print "Unable to locate file {file}"
			exit(-1)
		end
		self.file = file
	end

	fun parse_file: Node
	do
		var fs = new IFStream.open(file)
		var s = fs.read_all
		var l = new Lexer_beer(s)
		var tks = l.lex
		tokens.add_all tks
		return parse
	end
end
