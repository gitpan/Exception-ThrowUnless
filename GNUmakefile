test:

SHELL:=/bin/bash

MODS:=$(shell find lib -name '*.pm')
tags: $(MODS)
	ctags  $(MODS)

test: Makefile MANIFEST
	@echo make.out:1:results
	make -f Makefile $@ > make.out 2>&1 TEST_VERBOSE=1

dist: Makefile MANIFEST
	cvs commit
	make -f Makefile $@

%: Makefile MANIFEST
	make -f Makefile $@ > >( tee make.out ) 2>&1

PMS := $(shell find lib -name '*.pm')
GNUmakefile Makefile.PL $(PMS):
	$(error it should exist!)

Makefile: Makefile.PL MANIFEST $(PMS)
	perl Makefile.PL
	test -e Makefile

MANIFEST:
	cvsfiles -p | xargs lsfiles | sort > $@.new
	mv $@.new $@

