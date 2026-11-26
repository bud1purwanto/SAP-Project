*&---------------------------------------------------------------------*
*& Report  ZFIC_IB_AUC
*&
*&---------------------------------------------------------------------*
* Description      : Settlement AUC
*
* Application Area - FI
* ABAPer           - PST - Adhy
* Date             - 26 November 2012
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | ##.##.## |             |            | Program created          *
*&---------------------------------------------------------------------*

REPORT  ZFIC_IB_AUC.
INCLUDE ZFIC_IB_AUC_TOP.
INCLUDE ZFIC_IB_AUC_AIAB_TRANSF01.

START-OF-SELECTION.
CLEAR : IDATA_AIAB, IDATA_AIBU, IRESULT.
REFRESH : IDATA_AIAB, IDATA_AIBU, IRESULT.

MOVE FPATH to FNAME.
IF R1 EQ 'X'.
  PERFORM GUI_UPLOAD_AIAB.
  PERFORM AIAB_TRANS.
  PERFORM DISPLAY.
ELSE.
  PERFORM GUI_UPLOAD_AIBU.
  PERFORM AIBU_TRANS.
  PERFORM DISPLAY.
ENDIF.

END-OF-SELECTION.