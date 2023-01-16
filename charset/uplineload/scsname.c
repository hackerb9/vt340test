#include <string.h>

char *scsname(char *scs) {
  /* Given a Select Character Set escape sequence, such as "\e+>",
     return the 3- (or 4-) letter name for the character set.

     Note: We cannot use just the final character because which
     character set is intended also depends upon the intermediate
     values. For example: Esc+A is British, but Esc/A is Latin-1.
  */
  if (strlen(scs) < 3) return "unk";
  
  switch (scs[1]) {
  case '(':  case ')':  case '*':  case '+':
    /* 94-character sets in G0-4 */
    if (strcmp(scs+2, "B")==0)  return "asc";
    if (strcmp(scs+2, "0")==0)  return "gfx";
    if (strcmp(scs+2, ">")==0)  return "tcs";
    if (strcmp(scs+2, "%5")==0)  return "mcs";
    if (strcmp(scs+2, "<")==0)  return "pref";

    if (strcmp(scs+2, "I")==0)  return "kata";
    if (strcmp(scs+2, "J")==0)  return "jrom";

    if (strcmp(scs+2, "A")==0)  return "uknr";
    if (strcmp(scs+2, "4")==0)  return "nlnr";
    if (strcmp(scs+2, "5")==0)  return "finr";
    if (strcmp(scs+2, "C")==0)  return "finr";
    if (strcmp(scs+2, "R")==0)  return "frnr";
    if (strcmp(scs+2, "9")==0)  return "qunr";
    if (strcmp(scs+2, "Q")==0)  return "qunr";
    if (strcmp(scs+2, "K")==0)  return "denr";
    if (strcmp(scs+2, "Y")==0)  return "itnr";
    if (strcmp(scs+2, "`")==0)  return "nonr";
    if (strcmp(scs+2, "E")==0)  return "nonr";
    if (strcmp(scs+2, "6")==0)  return "nonr";
    if (strcmp(scs+2, "%6")==0)  return "ptnr";
    if (strcmp(scs+2, "Z")==0)  return "esnr";
    if (strcmp(scs+2, "7")==0)  return "senr";
    if (strcmp(scs+2, "H")==0)  return "senr";
    if (strcmp(scs+2, "=")==0)  return "chnr";

    return "unk";
    break;

  case '-':  case '.':  case '/':
    /* 96-character sets in G1-4 */
    if (strcmp(scs+2, "<") == 0)     return "pref";
    if (strcmp(scs+2, " @") == 0)    return "soft";
    if (strcmp(scs+2, "&%C") == 0)   return "soft";

    if (strcmp(scs+2, "A") == 0)   return "lat1";
    if (strcmp(scs+2, "B") == 0)   return "lat2";
    if (strcmp(scs+2, "C") == 0)   return "lat3";
    if (strcmp(scs+2, "D") == 0)   return "lat4";
    if (strcmp(scs+2, "L") == 0)   return "cyr";
    if (strcmp(scs+2, "G") == 0)   return "arab";
    if (strcmp(scs+2, "F") == 0)   return "grk";
    if (strcmp(scs+2, "H") == 0)   return "heb";
    if (strcmp(scs+2, "M") == 0)   return "lat5";
    if (strcmp(scs+2, "K") == 0)   return "math";

    return "unk";
    break;

  case '$':
    /* Multibyte character sets */
    if (strcmp(scs+3, "A") == 0)      return "cgb";
    if (strcmp(scs+3, "B") == 0)      return "jap";
    if (strcmp(scs+3, "C") == 0)      return "kor";

    break;

  default:
    /* Unknown intermediate */
    return "unk";
  }    

  return "unk";
}

char *scslongname(char *scs) {
  /* Given a Select Character Set escape sequence, such as "\e+>",
     return the full name for the character set. */

  char *shortname = scsname(scs);

  if (strcmp(shortname, "asc") == 0)    return "ASCII (ANSI X3.4-1986)";
  if (strcmp(shortname, "gfx") == 0)    return "DEC VT100 Graphics";
  if (strcmp(shortname, "tcs") == 0)    return "DEC Technical";
  if (strcmp(shortname, "mcs") == 0)    return "DEC Multinational";
  if (strcmp(shortname, "pref") == 0)   return "User-preferred Supplemental"; 
  if (strcmp(shortname, "soft") == 0)   return "Down-Line-Loadable (Soft)";

  if (strcmp(shortname, "lat1") == 0)   return "Latin Alphabet No. 1";
  if (strcmp(shortname, "lat2") == 0)   return "Latin Alphabet No. 2";
  if (strcmp(shortname, "lat3") == 0)   return "Latin Alphabet No. 3";
  if (strcmp(shortname, "lat4") == 0)   return "Latin Alphabet No. 4";
  if (strcmp(shortname, "cyr") == 0)    return "Latin/Cyrillic";
  if (strcmp(shortname, "arab") == 0)   return "Latin/Arabic";
  if (strcmp(shortname, "grk") == 0)    return "Latin/Greek";
  if (strcmp(shortname, "heb") == 0)    return "Latin/Hebrew";
  if (strcmp(shortname, "lat5") == 0)   return "Latin Alphabet No. 5";
  if (strcmp(shortname, "math") == 0)   return "Math/Technical Set (?)";

  if (strcmp(shortname, "cgb") == 0)     return "Chinese (CAS GB 2312-80)";
  if (strcmp(shortname, "jap") == 0)     return "Japanese (JIS X 0208)";
  if (strcmp(shortname, "kata") == 0)    return "JIS-Katakana (JIS X 0201)";
  if (strcmp(shortname, "jrom") == 0)    return "JIS-Roman (JIS X 0201)";
  if (strcmp(shortname, "kor") == 0)     return "Korean (KS C 5601-1989)";

  /* National Replacement Character Set */
  if (strcmp(shortname, "uknr")==0)  return "British National Replacement";
  if (strcmp(shortname, "nlnr")==0)  return "Dutch National Replacement";
  if (strcmp(shortname, "finr")==0)  return "Finnish National Replacement";
  if (strcmp(shortname, "frnr")==0)  return "French National Replacement";
  if (strcmp(shortname, "qunr")==0)  return "French Canadian National Replacement";
  if (strcmp(shortname, "denr")==0)  return "German National Replacement";
  if (strcmp(shortname, "itnr")==0)  return "Italian National Replacement";
  if (strcmp(shortname, "nonr")==0) return "Norwegian/Danish National Replacement";
  if (strcmp(shortname, "ptnr")==0)  return "Portuguese National Replacement";
  if (strcmp(shortname, "esnr")==0)  return "Spanish National Replacement";
  if (strcmp(shortname, "senr")==0)  return "Swedish National Replacement";
  if (strcmp(shortname, "chnr")==0)  return "Swiss National Replacement";

  return scs+1;			/* Return escape sequence without escape */
}

/* Note from Kermit Documentation
   
    It is important to note that the final letter of the escape
    sequence is not always sufficient to designate a character set.
    For example, Czech Standard and JIS Katakana are both designated
    by letter I, but the two can be distinguished by the intermediate
    characters of the escape sequence, which specify whether the set
    is single- or multibyte, or, when both sets are single-byte,
    whether there are 94 or 96 characters.
*/

/* Table from Kermit Documentation
  
                            Escape    ISO          ECMA        ISO/ECMA
 Alphabet Name              Sequence  Reference    Reference   Registration
 
  ASCII (ANSI X3.4-1986)    <ESC>(B   ISO 646 IRV  ECMA-6        6
  Latin Alphabet No. 1      <ESC>-A   ISO 8859-1   ECMA-94     100
  Latin Alphabet No. 2      <ESC>-B   ISO 8859-2   ECMA-94     101
  Latin Alphabet No. 3      <ESC>-C   ISO 8859-3   ECMA-94     109
  Latin Alphabet No. 4      <ESC>-D   ISO 8859-4   ECMA-94     110
  Latin/Cyrillic            <ESC>-L   ISO 8859-5   ECMA-113    144
  Latin/Arabic              <ESC>-G   ISO 8859-6   ECMA-114    127
  Latin/Greek               <ESC>-F   ISO 8859-7   ECMA-118    126
  Latin/Hebrew              <ESC>-H   ISO 8859-8   ECMA-121    138
  Latin Alphabet No. 5      <ESC>-M   ISO 8859-9   ECMA-128    148
* Math/Technical Set        <ESC>-K   ????         ????        143
  Chinese (CAS GB 2312-80)  <ESC>$)A  none         none         58
  Japanese (JIS X 0208)     <ESC>$)B  none         none         87
  JIS-Katakana (JIS X 0201) <ESC>)I   none         none         13
  JIS-Roman (JIS X 0201)    <ESC>)J   none         none         14
  Korean (KS C 5601-1989)   <ESC>$)C  none         none        149
 
   Table 6: Alphabets, Selectors, Standards, and Registration Numbers
_____________________________________________________________________________
 
* A math/technical set is clearly needed to handle the IBM PC, DEC VT-series,
  and other math/technical/line-drawing characters, but there is apparently
  no such standard set at this time (ISO 6862? ISO DIS 10367?)
*/  
