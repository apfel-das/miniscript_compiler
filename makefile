all: flex bison compiler print_init

	
flex: 
	@flex ms_lex.l

	

	
bison:
	@bison -d -v -r all ms_parser.y

	
	
compiler:
	@gcc -o ms_compiler ms_parser.tab.c lex.yy.c cgen.c -lfl

	

	
clean:
	@rm -f  ms_parser.tab.c lex.yy.c
	@rm -f  ms_parser.tab.h
	@rm -f *.output 
	@rm -f ms_compiler

	
	
print_init: 
	@echo "MiniScript compiler created!"


	