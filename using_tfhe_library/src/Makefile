INCLUDE = ../include

# Compilation flags.
CC = gcc
CFLAGS = -std=c11 -Wall -Wextra
CPPFLAGS = -I$(INCLUDE)
DEBUGFLAGS = -g
TFHEFLAG  = -ltfhe-spqlios-fma

# Disable implicit rules
.SUFFIXES:

# Special rules and targets.
.PHONY: all clean help

# Rules and targets.
all: example_communication

example_communication: example_communication.o alice.o cloud.o homomorphic_functions.o
	$(CC) $(CFLAGS) -o $@ $^ $(TFHEFLAG)

example_communication.o: example_communication.c $(INCLUDE)/alice.h\
			 $(INCLUDE)/cloud.h $(INCLUDE)/homomorphic_functions.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $^ $(TFHEFLAG)

alice.o: alice.c $(INCLUDE)/alice.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $^ $(TFHEFLAG)

cloud.o: cloud.c $(INCLUDE)/cloud.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $^ $(TFHEFLAG)

homomorphic_functions.o: homomorphic_functions.c $(INCLUDE)/homomorphic_functions.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $^ $(TFHEFLAG)
						
clean:
	rm -f *.o test *~

help:
	@echo "Usage:"
	@echo "    make [all]\t\tRun the target build"
	@echo "    make build\t\tBuild executable"
	@echo "    make clean\t\tRemove all files produced by the compilation"
	@echo "    make help\t\tDisplay this help"
