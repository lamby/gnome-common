# Macro to add for using GNU gettext.
# Ulrich Drepper <drepper@cygnus.com>, 1995.
#
# Modified to never use included libintl. 
# Owen Taylor <otaylor@redhat.com>, 12/15/1998
#
#
# This file can be copied and used freely without restrictions.  It can
# be used in projects which are not available under the GNU Public License
# but which still want to provide support for the GNU gettext functionality.
# Please note that the actual code is *not* freely available.
#

# serial 5

AC_DEFUN(AM_GNOME_WITH_NLS,
  [AC_MSG_CHECKING([whether NLS is requested])
    dnl Default is enabled NLS
    AC_ARG_ENABLE(nls,
      [  --disable-nls           do not use Native Language Support],
      USE_NLS=$enableval, USE_NLS=yes)
    AC_MSG_RESULT($USE_NLS)
    AC_SUBST(USE_NLS)

    USE_INCLUDED_LIBINTL=no

    dnl If we use NLS figure out what method
    if test "$USE_NLS" = "yes"; then
      AC_DEFINE(ENABLE_NLS)
#      AC_MSG_CHECKING([whether included gettext is requested])
#      AC_ARG_WITH(included-gettext,
#        [  --with-included-gettext use the GNU gettext library included here],
#        nls_cv_force_use_gnu_gettext=$withval,
#        nls_cv_force_use_gnu_gettext=no)
#      AC_MSG_RESULT($nls_cv_force_use_gnu_gettext)
      nls_cv_force_use_gnu_gettext="no"

      nls_cv_use_gnu_gettext="$nls_cv_force_use_gnu_gettext"
      if test "$nls_cv_force_use_gnu_gettext" != "yes"; then
        dnl User does not insist on using GNU NLS library.  Figure out what
        dnl to use.  If gettext or catgets are available (in this order) we
        dnl use this.  Else we have to fall back to GNU NLS library.
	dnl catgets is only used if permitted by option --with-catgets.
	nls_cv_header_intl=
	nls_cv_header_libgt=
	CATOBJEXT=NONE

	AC_CHECK_HEADER(libintl.h,
	  [AC_CACHE_CHECK([for gettext in libc], gt_cv_func_gettext_libc,
	    [AC_TRY_LINK([#include <libintl.h>], [return (int) gettext ("")],
	       gt_cv_func_gettext_libc=yes, gt_cv_func_gettext_libc=no)])

	   if test "$gt_cv_func_gettext_libc" != "yes"; then
	     AC_CHECK_LIB(intl, bindtextdomain,
	       [AC_CACHE_CHECK([for gettext in libintl],
		 gt_cv_func_gettext_libintl,
		 [AC_CHECK_LIB(intl, gettext,
		  gt_cv_func_gettext_libintl=yes,
		  gt_cv_func_gettext_libintl=no)],
		 gt_cv_func_gettext_libintl=no)])
	   fi

	   if test "$gt_cv_func_gettext_libc" = "yes" \
	      || test "$gt_cv_func_gettext_libintl" = "yes"; then
	      AC_DEFINE(HAVE_GETTEXT)
	      AM_PATH_PROG_WITH_TEST(MSGFMT, msgfmt,
		[test -z "`$ac_dir/$ac_word -h 2>&1 | grep 'dv '`"], no)dnl
	      if test "$MSGFMT" != "no"; then
		AC_CHECK_FUNCS(dcgettext)
		AC_PATH_PROG(GMSGFMT, gmsgfmt, $MSGFMT)
		AM_PATH_PROG_WITH_TEST(XGETTEXT, xgettext,
		  [test -z "`$ac_dir/$ac_word -h 2>&1 | grep '(HELP)'`"], :)
		AC_TRY_LINK(, [extern int _nl_msg_cat_cntr;
			       return _nl_msg_cat_cntr],
		  [CATOBJEXT=.gmo
		   DATADIRNAME=share],
		  [CATOBJEXT=.mo
		   DATADIRNAME=lib])
		INSTOBJEXT=.mo
	      fi
	    fi

	    # Added by Martin Baulig 12/15/98 for libc5 systems
	    if test "$gt_cv_func_gettext_libc" != "yes" \
	       && test "$gt_cv_func_gettext_libintl" = "yes"; then
	       INTLLIBS=-lintl
	       LIBS=`echo $LIBS | sed -e 's/-lintl//'`
	    fi
	])

        if test "$CATOBJEXT" = "NONE"; then
	  AC_MSG_CHECKING([whether catgets can be used])
	  AC_ARG_WITH(catgets,
	    [  --with-catgets          use catgets functions if available],
	    nls_cv_use_catgets=$withval, nls_cv_use_catgets=no)
	  AC_MSG_RESULT($nls_cv_use_catgets)

	  if test "$nls_cv_use_catgets" = "yes"; then
	    dnl No gettext in C library.  Try catgets next.
	    AC_CHECK_LIB(i, main)
	    AC_CHECK_FUNC(catgets,
	      [AC_DEFINE(HAVE_CATGETS)
	       INTLOBJS="\$(CATOBJS)"
	       AC_PATH_PROG(GENCAT, gencat, no)dnl
#	       if test "$GENCAT" != "no"; then
#		 AC_PATH_PROG(GMSGFMT, gmsgfmt, no)
#		 if test "$GMSGFMT" = "no"; then
#		   AM_PATH_PROG_WITH_TEST(GMSGFMT, msgfmt,
#		    [test -z "`$ac_dir/$ac_word -h 2>&1 | grep 'dv '`"], no)
#		 fi
#		 AM_PATH_PROG_WITH_TEST(XGETTEXT, xgettext,
#		   [test -z "`$ac_dir/$ac_word -h 2>&1 | grep '(HELP)'`"], :)
#		 USE_INCLUDED_LIBINTL=yes
#		 CATOBJEXT=.cat
#		 INSTOBJEXT=.cat
#		 DATADIRNAME=lib
#		 INTLDEPS='$(top_builddir)/intl/libintl.a'
#		 INTLLIBS=$INTLDEPS
#		 LIBS=`echo $LIBS | sed -e 's/-lintl//'`
#		 nls_cv_header_intl=intl/libintl.h
#		 nls_cv_header_libgt=intl/libgettext.h
#              fi
            ])
	  fi
        fi

        if test "$CATOBJEXT" = "NONE"; then
	  dnl Neither gettext nor catgets in included in the C library.
	  dnl Fall back on GNU gettext library.
	  nls_cv_use_gnu_gettext=yes
        fi
      fi

      if test "$nls_cv_use_gnu_gettext" != "yes"; then
        AC_DEFINE(ENABLE_NLS)
      else
         # Unset this variable since we use the non-zero value as a flag.
         CATOBJEXT=
#        dnl Mark actions used to generate GNU NLS library.
#        INTLOBJS="\$(GETTOBJS)"
#        AM_PATH_PROG_WITH_TEST(MSGFMT, msgfmt,
#	  [test -z "`$ac_dir/$ac_word -h 2>&1 | grep 'dv '`"], msgfmt)
#        AC_PATH_PROG(GMSGFMT, gmsgfmt, $MSGFMT)
#        AM_PATH_PROG_WITH_TEST(XGETTEXT, xgettext,
#	  [test -z "`$ac_dir/$ac_word -h 2>&1 | grep '(HELP)'`"], :)
#        AC_SUBST(MSGFMT)
#	USE_INCLUDED_LIBINTL=yes
#        CATOBJEXT=.gmo
#        INSTOBJEXT=.mo
#        DATADIRNAME=share
#	INTLDEPS='$(top_builddir)/intl/libintl.a'
#	INTLLIBS=$INTLDEPS
#	LIBS=`echo $LIBS | sed -e 's/-lintl//'`
#        nls_cv_header_intl=intl/libintl.h
#        nls_cv_header_libgt=intl/libgettext.h
      fi

      dnl Test whether we really found GNU xgettext.
      if test "$XGETTEXT" != ":"; then
	dnl If it is no GNU xgettext we define it as : so that the
	dnl Makefiles still can work.
	if $XGETTEXT --omit-header /dev/null 2> /dev/null; then
	  : ;
	else
	  AC_MSG_RESULT(
	    [found xgettext program is not GNU xgettext; ignore it])
	  XGETTEXT=":"
	fi
      fi

      # We need to process the po/ directory.
      POSUB=po
    else
      DATADIRNAME=share
      nls_cv_header_intl=intl/libintl.h
      nls_cv_header_libgt=intl/libgettext.h
    fi
    AC_LINK_FILES($nls_cv_header_libgt, $nls_cv_header_intl)
    AC_OUTPUT_COMMANDS(
     [case "$CONFIG_FILES" in *po/Makefile.in*)
        sed -e "/POTFILES =/r po/POTFILES" po/Makefile.in > po/Makefile
      esac])


#    # If this is used in GNU gettext we have to set USE_NLS to `yes'
#    # because some of the sources are only built for this goal.
#    if test "$PACKAGE" = gettext; then
#      USE_NLS=yes
#      USE_INCLUDED_LIBINTL=yes
#    fi

    dnl These rules are solely for the distribution goal.  While doing this
    dnl we only have to keep exactly one list of the available catalogs
    dnl in configure.in.
    for lang in $ALL_LINGUAS; do
      GMOFILES="$GMOFILES $lang.gmo"
      POFILES="$POFILES $lang.po"
    done

    dnl Make all variables we use known to autoconf.
    AC_SUBST(USE_INCLUDED_LIBINTL)
    AC_SUBST(CATALOGS)
    AC_SUBST(CATOBJEXT)
    AC_SUBST(DATADIRNAME)
    AC_SUBST(GMOFILES)
    AC_SUBST(INSTOBJEXT)
    AC_SUBST(INTLDEPS)
    AC_SUBST(INTLLIBS)
    AC_SUBST(INTLOBJS)
    AC_SUBST(POFILES)
    AC_SUBST(POSUB)
  ])

AC_DEFUN(AM_GNOME_GETTEXT,
  [AC_REQUIRE([AC_PROG_MAKE_SET])dnl
   AC_REQUIRE([AC_PROG_CC])dnl
   AC_REQUIRE([AC_PROG_RANLIB])dnl
   AC_REQUIRE([AC_ISC_POSIX])dnl
   AC_REQUIRE([AC_HEADER_STDC])dnl
   AC_REQUIRE([AC_C_CONST])dnl
   AC_REQUIRE([AC_C_INLINE])dnl
   AC_REQUIRE([AC_TYPE_OFF_T])dnl
   AC_REQUIRE([AC_TYPE_SIZE_T])dnl
   AC_REQUIRE([AC_FUNC_ALLOCA])dnl
   AC_REQUIRE([AC_FUNC_MMAP])dnl

   AC_CHECK_HEADERS([argz.h limits.h locale.h nl_types.h malloc.h string.h \
unistd.h sys/param.h])
   AC_CHECK_FUNCS([getcwd munmap putenv setenv setlocale strchr strcasecmp \
strdup __argz_count __argz_stringify __argz_next])

   if test "${ac_cv_func_stpcpy+set}" != "set"; then
     AC_CHECK_FUNCS(stpcpy)
   fi
   if test "${ac_cv_func_stpcpy}" = "yes"; then
     AC_DEFINE(HAVE_STPCPY)
   fi

   AM_LC_MESSAGES
   AM_GNOME_WITH_NLS

   if test "x$CATOBJEXT" != "x"; then
     if test "x$ALL_LINGUAS" = "x"; then
       LINGUAS=
     else
       AC_MSG_CHECKING(for catalogs to be installed)
       NEW_LINGUAS=
       if test "x$LINGUAS" = "x"; then
           LINGUAS=$ALL_LINGUAS
       fi
       for lang in $LINGUAS; do
         case "$ALL_LINGUAS" in
          *$lang*) NEW_LINGUAS="$NEW_LINGUAS $lang" ;;
         esac
       done
       LINGUAS=$NEW_LINGUAS
       AC_MSG_RESULT($LINGUAS)
     fi

     dnl Construct list of names of catalog files to be constructed.
     if test -n "$LINGUAS"; then
       for lang in $LINGUAS; do CATALOGS="$CATALOGS $lang$CATOBJEXT"; done
     fi
   fi

   dnl The reference to <locale.h> in the installed <libintl.h> file
   dnl must be resolved because we cannot expect the users of this
   dnl to define HAVE_LOCALE_H.
   if test $ac_cv_header_locale_h = yes; then
     INCLUDE_LOCALE_H="#include <locale.h>"
   else
     INCLUDE_LOCALE_H="\
/* The system does not provide the header <locale.h>.  Take care yourself.  */"
   fi
   AC_SUBST(INCLUDE_LOCALE_H)

   dnl Determine which catalog format we have (if any is needed)
   dnl For now we know about two different formats:
   dnl   Linux libc-5 and the normal X/Open format
   test -d intl || mkdir intl
   if test "$CATOBJEXT" = ".cat"; then
     AC_CHECK_HEADER(linux/version.h, msgformat=linux, msgformat=xopen)

     dnl Transform the SED scripts while copying because some dumb SEDs
     dnl cannot handle comments.
     sed -e '/^#/d' $srcdir/intl/$msgformat-msg.sed > intl/po2msg.sed
   fi
   dnl po2tbl.sed is always needed.
   sed -e '/^#.*[^\\]$/d' -e '/^#$/d' \
     $srcdir/intl/po2tbl.sed.in > intl/po2tbl.sed

   dnl In the intl/Makefile.in we have a special dependency which makes
   dnl only sense for gettext.  We comment this out for non-gettext
   dnl packages.
   if test "$PACKAGE" = "gettext"; then
     GT_NO="#NO#"
     GT_YES=
   else
     GT_NO=
     GT_YES="#YES#"
   fi
   AC_SUBST(GT_NO)
   AC_SUBST(GT_YES)

   dnl If the AC_CONFIG_AUX_DIR macro for autoconf is used we possibly
   dnl find the mkinstalldirs script in another subdir but ($top_srcdir).
   dnl Try to locate is.
   MKINSTALLDIRS=
   if test -n "$ac_aux_dir"; then
     MKINSTALLDIRS="$ac_aux_dir/mkinstalldirs"
   fi
   if test -z "$MKINSTALLDIRS"; then
     MKINSTALLDIRS="\$(top_srcdir)/mkinstalldirs"
   fi
   AC_SUBST(MKINSTALLDIRS)

   dnl *** For now the libtool support in intl/Makefile is not for real.
   l=
   AC_SUBST(l)

   dnl Generate list of files to be processed by xgettext which will
   dnl be included in po/Makefile.
   test -d po || mkdir po
   if test "x$srcdir" != "x."; then
     if test "x`echo $srcdir | sed 's@/.*@@'`" = "x"; then
       posrcprefix="$srcdir/"
     else
       posrcprefix="../$srcdir/"
     fi
   else
     posrcprefix="../"
   fi
   rm -f po/POTFILES
   sed -e "/^#/d" -e "/^\$/d" -e "s,.*,	$posrcprefix& \\\\," -e "\$s/\(.*\) \\\\/\1/" \
	< $srcdir/po/POTFILES.in > po/POTFILES
  ])


AC_DEFUN(AM_PATH_GNOME,
[dnl 
dnl Get the cflags and libraries from the gnome-config script
dnl
AC_ARG_WITH(gnome-prefix,[  --with-gnome-prefix=PFX   Prefix where GNOME is installed (optional)],
            gnome_config_prefix="$withval", gnome_config_prefix="")
AC_ARG_WITH(gnome-exec-prefix,[  --with-gnome-exec-prefix=PFX Exec prefix where GNOME is installed (optional)],
            gnome_config_exec_prefix="$withval", gnome_config_exec_prefix="")

  if test x$gnome_config_exec_prefix != x ; then
     gnome_config_args="$gnome_config_args --exec-prefix=$gnome_config_exec_prefix"
     if test x${GNOME_CONFIG+set} != xset ; then
        GNOME_CONFIG=$gnome_config_exec_prefix/bin/gnome-config
     fi
  fi
  if test x$gnome_config_prefix != x ; then
     gnome_config_args="$gnome_config_args --prefix=$gnome_config_prefix"
     if test x${GNOME_CONFIG+set} != xset ; then
        GNOME_CONFIG=$gnome_config_prefix/bin/gnome-config
     fi
  fi

  AC_PATH_PROG(GNOME_CONFIG, gnome-config, no)
  min_gnome_version=ifelse([$1], , 1.1.0, $1)

  AC_MSG_CHECKING(for GNOME - version >= $min_gnome_version)
  no_gnome=""
  if test "$GNOME_CONFIG" = "no" ; then
    no_gnome=yes
  else
    GNOME_CFLAGS="`$GNOME_CONFIG $gnome_config_args --cflags gnome`"
    GNOME_LIBS="`$GNOME_CONFIG $gnome_config_args --libs gnome`"
    GNOMEUI_CFLAGS="`$GNOME_CONFIG $gnome_config_args --cflags gnomeui`"
    GNOMEUI_LIBS="`$GNOME_CONFIG $gnome_config_args --libs gnomeui`"

    gnome_config_major_version=`$GNOME_CONFIG $gnome_config_args --version | \
           sed 's/[[^0-9]]*\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\)/\1/'`
    gnome_config_minor_version=`$GNOME_CONFIG $gnome_config_args --version | \
           sed 's/[[^0-9]]*\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\)/\2/'`
    gnome_config_micro_version=`$GNOME_CONFIG $gnome_config_args --version | \
           sed 's/[[^0-9]]*\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\)/\3/'`
    needed_major_version=`echo $min_gnome_version | \
           sed 's/[[^0-9]]*\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\)/\1/'`
    needed_minor_version=`echo $min_gnome_version | \
           sed 's/[[^0-9]]*\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\)/\2/'`
    needed_micro_version=`echo $min_gnome_version | \
           sed 's/[[^0-9]]*\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\)/\3/'`

    if test $gnome_config_major_version -lt $needed_major_version; then
	ifelse([$3], , :, [$3])
	no_gnome=yes
    elif test $gnome_config_major_version = $needed_major_version; then
	if test -n "$needed_minor_version" -a $gnome_config_minor_version -lt $needed_minor_version; then
		ifelse([$3], , :, [$3])
		no_gnome=yes
	elif test -n "$needed_minor_version" -a $gnome_config_minor_version = $needed_minor_version; then
		if test -n "$needed_micro_version" -a $gnome_config_micro_version -lt $needed_micro_version; then
			ifelse([$3], , :, [$3])
			no_gnome=yes
		fi
	fi
    fi
  fi
  AC_SUBST(GNOME_CFLAGS)
  AC_SUBST(GNOME_LIBS)
  AC_SUBST(GNOMEUI_CFLAGS)
  AC_SUBST(GNOMEUI_LIBS)

  if test "x$no_gnome" = x ; then
     AC_MSG_RESULT(yes)
     ifelse([$2], , :, [$2])     
  else
     AC_MSG_RESULT(no)
     if test "$GNOME_CONFIG" = "no" ; then
       echo "*** The gnome-config script installed by GNOME could not be found"
       echo "*** If GNOME was installed in PREFIX, make sure PREFIX/bin is in"
       echo "*** your path, or set the GNOME_CONFIG environment variable to the"
       echo "*** full path to gnome-config."
     else
	:
     fi
     GNOME_CFLAGS=""
     GNOME_LIBS=""
     ifelse([$3], , :, [$3])
  fi

  tmp_gnome_libdir=`$GNOME_CONFIG $gnome_config_args --libdir`
  if test -n "$4"; then
	AC_MSG_CHECKING([for additional GNOME modules])
  fi
  for module in $4 ""; do
	gnome_m4_notfound=no
	if test "$module" = zvt; then
	  ZVT_LIBS="`$GNOME_CONFIG $gnome_config_args --libs zvt`"
	  AC_SUBST(ZVT_LIBS)
	elif test "$module" = gtk; then
	  GTK_CFLAGS="`$GNOME_CONFIG $gnome_config_args --cflags gtk`"
	  GTK_LIBS="`$GNOME_CONFIG $gnome_config_args --libs gtk`"
	  AC_SUBST(GTK_CFLAGS)
	  AC_SUBST(GTK_LIBS)
	elif test "$module" = "glib"; then
	  GLIB_CFLAGS="`$GNOME_CONFIG $gnome_config_args --cflags glib`"
	  GLIB_LIBS="`$GNOME_CONFIG $gnome_config_args --libs glib`"
	  AC_SUBST(GLIB_CFLAGS)
	  AC_SUBST(GLIB_LIBS)
	elif test "$module" = "oaf"; then
	  OAF_CFLAGS="`$GNOME_CONFIG $gnome_config_args --cflags oaf`"
	  OAF_LIBS="`$GNOME_CONFIG $gnome_config_args --libs oaf`"
	  AC_SUBST(OAF_CFLAGS)
	  AC_SUBST(OAF_LIBS)
	elif test "$module" = "gnorba"; then
	  GNORBA_CFLAGS="`$GNOME_CONFIG $gnome_config_args --cflags gnorba`"
	  GNORBA_LIBS="`$GNOME_CONFIG $gnome_config_args --libs gnorba`"
	  AC_SUBST(GNORBA_CFLAGS)
	  AC_SUBST(GNORBA_LIBS)
	elif test -n "$module"; then
	  if $GNOME_CONFIG $gnome_config_args --cflags $module >/dev/null 2>&1; then
		tmp_bsnom=`echo $module | tr a-z A-Z`
		eval $tmp_bsnom'_CFLAGS'=\"`$GNOME_CONFIG $gnome_config_args --cflags $module`\"
		eval $tmp_bsnom'_LIBS'=\"`$GNOME_CONFIG $gnome_config_args --libs $module`\"
	  else
	  	AC_MSG_RESULT([*** $module library is not installed])
	  	ifelse([$3], , :, [$3])
		gnome_m4_notfound=yes
	  fi
	fi
	if test "$gnome_m4_notfound" = no; then
	  echo $ac_n " $module" 1>&6
	fi
  done
  if test -n "$4"; then
	AC_MSG_RESULT([])
  fi
])
