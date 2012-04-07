## -*- text -*- ##
# Master Makefile for the GNU readline library.
# Copyright (C) 1994-2004 Free Software Foundation, Inc.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
RL_LIBRARY_VERSION = 5.0
RL_LIBRARY_NAME = readline

PACKAGE = readline
VERSION = 5.0-rc1

PACKAGE_BUGREPORT = bug-readline@gnu.org
PACKAGE_NAME = readline
PACKAGE_STRING = readline 5.0-rc1
PACKAGE_VERSION = 5.0-rc1

srcdir = .
VPATH = .
top_srcdir = .
BUILD_DIR = /e/julia/julia/external/readline-5.0

INSTALL = /bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644

CC = gcc
RANLIB = ranlib
AR = ar
ARFLAGS = cr
RM = rm -f
CP = cp
MV = mv


SHELL = /bin/sh

prefix = /e/julia/julia/external/root
exec_prefix = ${prefix}

bindir = ${exec_prefix}/bin
libdir = ${exec_prefix}/lib
mandir = ${prefix}/man
includedir = ${prefix}/include
datadir = ${prefix}/share
localedir = $(datadir)/locale

infodir = ${prefix}/info

man3dir = $(mandir)/man3

# Support an alternate destination root directory for package building
DESTDIR =

# Programs to make tags files.
ETAGS = etags -tw
CTAGS = ctags -tw

CFLAGS = -g -O
LOCAL_CFLAGS =  -DRL_LIBRARY_VERSION='"$(RL_LIBRARY_VERSION)"'
CPPFLAGS = 

DEFS = -DHAVE_CONFIG_H
LOCAL_DEFS = 

TERMCAP_LIB = -lcurses

# For libraries which include headers from other libraries.
INCLUDES = -I. -I$(srcdir)

XCCFLAGS = $(DEFS) $(LOCAL_DEFS) $(CPPFLAGS) $(INCLUDES)
CCFLAGS = $(XCCFLAGS) $(LOCAL_CFLAGS) $(CFLAGS)

# could add -Werror here
GCC_LINT_FLAGS = -ansi -Wall -Wshadow -Wpointer-arith -Wcast-qual \
		 -Wwrite-strings -Wstrict-prototypes \
		 -Wmissing-prototypes -Wno-implicit -pedantic
GCC_LINT_CFLAGS = $(XCCFLAGS) $(GCC_LINT_FLAGS) -g -O 

.c.o:
	${RM} $@
	$(CC) -c $(CCFLAGS) $<

# The name of the main library target.
LIBRARY_NAME = libreadline.a
STATIC_LIBS = libreadline.a libhistory.a

# The C code source files for this library.
CSOURCES = $(srcdir)/readline.c $(srcdir)/funmap.c $(srcdir)/keymaps.c \
	   $(srcdir)/vi_mode.c $(srcdir)/parens.c $(srcdir)/rltty.c \
	   $(srcdir)/complete.c $(srcdir)/bind.c $(srcdir)/isearch.c \
	   $(srcdir)/display.c $(srcdir)/signals.c $(srcdir)/emacs_keymap.c \
	   $(srcdir)/vi_keymap.c $(srcdir)/util.c $(srcdir)/kill.c \
	   $(srcdir)/undo.c $(srcdir)/macro.c $(srcdir)/input.c \
	   $(srcdir)/callback.c $(srcdir)/terminal.c $(srcdir)/xmalloc.c \
	   $(srcdir)/history.c $(srcdir)/histsearch.c $(srcdir)/histexpand.c \
	   $(srcdir)/histfile.c $(srcdir)/nls.c $(srcdir)/search.c \
	   $(srcdir)/shell.c $(srcdir)/savestring.c $(srcdir)/tilde.c \
	   $(srcdir)/text.c $(srcdir)/misc.c $(srcdir)/compat.c \
	   $(srcdir)/mbutil.c

# The header files for this library.
HSOURCES = readline.h rldefs.h chardefs.h keymaps.h history.h histlib.h \
	   posixstat.h posixdir.h posixjmp.h tilde.h rlconf.h rltty.h \
	   ansi_stdlib.h tcap.h rlstdc.h xmalloc.h rlprivate.h rlshell.h \
	   rltypedefs.h rlmbutil.h

HISTOBJ = history.o histexpand.o histfile.o histsearch.o shell.o mbutil.o
TILDEOBJ = tilde.o
OBJECTS = readline.o vi_mode.o funmap.o keymaps.o parens.o search.o \
	  rltty.o complete.o bind.o isearch.o display.o signals.o \
	  util.o kill.o undo.o macro.o input.o callback.o terminal.o \
	  text.o nls.o misc.o compat.o xmalloc.o $(HISTOBJ) $(TILDEOBJ)

# The texinfo files which document this library.
DOCSOURCE = doc/rlman.texinfo doc/rltech.texinfo doc/rluser.texinfo
DOCOBJECT = doc/readline.dvi
DOCSUPPORT = doc/Makefile
DOCUMENTATION = $(DOCSOURCE) $(DOCOBJECT) $(DOCSUPPORT)

CREATED_MAKEFILES = Makefile doc/Makefile examples/Makefile shlib/Makefile
CREATED_CONFIGURE = config.status config.h config.cache config.log \
		    stamp-config stamp-h
CREATED_TAGS = TAGS tags

INSTALLED_HEADERS = readline.h chardefs.h keymaps.h history.h tilde.h \
		    rlstdc.h rlconf.h rltypedefs.h

##########################################################################
TARGETS = static 
INSTALL_TARGETS = install-static 

all: $(TARGETS)

everything: all examples

static: $(STATIC_LIBS)

libreadline.a: $(OBJECTS)
	$(RM) $@
	$(AR) $(ARFLAGS) $@ $(OBJECTS)
	-test -n "$(RANLIB)" && $(RANLIB) $@

libhistory.a: $(HISTOBJ) xmalloc.o
	$(RM) $@
	$(AR) $(ARFLAGS) $@ $(HISTOBJ) xmalloc.o
	-test -n "$(RANLIB)" && $(RANLIB) $@

# Since tilde.c is shared between readline and bash, make sure we compile
# it with the right flags when it's built as part of readline
tilde.o:	tilde.c
	rm -f $@
	$(CC) $(CCFLAGS) -DREADLINE_LIBRARY -c $(srcdir)/tilde.c

readline: $(OBJECTS) readline.h rldefs.h chardefs.h ./libreadline.a
	$(CC) $(CCFLAGS) -o $@ ./examples/rl.c ./libreadline.a ${TERMCAP_LIB}

lint:	force
	$(MAKE) $(MFLAGS) CCFLAGS='$(GCC_LINT_CFLAGS)' static

Makefile makefile: config.status $(srcdir)/Makefile.in
	CONFIG_FILES=Makefile CONFIG_HEADERS= $(SHELL) ./config.status

Makefiles makefiles: config.status $(srcdir)/Makefile.in
	@for mf in $(CREATED_MAKEFILES); do \
		CONFIG_FILES=$$mf CONFIG_HEADERS= $(SHELL) ./config.status ; \
	done

config.status: configure
	$(SHELL) ./config.status --recheck

config.h:	stamp-h

stamp-h: config.status $(srcdir)/config.h.in
	CONFIG_FILES= CONFIG_HEADERS=config.h ./config.status
	echo > $@

#$(srcdir)/configure: $(srcdir)/configure.in	## Comment-me-out in distribution
#	cd $(srcdir) && autoconf	## Comment-me-out in distribution


shared:	force
	-test -d shlib || mkdir shlib
	-( cd shlib ; ${MAKE} ${MFLAGS} all )

documentation: force
	-test -d doc || mkdir doc
	-( cd doc && $(MAKE) $(MFLAGS) )

examples: force
	-test -d examples || mkdir examples
	-(cd examples && ${MAKE} ${MFLAGS} all )

force:

install-headers: installdirs ${INSTALLED_HEADERS}
	for f in ${INSTALLED_HEADERS}; do \
		$(INSTALL_DATA) $(srcdir)/$$f $(DESTDIR)$(includedir)/readline ; \
	done

uninstall-headers:
	-test -n "$(includedir)" && cd $(DESTDIR)$(includedir)/readline && \
		${RM} ${INSTALLED_HEADERS}

maybe-uninstall-headers: uninstall-headers

install:	$(INSTALL_TARGETS)

install-static: installdirs $(STATIC_LIBS) install-headers install-doc
	-$(MV) $(DESTDIR)$(libdir)/libreadline.a $(DESTDIR)$(libdir)/libreadline.old
	$(INSTALL_DATA) libreadline.a $(DESTDIR)$(libdir)/libreadline.a
	-test -n "$(RANLIB)" && $(RANLIB) $(DESTDIR)$(libdir)/libreadline.a
	-$(MV) $(DESTDIR)$(libdir)/libhistory.a $(DESTDIR)$(libdir)/libhistory.old
	$(INSTALL_DATA) libhistory.a $(DESTDIR)$(libdir)/libhistory.a
	-test -n "$(RANLIB)" && $(RANLIB) $(DESTDIR)$(libdir)/libhistory.a

installdirs: $(srcdir)/support/mkinstalldirs
	-$(SHELL) $(srcdir)/support/mkinstalldirs $(DESTDIR)$(includedir) \
		$(DESTDIR)$(includedir)/readline $(DESTDIR)$(libdir) \
		$(DESTDIR)$(infodir) $(DESTDIR)$(man3dir)

uninstall: uninstall-headers uninstall-doc
	-test -n "$(DESTDIR)$(libdir)" && cd $(DESTDIR)$(libdir) && \
		${RM} libreadline.a libreadline.old libhistory.a libhistory.old $(SHARED_LIBS)
	-( cd shlib; ${MAKE} ${MFLAGS} DESTDIR=${DESTDIR} uninstall )

install-shared: installdirs install-headers shared install-doc
	-( cd shlib ; ${MAKE} ${MFLAGS} DESTDIR=${DESTDIR} install )
	
uninstall-shared: maybe-uninstall-headers
	-( cd shlib; ${MAKE} ${MFLAGS} DESTDIR=${DESTDIR} uninstall )

install-doc:	installdirs
	-( if test -d doc ; then \
		cd doc && \
		${MAKE} ${MFLAGS} infodir=$(infodir) DESTDIR=${DESTDIR} install; \
	  fi )

uninstall-doc:
	-( if test -d doc ; then \
		cd doc && \
		${MAKE} ${MFLAGS} infodir=$(infodir) DESTDIR=${DESTDIR} uninstall; \
	  fi )

TAGS:	force
	$(ETAGS) $(CSOURCES) $(HSOURCES)

tags:	force
	$(CTAGS) $(CSOURCES) $(HSOURCES)

clean:	force
	$(RM) $(OBJECTS) $(STATIC_LIBS)
	$(RM) readline readline.exe
	-( cd shlib && $(MAKE) $(MFLAGS) $@ )
	-( cd doc && $(MAKE) $(MFLAGS) $@ )
	-( cd examples && $(MAKE) $(MFLAGS) $@ )

mostlyclean: clean
	-( cd shlib && $(MAKE) $(MFLAGS) $@ )
	-( cd doc && $(MAKE) $(MFLAGS) $@ )
	-( cd examples && $(MAKE) $(MFLAGS) $@ )

distclean maintainer-clean: clean
	-( cd shlib && $(MAKE) $(MFLAGS) $@ )
	-( cd doc && $(MAKE) $(MFLAGS) $@ )
	-( cd examples && $(MAKE) $(MFLAGS) $@ )
	$(RM) Makefile
	$(RM) $(CREATED_CONFIGURE)
	$(RM) $(CREATED_TAGS)

info dvi:
	-( cd doc && $(MAKE) $(MFLAGS) $@ )

install-info:
check:
installcheck:

dist:   force
	@echo Readline distributions are created using $(srcdir)/support/mkdist.
	@echo Here is a sample of the necessary commands:
	@echo bash $(srcdir)/support/mkdist -m $(srcdir)/MANIFEST -s $(srcdir) -r $(RL_LIBRARY_NAME) $(RL_LIBRARY_VERSION)
	@echo tar cf $(RL_LIBRARY_NAME)-${RL_LIBRARY_VERSION}.tar ${RL_LIBRARY_NAME}-$(RL_LIBRARY_VERSION)
	@echo gzip $(RL_LIBRARY_NAME)-$(RL_LIBRARY_VERSION).tar

# Tell versions [3.59,3.63) of GNU make not to export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:

# Dependencies
bind.o: ansi_stdlib.h posixstat.h
bind.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
bind.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h rlstdc.h
bind.o: history.h
callback.o: rlconf.h
callback.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
callback.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h rlstdc.h
compat.o: rlstdc.h
complete.o: ansi_stdlib.h posixdir.h posixstat.h
complete.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
complete.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h rlstdc.h
display.o: ansi_stdlib.h posixstat.h
display.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
display.o: tcap.h
display.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
display.o: history.h rlstdc.h
funmap.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
funmap.o: rlconf.h ansi_stdlib.h rlstdc.h
funmap.o: ${BUILD_DIR}/config.h
histexpand.o: ansi_stdlib.h
histexpand.o: history.h histlib.h rlstdc.h rltypedefs.h
histexpand.o: ${BUILD_DIR}/config.h
histfile.o: ansi_stdlib.h
histfile.o: history.h histlib.h rlstdc.h rltypedefs.h
histfile.o: ${BUILD_DIR}/config.h
history.o: ansi_stdlib.h
history.o: history.h histlib.h rlstdc.h rltypedefs.h
history.o: ${BUILD_DIR}/config.h
histsearch.o: ansi_stdlib.h
histsearch.o: history.h histlib.h rlstdc.h rltypedefs.h
histsearch.o: ${BUILD_DIR}/config.h
input.o: ansi_stdlib.h
input.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
input.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h rlstdc.h
isearch.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
isearch.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
isearch.o: ansi_stdlib.h history.h rlstdc.h
keymaps.o: emacs_keymap.c vi_keymap.c
keymaps.o: keymaps.h rltypedefs.h chardefs.h rlconf.h ansi_stdlib.h
keymaps.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
keymaps.o: ${BUILD_DIR}/config.h rlstdc.h
kill.o: ansi_stdlib.h
kill.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
kill.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
kill.o: history.h rlstdc.h
macro.o: ansi_stdlib.h
macro.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
macro.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
macro.o: history.h rlstdc.h
mbutil.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
mbutil.o: readline.h keymaps.h rltypedefs.h chardefs.h rlstdc.h
misc.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
misc.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
misc.o: history.h rlstdc.h ansi_stdlib.h
nls.o: ansi_stdlib.h
nls.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
nls.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h  
nls.o: history.h rlstdc.h  
parens.o: rlconf.h
parens.o: ${BUILD_DIR}/config.h
parens.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h rlstdc.h
readline.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
readline.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
readline.o: history.h rlstdc.h
readline.o: posixstat.h ansi_stdlib.h posixjmp.h
rltty.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
rltty.o: rltty.h
rltty.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h rlstdc.h
search.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
search.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
search.o: ansi_stdlib.h history.h rlstdc.h
shell.o: ${BUILD_DIR}/config.h
shell.o: ansi_stdlib.h
signals.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
signals.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
signals.o: history.h rlstdc.h
terminal.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
terminal.o: tcap.h
terminal.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
terminal.o: history.h rlstdc.h
text.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
text.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
text.o: history.h rlstdc.h ansi_stdlib.h
tilde.o: ansi_stdlib.h
tilde.o: ${BUILD_DIR}/config.h
tilde.o: tilde.h
undo.o: ansi_stdlib.h
undo.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
undo.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
undo.o: history.h rlstdc.h
util.o: posixjmp.h ansi_stdlib.h
util.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
util.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h rlstdc.h
vi_mode.o: rldefs.h ${BUILD_DIR}/config.h rlconf.h
vi_mode.o: readline.h keymaps.h rltypedefs.h chardefs.h tilde.h
vi_mode.o: history.h ansi_stdlib.h rlstdc.h
xmalloc.o: ${BUILD_DIR}/config.h
xmalloc.o: ansi_stdlib.h

bind.o: rlshell.h
histfile.o: rlshell.h
nls.o: rlshell.h
readline.o: rlshell.h
shell.o: rlshell.h
terminal.o: rlshell.h
histexpand.o: rlshell.h

bind.o: rlprivate.h
callback.o: rlprivate.h
complete.o: rlprivate.h
display.o: rlprivate.h
input.o: rlprivate.h
isearch.o: rlprivate.h
kill.o: rlprivate.h
macro.o: rlprivate.h
mbutil.o: rlprivate.h
misc.o: rlprivate.h
nls.o: rlprivate.h   
parens.o: rlprivate.h
readline.o: rlprivate.h
rltty.o: rlprivate.h 
search.o: rlprivate.h
signals.o: rlprivate.h
terminal.o: rlprivate.h
text.o: rlprivate.h
undo.o: rlprivate.h
util.o: rlprivate.h
vi_mode.o: rlprivate.h

bind.o: xmalloc.h
complete.o: xmalloc.h
display.o: xmalloc.h
funmap.o: xmalloc.h
histexpand.o: xmalloc.h
histfile.o: xmalloc.h
history.o: xmalloc.h
input.o: xmalloc.h
isearch.o: xmalloc.h
keymaps.o: xmalloc.h
kill.o: xmalloc.h
macro.o: xmalloc.h
mbutil.o: xmalloc.h
misc.o: xmalloc.h
readline.o: xmalloc.h
savestring.o: xmalloc.h
search.o: xmalloc.h
shell.o: xmalloc.h
terminal.o: xmalloc.h
text.o: xmalloc.h
tilde.o: xmalloc.h
undo.o: xmalloc.h
util.o: xmalloc.h
vi_mode.o: xmalloc.h
xmalloc.o: xmalloc.h

complete.o: rlmbutil.h
display.o: rlmbutil.h
histexpand.o: rlmbutil.h
input.o: rlmbutil.h    
isearch.o: rlmbutil.h
mbutil.o: rlmbutil.h
misc.o: rlmbutil.h
readline.o: rlmbutil.h
search.o: rlmbutil.h 
text.o: rlmbutil.h
vi_mode.o: rlmbutil.h

bind.o: $(srcdir)/bind.c
callback.o: $(srcdir)/callback.c
compat.o: $(srcdir)/compat.c
complete.o: $(srcdir)/complete.c
display.o: $(srcdir)/display.c
funmap.o: $(srcdir)/funmap.c
input.o: $(srcdir)/input.c
isearch.o: $(srcdir)/isearch.c
keymaps.o: $(srcdir)/keymaps.c $(srcdir)/emacs_keymap.c $(srcdir)/vi_keymap.c
kill.o: $(srcdir)/kill.c
macro.o: $(srcdir)/macro.c
mbutil.o: $(srcdir)/mbutil.c
misc.o: $(srcdir)/misc.c
nls.o: $(srcdir)/nls.c
parens.o: $(srcdir)/parens.c
readline.o: $(srcdir)/readline.c
rltty.o: $(srcdir)/rltty.c
savestring.o: $(srcdir)/savestring.c
search.o: $(srcdir)/search.c
shell.o: $(srcdir)/shell.c
signals.o: $(srcdir)/signals.c
terminal.o: $(srcdir)/terminal.c
text.o: $(srcdir)/text.c
tilde.o: $(srcdir)/tilde.c
undo.o: $(srcdir)/undo.c
util.o: $(srcdir)/util.c
vi_mode.o: $(srcdir)/vi_mode.c
xmalloc.o: $(srcdir)/xmalloc.c

histexpand.o: $(srcdir)/histexpand.c
histfile.o: $(srcdir)/histfile.c
history.o: $(srcdir)/history.c
histsearch.o: $(srcdir)/histsearch.c

bind.o: bind.c
callback.o: callback.c
compat.o: compat.c
complete.o: complete.c
display.o: display.c
funmap.o: funmap.c
input.o: input.c
isearch.o: isearch.c
keymaps.o: keymaps.c emacs_keymap.c vi_keymap.c
kill.o: kill.c
macro.o: macro.c
mbutil.o: mbutil.c
misc.o: misc.c
nls.o: nls.c
parens.o: parens.c
readline.o: readline.c
rltty.o: rltty.c
savestring.o: savestring.c
search.o: search.c
shell.o: shell.c
signals.o: signals.c
terminal.o: terminal.c
text.o: text.c
tilde.o: tilde.c
undo.o: undo.c
util.o: util.c
vi_mode.o: vi_mode.c
xmalloc.o: xmalloc.c

histexpand.o: histexpand.c
histfile.o: histfile.c
history.o: history.c
histsearch.o: histsearch.c
