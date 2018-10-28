#define ATS_DYNLOADFLAG 0
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

// fun mkstemp {n:int | n >= 6} (template: !strnptr(n)): int = "mac#%"
extern fun c_mkstemp (template: string): int = "mac#mkstemp"
// fun malloc_gc {n:int} (bsz: size_t (n)) :<!wrt> [l:agz] (b0ytes n @ l, mfree_gc_v (l) | ptr l)
extern fun c_malloc (size: size_t): ptr = "mac#malloc"

extern fun xmkstemp (template: string): int = "ext#xmkstemp"
implement xmkstemp (template) = fd where {
  val fd = c_mkstemp template
  val () = assertloc (fd >= 0)
}

extern fun xmalloc (size: size_t): ptr = "ext#xmalloc"
implement xmalloc (size) = ret where {
  val ret = c_malloc size
  val () = assertloc (ret > the_null_ptr)
}
