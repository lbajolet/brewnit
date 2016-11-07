import beer_lexer
import beer_parser

fun parse_beer_file(file: String): nullable Node do
	var p = file.to_path
	if not p.exists then
		print "File '{file}' not found."
		return null
	end
	var s = p.read_all
	var l = new Lexer_beer(s)
	var parser = new Parser_beer
	var tks = l.lex
	parser.tokens.add_all tks
	return parser.parse
end
