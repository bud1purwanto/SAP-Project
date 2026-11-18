*----------------------------------------------------------------------*
* Report ZQMI_PROP_SELECT
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*                                                                      *
* Description      : Properties Report for Production
*                                                                      *
* Application Area - QM
* ABAPer           - Rimbun Gracia Siahaan
* Date             - June, 28 2012
*----------------------------------------------------------------------*
* Amendment History
* ~~~~~~~~~~~~~~~~~
* Ref | Date     | Programmer  | Correction | Description
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~
* 001 | ##.##.## |             |            | Program created
*----------------------------------------------------------------------*

REPORT  ZQMI_PROP_SELECT.

INCLUDE ZQMI_PROP_SELECT_TOP.
INCLUDE ZABAPALV.
INCLUDE Z_PROG_INFO.
INCLUDE ZQMI_PROP_CLASS_DEFINITION.    " Class Definition
INCLUDE ZQMI_PROP_CLASS_IMPLEMENTATION.    " Class Implementation
INCLUDE ZQMI_PROP_SELECT_F01.