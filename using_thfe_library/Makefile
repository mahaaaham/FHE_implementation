INCLUDE = include
SRC = src
EXE = test

# Disable built-in rules
.SUFFIXES:

# Special rules and targets
.PHONY: all build clean help

# Rules and targets
all: build

build:
	$(MAKE) -C $(SRC) all
	mv $(SRC)/test .

clean:
	rm -f $(EXE) 
	rm -f *~
	cd $(INCLUDE) && rm -f *~
	$(MAKE) -C $(SRC) clean

help:
	@echo "Usage:"
	@echo -e "  make [all]\t\tRun the target build"
	@echo -e "  make build\t\tBuild executable"
	@echo -e "  make clean\t\tRemove all files produced by the compilation"
	@echo -e "  make help\t\tDisplay this help"
