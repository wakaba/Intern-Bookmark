all:

# ------ Setup ------

WGET = wget
GIT = git

deps: git-submodules pmbp-install

git-submodules:
	$(GIT) submodule update --init

local/bin/pmbp.pl:
	mkdir -p local/bin
	$(WGET) -O $@ https://github.com/wakaba/perl-setupenv/raw/master/bin/pmbp.pl

pmbp-upgrade: local/bin/pmbp.pl
	perl local/bin/pmbp.pl --update-pmbp-pl

pmbp-update: pmbp-upgrade
	perl local/bin/pmbp.pl --update \
	    --write-makefile-pl=Makefile.PL

pmbp-install: pmbp-upgrade
	perl local/bin/pmbp.pl --install \
            --create-perl-command-shortcut perl \
            --create-perl-command-shortcut plackup \
            --create-perl-command-shortcut prove \
            --create-perl-command-shortcut local/bin/which \
            --add-to-gitignore /perl \
            --add-to-gitignore /prove \
            --add-to-gitignore /plackup

# ------ Tests ------

PROVE = ./prove

test: test-deps test-main

test-deps: deps
	sh t/setup-db.sh

test-main:
	$(PROVE) t/*.t t/app/*.t
