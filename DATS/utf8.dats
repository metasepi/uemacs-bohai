#define ATS_DYNLOADFLAG 0
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"

vtypedef tptr (a:t@ype, l:addr) = (a @ l | ptr l)
typedef unicode_t = uint32

extern fun utf8_to_unicode {l:addr}{i,m:nat | i < m} (pf: !unicode_t@l | line: !strnptr(m), index: int(i), len: int(m), res: ptr(l)): uint = "ext#utf8_to_unicode"
implement utf8_to_unicode (pf | line, index, len, res) = bytes where {
  val c = line[index]
  var bytes = 1U
  val () = !res := $UN.cast{unicode_t}{char} c
  val () = if (c >= $UN.cast{char}{int} 0xc0) then
    undefined() // xxx TODO
}

extern fun unicode_to_utf8 {m:nat | m > 0} (c: uint, utf8: !strnptr(m)): uint = "ext#unicode_to_utf8"
implement unicode_to_utf8 (c, utf8) = bytes where {
  var bytes = 1U
  val () = utf8[0] := $UN.cast c
  val () = if (c > 0x7fU) then
    undefined() // xxx TODO
}
