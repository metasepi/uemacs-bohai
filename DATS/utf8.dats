#define ATS_DYNLOADFLAG 0
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"

vtypedef tptr (a:t@ype, l:addr) = (a @ l | ptr l)
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
extern fun utf8_to_unicode {l1,l2:addr} {i,m:nat | i < m} (pf: !unicode_t@l1 | line: !strnptr(l2,m), index: int(i), len: int(m), res: ptr(l1)): uint = "ext#utf8_to_unicode"
implement utf8_to_unicode (pf | line, index, len, res) =
  let
    fun loop1 (c: char, mask: uint, bytes: uint): (uint, uint) =
      if ((($UN.cast{uint}{char} c) land mask) != 0U)
      then loop1 (c, mask >> 1, bytes + 1U)
      else (mask, bytes)

    fun loop2 {m:nat} (line: !strnptr(m), i: int, len: int(m), bytes: uint, value: uint): uint =
      undefined()
      (* (* xxx TODO: Should implement following: *)
	for (i = 1; i < bytes; i++) {
		c = line[i];
		if ((c & 0xc0) != 0x80)
			return 1;
		value = (value << 6) | (c & 0x3f);
	}
       *)


    val c = line[index]
    val () = !res := $UN.cast{unicode_t}{char} c
  in

  (*
   * 0xxxxxxx is valid utf8
   * 10xxxxxx is invalid UTF-8, we assume it is Latin1
   *)
    if ($UN.cast{int}{char} c < 0xc0)
    then 1U
    else
      let
        (* Ok, it's 11xxxxxx, do a stupid decode *)
        val (mask, bytes'') = loop1 (c, 0x20U, 0x2U)
      in
        (* Invalid? Do it as a single byte Latin1 *)
        if (bytes'' > 6 || bytes'' > len)
        then 1U
        else
          let
            (* Ok, do the bytes *)
            val value = loop2 (line, 1, len, bytes'',
                               ($UN.cast{uint}{char} c) land (mask - 1U))
            val () = !res := $UN.cast{unicode_t}{uint} value
          in
            bytes''
          end
      end
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
extern fun unicode_to_utf8 {m:nat | m > 0} (c: uint, utf8: !strnptr(m)): uint = "ext#unicode_to_utf8"
implement unicode_to_utf8 (c, utf8) = bytes where {
  val () = utf8[0] := $UN.cast c
  val bytes = if (c > 0x7fU) then
    undefined()
    (* (* xxx TODO: Should implement following: *)
		int prefix = 0x40;
		char *p = utf8;
		do {
			*p++ = 0x80 + (c & 0x3f);
			bytes++;
			prefix >>= 1;
			c >>= 6;
		} while (c > prefix);
		*p = c - 2*prefix;
		reverse_string(utf8, p);
     *)
    else 1U
}
