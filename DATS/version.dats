#define ATS_DYNLOADFLAG 0
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
#include "HATS/version.hats"

extern fun version (): void = "ext#version"
implement version () =
  println! (PROGRAM_NAME_LONG, " version ", VERSION)
