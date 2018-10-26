# Make the build silent by default
V =

ifeq ($(strip $(V)),)
	E = @echo
	Q = @
else
	E = @\#
	Q =
endif
export E Q

uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')

PROGRAM=emb

DATS=version.dats

SRC=ansi.c basic.c bind.c buffer.c crypt.c display.c eval.c exec.c \
	file.c fileio.c ibmpc.c input.c isearch.c line.c lock.c main.c \
	pklock.c posix.c random.c region.c search.c spawn.c tcap.c \
	termio.c vmsvt.c vt52.c window.c word.c names.c globals.c \
	usage.c wrapper.c utf8.c util.c

OBJ=ansi.o basic.o bind.o buffer.o crypt.o display.o eval.o exec.o \
	file.o fileio.o ibmpc.o input.o isearch.o line.o lock.o main.o \
	pklock.o posix.o random.o region.o search.o spawn.o tcap.o \
	termio.o vmsvt.o vt52.o window.o word.o names.o globals.o version.dats.o \
	usage.o wrapper.o utf8.o util.o

HDR=ebind.h edef.h efunc.h epath.h estruct.h evar.h util.h version.h

ATS=patsopt
CC=gcc
WARNINGS=-Wall -Wno-unused-but-set-variable -Wno-misleading-indentation
CFLAGS=-O2 $(WARNINGS) -g -I$(PATSHOME) -I$(PATSHOME)/ccomp/runtime
ifeq ($(uname_S),Linux)
 DEFINES=-DAUTOCONF -DPOSIX -DUSG -D_XOPEN_SOURCE=600 -D_GNU_SOURCE
endif
ifeq ($(uname_S),FreeBSD)
 DEFINES=-DAUTOCONF -DPOSIX -DSYSV -D_FREEBSD_C_SOURCE -D_BSD_SOURCE -D_SVID_SOURCE -D_XOPEN_SOURCE=600
endif
ifeq ($(uname_S),Darwin)
 DEFINES=-DAUTOCONF -DPOSIX -DSYSV -D_DARWIN_C_SOURCE -D_BSD_SOURCE -D_SVID_SOURCE -D_XOPEN_SOURCE=600
endif
#DEFINES=-DAUTOCONF
#LIBS=-ltermcap			# BSD
LIBS=-lcurses			# SYSV
#LIBS=-ltermlib
#LIBS=-L/usr/lib/termcap -ltermcap
BINDIR=/usr/local/bin
LIBDIR=/usr/local/lib

$(PROGRAM): $(OBJ)
	$(E) "  LINK    " $@
	$(Q) $(CC) $(LDFLAGS) $(DEFINES) -o $@ $(OBJ) $(LIBS)

clean:
	$(E) "  CLEAN"
	$(Q) rm -f $(PROGRAM) core lintout makeout tags makefile.bak *.o *.dats.c

install: $(PROGRAM)
	cp $(PROGRAM) ${BINDIR}
	cp emacs.hlp ${LIBDIR}
	cp emacs.rc ${LIBDIR}/.emacsrc
	chmod 755 ${BINDIR}/$(PROGRAM)
	chmod 644 ${LIBDIR}/emacs.hlp ${LIBDIR}/.emacsrc

.c.o:
	$(E) "  CC      " $@
	$(Q) ${CC} ${CFLAGS} ${DEFINES} -c $*.c

%.dats.c: DATS/%.dats
	$(E) "  ATS     " $@
	$(Q) ${ATS} -o $@ -d $<
