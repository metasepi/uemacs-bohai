#define ATS_DYNLOADFLAG 0
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

vtypedef tptr (a:t@ype, l:addr) = (a @ l | ptr l)
typedef unicode_t = uint32

extern fun utf8_to_unicode {l:addr} (line: !strptr, index: uint, len: uint, res: !tptr(unicode_t, l)): uint = "ext#utf8_to_unicode"
implement utf8_to_unicode (line, index, len, res) =
  undefined()

extern fun unicode_to_utf8(c: uint, utf8: !strptr): uint = "ext#unicode_to_utf8"
implement unicode_to_utf8 (c, utf8) =
  undefined()
