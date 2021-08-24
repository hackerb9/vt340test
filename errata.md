## Documentation Errata

This is a page for accruing the errors I've found in the manuals.

### EK-VT3XX-GP-002

* DECSDM reversed regarding sixel scrolling

* DECLBD "Ky1" is merely the first Ky, not an identifier. Also,
  indentation for Pc is incorrect.


### EK-VT3XX-TP-001

There is a newer version of this manual which may not have these
errors. However, it isn't available online at the time of writing
(August 2021).

* DECSSDT: Select Status Line Type incorrectly uses a hyphen as the
  terminating character instead of a tilde. The manual should read:

>> |       |      |   |    |
>> |:------|:-----|:--|:---|
>> |**CSI**|**Ps**| $ | ~  |
>> |  9/11 |  3/? |2/4|7/14|

> Also the default if Ps is omitted is **0** (no status line), not
> **1** (indicator status line).



  