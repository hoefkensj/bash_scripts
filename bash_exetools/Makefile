NAME=bash_exetools
SRC=src/${NAME}
DSTOPT=/opt/local/scripts
BINOPT=/opt/local/shell
DSTUSR=/usr/local/scripts
BINUSR=/usr/local/bin

T1=findexe
T2=lsexe

installcom:
	chmod 775   $(SRC)/$(T1).sh
	chmod 775   $(SRC)/$(T2).sh

install-opt:installcom
	install -vD $(SRC)/$(T1).sh $(DSTOPT)/$(NAME)/$(T1).sh
	install -vD $(SRC)/$(T2).sh $(DSTOPT)/$(NAME)/$(T2).sh
	ln -s $(DSTOPT)/$(NAME)/$(T1).sh $(BINOPT)/$(T1)
	ln -s $(DSTOPT)/$(NAME)/$(T2).sh $(BINOPT)/$(T2)
install-usr:installcom
	install -vD $(SRC)/$(T1).sh $(DSTUSR)/$(NAME)/$(T1).sh
	install -vD $(SRC)/$(T2).sh $(DSTUSR)/$(NAME)/$(T2).sh
	ln -s $(DSTUSR)/$(NAME)/$(T1).sh $(BINUSR)/$(T1)
	ln -s $(DSTUSR)/$(NAME)/$(T2).sh $(BINUSR)/$(T2)
uninstall-usr:
	rm -rvf $(DSTUSR)/$(NAME)/$(T1).sh
	rm -rvf $(BINUSR)/$(T1)
	rm -rvf $(DSTUSR)/$(NAME)/$(T2).sh
	rm -rvf $(BINUSR)/$(T2)
uninstall-opt:
	rm -rvf $(DSTOPT)/$(NAME)/$(T1).sh
	rm -rvf $(BINOPT)/$(T1)
	rm -rvf $(DSTOPT)/$(NAME)/$(T2).sh
	rm -rvf $(BINOPT)/$(T2)

install:install-usr
uninstall:uninstall-usr