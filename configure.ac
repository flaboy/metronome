AC_INIT(metronome, 1.0, ecae@shopex.cn)

config_args=$*
AC_SUBST(config_args)

AC_CONFIG_FILES([Makefile metronomed])

AC_CANONICAL_SYSTEM
AC_DEFINE_UNQUOTED(CPU_VENDOR_OS, "$target", CPU_VENDOR_OS)

AC_PREFIX_DEFAULT(/usr/local/)

dnl Programs

AC_PROG_CC
AC_PROG_INSTALL
AC_ERLANG_SUBST_ERTS_VER()
AC_OUTPUT()
