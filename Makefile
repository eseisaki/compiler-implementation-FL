CC=gcc
LIBS=-lfl
DEPS=cgen.h FL_parser.tab.h


%.o: %.c $(DEPS)
	$(CC) -c -o $@ $<
	
all: FL_run FL_scan
	@echo "For lexical analyzer type: 		  make scan file='filename'"
	@echo "For syntax analyzer and translation type: make test file='filename'"
	@echo "To remove all output files type: 	  make clean"

FL_run: FL_run.o lex.yy.o FL_parser.tab.o cgen.o
	$(CC)  -o $@ $+ $(LIBS)

FL_scan:FL_scan.o lex.yy.o FL_parser.tab.o cgen.o
	$(CC)  -o $@ $+ $(LIBS)

FL_parser.tab.c FL_parser.tab.h: FL_parser.y
	bison -d -v -r all FL_parser.y

lex.yy.c: FL_lex.l FL_parser.tab.h
	flex FL_lex.l
	
test: FL_run
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@echo "SYNTAX analyzer and TRANSLATION of example file"  $(file).c
	./FL_run<  $(file).fl >  $(file).c
	gcc -Wall -std=c99 -o test  $(file).c
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@echo "RUN example file"  $(file).c
	./test
	
test_run:
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@echo "RUN example file"  $(file).c
	./test

	
scan:FL_scan
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@echo "LEXICAL analyzer of example file"  $(file).fl
	./FL_scan<  $(file).fl

.PHONY:all test scan

clean:
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@echo "remove all output files"
	rm FL_run FL_scan *.o FL_parser.tab.c FL_parser.tab.h lex.yy.c 

