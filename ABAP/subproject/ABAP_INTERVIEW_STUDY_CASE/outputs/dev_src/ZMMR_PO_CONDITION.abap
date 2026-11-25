* Report  Report  ZMMR_PO_CONDITION
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Description      : ZMMR_PO_CONDITION
*
* Application Area - MM
* ABAPer           - BJWP
* Date             - 06 November, 2012
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | 06.11.12 | BJWP        |            | Program created          *
*----------------------------------------------------------------------*

REPORT  ZMMR_PO_CONDITION.

INCLUDE ZABAPALV.
INCLUDE Z_PROG_INFOMMR.
INCLUDE ZMMR_PO_CONDITION_TOP.
INCLUDE ZMMR_PO_CONDITION_F01.

*-- Untuk initial awal di selection screen
INITIALIZATION.
  TITLE1  = 'Program Selection'.
  TITLE2  = 'PO Status'.
  TXT1    = 'Material Number'.
  TXT2    = 'Purchasing Document'.
  TXT3    = 'Vendor'.
  TXT4    = 'Material Group'.
  TXT5    = 'Plant'.
  TXT6    = 'Storage Location'.
  TXT7    = 'Document Date PO'.
  TXT8    = 'Document Type'.
  TXT10   = 'Purchasing Group'.
  TXT11   = 'Purchasing Organization'.
  TXT13   = 'Posting Date GR'.
  TXT14   = 'PO All'.
  TXT15   = 'PO Open'.
  TXT16   = 'PO Completed'.
  MOVE 'Program Information' TO INFO. "DOCUMENTATION

*  DOCUMENTATION*************************
AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.
*  *************************************

*-- jika sudah klik execute
START-OF-SELECTION.
  PERFORM GET_SRC.
  PERFORM GET_DATA.
  PERFORM SET_ALV.
