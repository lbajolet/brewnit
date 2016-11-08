import parser
import nitcc_runtime

class LiteralVisitor
	super Visitor

	redef fun visit(n) do n.accept_literal_visitor(self)
end

redef class Node

	fun accept_literal_visitor(v: LiteralVisitor) do visit_children(v)
end

redef class Nstring
	var value: String is noinit

	redef fun accept_literal_visitor(v) do value = text.substring(1, text.length - 2)
end

redef class Nnumber
	var value: Float is noinit

	redef fun accept_literal_visitor(v) do value = text.to_f
end

