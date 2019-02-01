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
all: test

test: generating_saving_params.c 
	$(CC) $(CFLAGS) -o $@ $^ $(TFHEFLAG)

clean:
	rm -f *.o test *~

help:
	@echo "Usage:"
	@echo -e "  make [all]\t\tRun the target test"
	@echo -e "  make aes\t\tBuild executable test"
	@echo -e "  make clean\t\tRemove all files produced by the compilation"
	@echo -e "  make help\t\tDisplay this help"

