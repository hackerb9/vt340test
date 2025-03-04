# National Replacement Character Sets

## j4james: NRC in Historical Context

<blockquote>

I think it's worth mentioning how the National Replacement Character
Sets (NRCs) work, because that's something that I think is not
immediately obvious if you aren't familiar with the history of these
terminals.

My understanding (which may be wrong) is that most if not all NRC sets
will _not_ work by default. You first have to enable National
Replacement Character Set Mode (`DECNRCM`), and that itself only works
if your keyboard dialect is set to something other than North
American. Then even with `DECNRCM` enabled, you'll still only have
access to one of the NRC sets - the one that matches your keyboard
dialect.

The point of these sets was for use on 7-bit systems, so once `DECNRCM`
is enabled, everything is 7-bit. If you've got a British keyboard, for
example, then Shift+3 is labelled as producing a pound symbol (£), but
the keyboard can't generate an 0xA3 codepoint on a 7-bit system. So
instead it generates 0x23, and relies on the fact that the British NRC
set has 0x23 mapped to £. That way it'll at least look like a £ when
you type it, even though the backend system is still receiving an
ASCII # character.

So unless you're tied to a 7-bit system with a specific non-ASCII
locale, and you're also using a matching keyboard, there's not much
use for these character sets. And I'm assuming that's why they only
allow for one at a time (if my understanding is correct).

</blockquote>

[(Thanks go to @j4james who kindly shared that bit of history.)](https://github.com/hackerb9/vt340test/issues/28)



### The VT340 and NRC Sets

National Replacement Character Sets appear to be an older method which
the VT340 merely provides as a backwards compatibility convenience. In
fact, it DEC seems to gone out of their way to make it difficult to
accidentally start using it. Any software which queries the VT340's
capabilities will find that National Replacement Character Mode
(`DECNRCM`) is "Permanently Disabled".

Without the manual, is not obvious from the VT340 Set-Up menu how to
even enable NRC — the page which lets one pick "Latin1" or
"Multilingual Character Set" has nothing about it. The trick is NRC
Sets are implicitly chosen by changing the _Keyboard_ type. Any
keyboard type other than the default ("North American") simultaneously
picks an NRC set.

| Keyboard        | NRC Set          |
|-----------------|------------------|
| United Kingdom  | United Kingdom   |
| Danish          | Norwegian/Danish |
| Dutch           | Dutch            |
| Finnish         | Finnish          |
| Flemish         | French           |
| French/Belgian  | French           |
| French Canadian | French Canadian  |
| German          | German           |
| Italian         | Italian          |
| Norwegian       | Norwegian/Danish |
| Portuguese      | Portuguese       |
| Spanish         | Spanish          |
| Swedish         | Swedish          |
| Swiss (French)  | Swiss            |
| Swiss (German)  | Swiss            |

The VT340 has tables and fonts for twelve different NRC regions and
can show only one of them at a time. Each one alters up to 12
different characters from ASCII. For example, the `#` character
displays as a `£` for the United Kingdom NRC Set.

The "extra" characters provided by the VT340's NRC Sets are:

¡, £, §, ¨, °, ¼, ½, ¾, ¿, Ã, Ä, Å, Æ, Ç, É, Ñ, Õ, Ö, Ø, Ü, ß, à, à, ã, ä, å, æ, ç, è, é, ê, ì, î, ñ, ò, ô, õ, ö, ø, ù, û, ü, ÿ

As mentioned in [the charset README](README.md), all of these
characters are already available in the Latin-1 character set, so
there is no real advantage to using them.

If you have files encoded in an NRC, you may be able to convert them
to Unicode using `iconv`. If you have a program that outputs NRC, try
using the `luit` program to wrap around it.

The twelve NRCs builtin to the VT340 and the escape codes for loading
them.
| Character Set        | G0     | G1     | G2      | G3     | International Registry |
|----------------------|--------|--------|---------|--------|------------------------|
| DEC Great Britain    | ESC(A  | ESC)A  | ESC\*A  | ESC+A  | [IR-004][IR004]        |
| German               | ESC(K  | ESC)K  | ESC\*K  | ESC+K  | [IR-021][IR021]        |
| French (France)      | ESC(R  | ESC)R  | ESC\*R  | ESC+R  | [IR-025][IR025]        |
| Italian              | ESC(Y  | ESC)Y  | ESC\*Y  | ESC+Y  | [IR-015][IR015]        |
| Spanish              | ESC(Z  | ESC)Z  | ESC\*Z  | ESC+Z  | [IR-017][IR017]        |
| DEC Dutch            | ESC(4  | ESC)4  | ESC\*4  | ESC+4  | None                   |
| DEC Finnish          | ESC(5  | ESC)5  | ESC\*5  | ESC+5  | None                   |
| DEC Portuguese       | ESC(%6 | ESC)%6 | ESC\*%6 | ESC+%6 | None                   |
| DEC Norwegian/Danish | ESC(6  | ESC)6  | ESC\*6  | ESC+6  | None                   |
| DEC Swedish          | ESC(7  | ESC)7  | ESC\*7  | ESC+7  | None                   |
| DEC French Canadian  | ESC(9  | ESC)9  | ESC\*9  | ESC+9  | None                   |
| DEC Swiss            | ESC(=  | ESC)=  | ESC\*=  | ESC+=  | None                   |

  [IR004]: https://hackerb9.github.io/vt340test/docs/standards/IR004-British.pdf
  [IR021]: https://hackerb9.github.io/vt340test/docs/standards/IR021-German.pdf 
  [IR025]: https://hackerb9.github.io/vt340test/docs/standards/IR025-French.pdf 
  [IR015]: https://hackerb9.github.io/vt340test/docs/standards/IR015-Italian.pdf
  [IR017]: https://hackerb9.github.io/vt340test/docs/standards/IR017-Spanish.pdf
