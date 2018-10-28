#define ATS_DYNLOADFLAG 0
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

extern fun xmkstemp (template: string): int = "ext#xmkstemp"
implement xmkstemp (template) =
  undefined()

extern fun xmalloc (size: size_t) : ptr = "ext#xmalloc"
implement xmalloc (size) =
  undefined()
