TARFILES = Makefile core/scanner.mll core/parser.mly core/ast.mli

OBJS = parser.cmo scanner.cmo

scanner.ml : core/scanner.mll
	ocamllex core/scanner.mll

parser.ml parser.mli : core/parser.mly
	ocamlyacc core/parser.mly

%.cmo : %.ml
	ocamlc -c $<

%.cmi : %.mli
	ocamlc -c $<

.PHONY : clean
clean :
	rm -f core/parser.ml core/parser.mli core/scanner.ml *.cmo *.cmi

# Generated by ocamldep *.ml *.mli
parser.cmo: ast.cmi parser.cmi 
parser.cmx: ast.cmi parser.cmi 
scanner.cmo: parser.cmi 
scanner.cmx: parser.cmx 
parser.cmi: ast.cmi 