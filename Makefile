# Copyright (c) 1994, 1995 James Clark
# See the file COPYING for copying permission.

prefix=/opt/local
exec_prefix=$(prefix)
# Where to install the binaries
bindir=$(exec_prefix)/bin
INSTALL=cp
# You might want to uncomment this on BSD systems
#INSTALL=install

# If you use gcc, then you must have at least version 2.6.1 and
# you must use -fno-implicit-templates
# and -O (or any optimization level >= 1).
# c++ is a front-end for gcc which takes care of linking with -lstdc++
CXX=c++ -fno-implicit-templates -O2
WARN=#-Wall -Wno-reorder -Wwrite-strings -Wpointer-arith -Wnested-externs -Woverloaded-virtual -Wbad-function-cast
# Executables will be *very* large if you use -g.
DEBUG=
# Add -DSP_HAVE_BOOL if you have the bool type.
# Add -DSP_ANSI_CLASS_INST for ANSI style explicit class template instantiation.
# Add -DSP_MULTI_BYTE for multi-byte support.
# Add -DSP_HAVE_LOCALE if you have setlocale().
# Add -DSP_HAVE_GETTEXT if you gettext() and friends (eg Solaris 2.3).
# Add -DSP_HAVE_SOCKET if you have sockets and you want support for HTTP
# Add -DSP_MUTEX_PTHREADS if you want to use pthreads for mutexes
# Add -DSP_DECLARE_H_ERRNO if you have sockets, but netdb.h doesn't declare h_errno
#   (reportedly HPUX, Ultrix and Solaris 5.4)
# Add -DSGML_CATALOG_FILES_DEFAULT=\"/usr/local/lib/sgml/catalog\"
#   (for example) to change the value used if the SGML_CATALOG_FILES
#   environment variable is unset.  SP now automatically searches for a file
#   called "catalog" in the same directory as the document entity.
# Add -Dsig_atomic_t=int on SunOS 4.1.x with g++ (or any other platform
#  which doesn't appropriately define sig_atomic_t).
# Add -DJADE_MIF to include the Jade MIF backend
XDEFINES=
DEFINES=-DSP_HAVE_BOOL -DSP_ANSI_CLASS_INST -DSP_MULTI_BYTE $(XDEFINES)
CXXFLAGS=-ansi $(DEBUG) $(WARN)
# Flag to pass to CXX to make it output list of dependencies as a Makefile.
CXXDEPGENFLAGS=-MM
LDFLAGS=
CC=gcc
CFLAGS=-O $(DEBUG)
# Missing library functions
# Uncomment these if your C++ system doesn't provide them.
LIBOBJS=#strerror.o memmove.o
# iostreams are required
# If you defined SP_HAVE_SOCKET, add any libraries that are needed for sockets
# -lsocket -lnsl needed on Solaris 2.x
# -lnsl on SunOS 4.1.3
XLIBS=#-lsocket -lnsl
# -L/usr/local/lib may be needed on the RS/6000
LIBS=-lm $(XLIBS)
# If you're building in another directory, copy or link this Makefile
# to the build directory, and set srcdir to point to the source directory.
srcdir=.
AR=ar
RANLIB=:
# Uncomment this for SunOS 4.1.3 or FreeBSD
# (and probably other BSD flavor systems as well)
#RANLIB=ranlib
M4=m4
# perl is needed if you change or add messages
PERL=perl
# Suffix for executables.
EXE=
# Uncomment this for OS/2.
#EXE=.exe

SP_LIBDIRS=lib $(XLIBDIRS)
SP_PROGDIRS=nsgmls spam sgmlnorm spent sx $(XPROGDIRS)
JADE_LIBDIRS=grove spgrove style
JADE_PROGDIRS=jade
LIBDIRS=$(SP_LIBDIRS) $(JADE_LIBDIRS)
PROGDIRS=$(SP_PROGDIRS) $(JADE_PROGDIRS)
sp_dodirs=$(SP_LIBDIRS) $(SP_PROGDIRS)
jade_dodirs=$(LIBDIRS) $(PROGDIRS)

PURIFYFLAGS=
PURIFY=purify $(PURIFYFLAGS) -g++=yes -collector=`dirname \`gcc -print-libgcc-file-name\``/ld

MDEFINES='CXX=$(CXX)' 'CC=$(CC)' 'LIBOBJS=$(LIBOBJS)' 'CXXFLAGS=$(CXXFLAGS)' \
 'CFLAGS=$(CFLAGS)' 'LDFLAGS=$(LDFLAGS)' 'DEFINES=$(DEFINES)' \
 'srcdir=$(srcdir)' 'AR=$(AR)' 'RANLIB=$(RANLIB)' \
 'M4=$(M4)' 'PERL=$(PERL)' 'LIBS=$(LIBS)' 'PURIFY=$(PURIFY)' \
 'PIC_FLAG=$(PIC_FLAG)' 'XPROGDIRS=$(XPROGDIRS)' 'XLIBDIRS=$(XLIBDIRS)' \
 'libMakefile=$(libMakefile)' 'EXE=$(EXE)' 'bindir=$(bindir)' \
 'INSTALL=$(INSTALL)' CXXDEPGENFLAGS='$(CXXDEPGENFLAGS)'

# Automatic template instantiation can cause compilers to generate
# various extra files; the clean target won't delete these.
TARGETS=all install depend gen clean pure
libMakefile=Makefile.lib
do=all

$(TARGETS): FORCE
	@if test -d $(srcdir)/jade; \
	then $(MAKE) -f $(srcdir)/Makefile $(MDEFINES) do=$@ $(jade_dodirs); \
	else $(MAKE) -f $(srcdir)/Makefile $(MDEFINES) do=$@ $(sp_dodirs); \
	fi

$(LIBDIRS): FORCE
	@if test $(srcdir) = .; \
	then srcdir=.; \
	else srcdir=`cd $(srcdir); pwd`/$@; \
	fi; \
	test -d $@ || mkdir $@; \
	cd $@; \
	test -f $$srcdir/Makefile.dep || touch $$srcdir/Makefile.dep; \
	$(MAKE) $(MDEFINES) srcdir=$$srcdir VPATH=$$srcdir \
		-f $$srcdir/../Makefile.comm -f $$srcdir/Makefile.sub \
	        -f $$srcdir/../$(libMakefile) -f $$srcdir/Makefile.dep $(do)

$(PROGDIRS): FORCE
	@if test $(srcdir) = .; \
	then srcdir=.; \
	else srcdir=`cd $(srcdir); pwd`/$@; \
	fi; \
	test -d $@ || mkdir $@; \
	cd $@; \
	test -f $$srcdir/Makefile.dep || touch $$srcdir/Makefile.dep; \
	$(MAKE) $(MDEFINES) srcdir=$$srcdir VPATH=$$srcdir \
		-f $$srcdir/../Makefile.comm -f $$srcdir/Makefile.sub \
	        -f $$srcdir/../Makefile.prog -f $$srcdir/Makefile.dep $(do)

$(PROGDIRS): lib

# GNU tar
TAR=tar

dist: FORCE
	version=`cat VERSION`; \
	rm -fr sp-$$version; \
	mkdir sp-$$version; \
	cd sp-$$version; \
	ln -s ../* .; \
	rm sp-$$version; \
	rm SP.mak ; \
	sed -e '/^   CD /s/[A-Z]:\\.*\\//' -e "s/$$/`echo @ | tr @ \\\\015`/" \
	  ../SP.mak >SP.mak; \
	cd ..; \
	ln -s `pwd` sp-$$version; \
	$(TAR) -c -f sp-$$version.tar.gz -h -z \
	  `sed -e "s|.*|sp-$$version/&|" FILES`; \
	rm -fr sp-$$version

FORCE:
