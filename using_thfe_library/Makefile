DATA = data
INCLUDE = include
SRC = src
EXE = example_communication

# Disable built-in rules
.SUFFIXES:

# Special rules and targets
.PHONY: all build clean help

# Rules and targets
all: build

build:
	$(MAKE) -C $(SRC) all
	mv $(SRC)/$(EXE) .

clean:
	rm -f $(EXE) 
	rm -f *~
	cd $(INCLUDE) && rm -f *~
	cd $(DATA) && rm -f *.data *.key *~
	$(MAKE) -C $(SRC) clean

help:
	@echo "Usage:"
	@echo "    make [all]\t\tRun the target build"
	@echo "    make build\t\tBuild executable"
	@echo "    make clean\t\tRemove all files produced by the compilation"
	@echo "    make help\t\tDisplay this help"
