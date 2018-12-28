#define ATS_DYNLOADFLAG 0
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"

vtypedef tptr (a:t@ype, l:addr) = (a @ l | ptr l) // xxx need it?
typedef unicode_t = uint32

(*
 * utf8_to_unicode()
 *
 * Convert a UTF-8 sequence to its unicode value, and return the length of
 * the sequence in bytes.
 *
 * NOTE! Invalid UTF-8 will be converted to a one-byte sequence, so you can
 * either use it as-is (ie as Latin1) or you can check for invalid UTF-8
 * by checking for a length of 1 and a result > 127.
 *
 * NOTE 2! This does *not* verify things like minimality. So overlong forms
 * are happily accepted and decoded, as are the various "invalid values".
 *)
extern fun utf8_to_unicode {l:addr} {i,m:nat | i < m} (pf: !unicode_t@l | line: !strnptr(m), index: uint(i), len: uint(m), res: ptr(l)): uint = "ext#utf8_to_unicode"
implement utf8_to_unicode (pf | line, index, len, res) =
  let
    fun loop1 {m:nat} (c: char, mask: uint, bytes: uint(m)): [n:nat] (uint, uint(n)) =
      if ((($UN.cast{uint}{char} c) land mask) != 0U)
      then loop1 (c, mask >> 1, bytes + 1U)
      else (mask, bytes)

    fun loop2 {b,i,j,m:nat | i + b <= m} (line: !strnptr(m), index: uint(i), len: uint(m), bytes: uint(b), j: uint(j), value: uint): uint =
      if j >= bytes then
        value
      else
        let
          val c = line[index + j]
        in
          if (($UN.cast{uint}{char} c) land 0xc0U) != 0x80U
          then 1U
          else loop2 (line, index, len, bytes, j + 1U,
                      (value << 6) lor ($UN.cast{uint}{char} c land 0x3fU))
        end

    val c = line[index]
    val () = !res := $UN.cast{unicode_t}{char} c
  in

  (*
   * 0xxxxxxx is valid utf8
   * 10xxxxxx is invalid UTF-8, we assume it is Latin1
   *)
    if ($UN.cast{int}{char} c < 0xc0)
    then 1U else
      let
        (* Ok, it's 11xxxxxx, do a stupid decode *)
        val (mask, bytes') = loop1 (c, 0x20U, 0x2U)
      in
        (* Invalid? Do it as a single byte Latin1 *)
        if ((bytes' > 6) + (bytes' > len - index))
        then 1U
        else
          let
            (* Ok, do the bytes *)
            val value = loop2 (line, index, len, bytes', 1U,
                               ($UN.cast{uint}{char} c) land (mask - 1U))
            val () = !res := $UN.cast{unicode_t}{uint} value
          in
            bytes'
          end
      end
  end

fun reverse_string {m,n:nat | n < m} (utf8: !strnptr(m), bytes: int(n)): void =
  let
    fun loop {m,n,o:nat | n < m && o <= n} (utf8: !strnptr(m), bytes: int(n), index: int(o)): void =
      if index * 2 >= bytes then () else
        let
          val a = utf8[index]
          val b = utf8[bytes - index]
          val () = utf8[index] := b
          val () = utf8[bytes - index] := a
        in
          loop (utf8, bytes, index + 1)
        end
  in
    loop (utf8, bytes, 0)
  end

(*
 * unicode_to_utf8()
 *
 * Convert a unicode value to its canonical utf-8 sequence.
 *
 * NOTE! This does not check for - or care about - the "invalid" unicode
 * values.  Also, converting a utf-8 sequence to unicode and back does
 * *not* guarantee the same sequence, since this generates the shortest
 * possible sequence, while utf8_to_unicode() accepts both Latin1 and
 * overlong utf-8 sequences.
 *)
extern fun unicode_to_utf8 {m:int | m == 6} (c: uint, utf8: !strnptr(m)): uint = "ext#unicode_to_utf8"
implement unicode_to_utf8 {m}(c, utf8) =
  let
    fun loop {m,n:nat | m == 6 && n < m} (utf8: !strnptr(m), prefixi: uint, bytes: int(n), c: uint): [o:nat | o < m] (uint, int(o), uint) =
      let
        val () = utf8[bytes] := $UN.cast(0x80U + (c land 0x3fU))
        val bytes' = bytes + 1
        val prefixi' = prefixi >> 1
        val c' = c >> 6
        val () = assertloc (bytes' < 6)
      in
        if c' > prefixi'
        then (prefixi', bytes', c')
        else loop (utf8, prefixi', bytes', c')
      end

    val () = utf8[0] := $UN.cast c
  in
    if (c > 0x7fU)
    then
      let
        val (prefixi, bytes, c') = loop (utf8, 0x40U, 0, c)
        val () = utf8[bytes] := $UN.cast(c' - 2U * prefixi)
        val () = reverse_string(utf8, bytes)
      in
        $UN.cast{uint}{int}(bytes + 1)
      end
    else 1U
  end
