PREFIX ?= $(HOME)/.local

.PHONY: test run menu install uninstall doctor list

test:
	./tests/run.sh

run menu:
	./animated.sh

list:
	./animated.sh list

doctor:
	./animated.sh doctor

install:
	./install.sh $(PREFIX)

uninstall:
	./uninstall.sh $(PREFIX)
