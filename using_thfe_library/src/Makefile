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
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $@ $^ $(TFHEFLAG)

example_communication.o: example_communication.c $(INCLUDE)/example_communication.h\
			 $(INCLUDE)/alice.h $(INCLUDE)/cloud.h\
			 $(INCLUDE)/homomorphic_functions.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $@ $^ $(TFHEFLAG)

alice.o: alice.c $(INCLUDE)/alice.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $@ $^ $(TFHEFLAG)

cloud.o: cloud.c $(INCLUDE)/cloud.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $@ $^ $(TFHEFLAG)

homomorphic_functions.o: homomorphic_functions.c $(INCLUDE)/homomorphic_functions.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $@ $^ $(TFHEFLAG)
						
clean:
	rm -f *.o test *~

help:
	@echo "Usage:"
	@echo -e "  make [all]\t\tRun the target test"
	@echo -e "  make aes\t\tBuild executable test"
	@echo -e "  make clean\t\tRemove all files produced by the compilation"
	@echo -e "  make help\t\tDisplay this help"

