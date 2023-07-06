# Relevant standards

Some of DEC's documentation, particularly for character encodings and
escape sequences, doesn't make much sense until you see the standards
they were constrained by. The VT340 Text Programming Reference Manual
lists some of the "coding standards" the terminal is compatible with.


## dpANS X3.134.1: 8-Bit ASCII structure and rules

## dpANS X3.134.2: Code for information interchange of 7-bit and 8-bit ASCII supplemental multilingual graphic character set

## ANSI X3.4 (1977): American Standard Code for Information Interchange (ASCII)

## ANSI-x3.64: _The_ ANSI Standard for Escape Sequences

* [ANSI-X3.64 (1979)](ANSI-X3.64-1979.pdf) - Contemporary when VT340
  was being designed.
* [ECMA-48 (1991)](ECMA-48_1991.pdf) - Final version
* ANSI x3.64 is equivalent to ISO-6429, ECMA-48, and FIPS Pub. 86.

This standard was so ubiquitous in the 1980s that even now, decades
later, the phrase "ANSI codes" means this document. This is the
standard that describes how valid escape sequences can be formed,
defines the meaning for some sequences, and specifies how private
extensions can be made.


## ISO 646-1977: International ASCII

* ISO 646-1973 - Original international standardization,
* Technically identical to ECMA-6 and CCITT Rec V.3 (Alphabet 5).


## ISO 2022-1986: Multilingual Code Extension Techniques.

* [ECMA-35 (1985)](ECMA-35_1985.pdf] - Contemporary with VT340. 
  Verbatim identical to ISO 2022-1986.
* [ANSI-X3.41 (1974)](ANSI-X3.41-1974.pdf) - Original standard.
  (Technically, [ECMA-35 (1971)](ECMA-35_1971.pdf) was the
  original-original, but ANSI's typesetting is easier to read.)
* [ECMA-35 (1994)](ECMA-35_1994.pdf) - Final version.
* ISO 2022 is technically the same as ANSI-X3.41, ECMA-35, and FIPS Pub 35.

This is the standard that explains how to use characters from other
languages via "shifting" to replace sections of the 8-bit character
set.

## ISO 6429-1983: Additional Control Functions for Character Imaging Devices

## ISO 8859-1-1987: 8-bit single byte code graphic character sets: Part 1: Latin Alphabet Nr 1.

Essentially, Latin-1 appears to be a codification of DEC's
Multilingual Character Set (MCS) with a few minor changes.

## ISBN 2-12-953907-0: International Register of Coded Character Sets to be used with Escape Sequences

* [ISO International Register](ISO_IR_Character_Set_Registry_2004.pdf) (mirrored from https://itscj.ipsj.or.jp/)

	Not technically a standard, the "IR" is a list of the ISO 2022
	character sets in use around the world and what escape sequences
	are used to activate them. DEC released localized versions of the
	VT340 for markets -- such as Hebrew, Korean, and Russian -- that
	likely used these sequences to select the proper character set.
	This may be an old list as it has had no new entries since 2004.

