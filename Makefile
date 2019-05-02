# Makefile for rpncalc - a rudimentary emulation of a HP28S
#
# $Id: Makefile,v 1.12 1997/02/01 14:30:11 david Exp $

RM      = rm -f
CC      = gcc

CFLAGS=-g
ifneq (,$(findstring noopt,$(DEB_BUILD_OPTIONS)))
CFLAGS += -O0
else
CFLAGS += -O2
endif
CFLAGS += -Wall\
  -Wmissing-declarations -Wstrict-prototypes -Wmissing-prototypes\
  -Wshadow\
  -Wcast-align -Wcast-qual -Wcast-align\
  -Wbad-function-cast -Wpointer-arith\
  -Wwrite-strings -Wnested-externs\
  -Wformat

YFLAGS = -d
LFLAGS = -8 # -d

DEFS	= -DLOCALEDIR=\"$(LOCALEDIR)\" -DPACKAGE=\"rpncalc\" -DVERSION=\"1.36\"

LIBS    = -lm -lreadline

LDFLAGS =

BIN     = rpncalc

MAN     = $(BIN).1
MANTEMPL= $(MAN).sed

MAN_LINGUAS = de es
MANTEMPLS = rpncalc.de.1.sed rpncalc.en.1.sed rpncalc.es.1.sed
MANS = rpncalc.de.1 rpncalc.en.1 rpncalc.es.1

SRCS    = cmds.c stack.c utils.c
OBJS	= cmds.o stack.o utils.o gram.o scan.o
HEADER  = $(BIN).h cmds.h utils.h stack.h
CLEANFILES=gram.c scan.c $(man_MANS)

prefix  = $(DESTDIR)/usr
BINDIR  = $(prefix)/bin
MANDIR  = $(prefix)/share/man
MANDIR1 = $(MANDIR)/man1

LINGUAS = de es fi fr
LOCALEDIR = $(prefix)/share/locale

all:	rpncalc $(MAN) $(MANS)

$(BIN).c:

$(MAN): $(BIN) proto.ed
	sed -e "s/\\\$$Date.*\\\$$/`date +'%B %-d, %Y'`/g" $(MANTEMPL) > $(MAN)
	LANG=C ed -s - $(MAN) < proto.ed
	chmod 644 $(MAN)
	ln -fs rpncalc.en.1 rpncalc.1

$(MANS): proto.ed $(MANTEMPLS)
	unset LANG; \
	for lang in $(MAN_LINGUAS); do \
	  manpage=rpncalc.$$lang.1; \
	  LANG=$$lang_$$(echo $$lang|tr a-z A-Z) sed -e "s/\\\$$Date.*\\\$$/`date +'%B %-d, %Y'`/g" $$manpage.sed > $$manpage; \
	  ed -s - $$manpage < proto.ed; \
	  chmod 644 $$manpage; \
	done

.c.o:	$(HEADER) $(SRCS)
		$(CC) $(CFLAGS) $(DEFS) -c -o $@ $<

rpncalc:	$(HEADER) $(SRCS) $(OBJS) $(BIN).c
	$(CC) $(CFLAGS) $(LDFLAGS) $(DEFS) -o $(BIN) $(BIN).c $(OBJS) $(LIBS)

clean:
	$(RM) *.o *~ *.bak \#*\# errors core* a.out TAGS
	$(RM) $(BIN)

install:	$(MAN) $(BIN)
	install -d -g root -o root -m 755 $(BINDIR)
	install    -g root -o root -m 755 $(BIN) $(BINDIR)
	install -d -g root -o root -m 755 $(MANDIR1)
	install    -g root -o root -m 644 $(MAN) $(MANDIR1)

	for lang in `echo $(MAN_LINGUAS)|tr ' ' '\n'|grep -v en`; do \
	  mandir=$(MANDIR)/$$lang/man1; \
	  install -d -g root -o root -m 755 $$mandir; \
	  install    -g root -o root -m 644 rpncalc.$$lang.1 $$mandir/rpncalc.1; \
	done
	for lang in `echo $(LINGUAS)|tr ' ' '\n'|grep -v en`; do \
	  localedir=$(LOCALEDIR)/$$lang/LC_MESSAGES; \
	  install -d -g root -o root -m 755 $$localedir; \
	  install    -g root -o root -m 644 po/$$lang.gmo $$localedir/rpncalc.mo; \
	done

po:
	xgettext -F -o po/rpncalc.pot -k_ *.[cly]

rpncalc.c: cmds.h stack.h utils.h Makefile
cmds.c: cmds.h stack.h utils.h Makefile
stack.c: cmds.h stack.h utils.h Makefile
utils.c: utils.h Makefile
scan.l: cmds.h stack.h utils.h gram.h Makefile
gram.y: cmds.h stack.h utils.h Makefile

.PHONY:	po clean
