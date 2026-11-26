*----------------------------------------------------------------------*
* Report  ZPPI_UP_DL_PO_JR                                             *
* ~~~~~~~~~~~~~~                                                       *
*                                                                      *
* Description: Planning Jumbo roll   Menu                              *
*                                                                      *
* Specification - pp                                                   *
* Abaper        - Bagus aditya putra (bap)                             *
*----------------------------------------------------------------------*
* Amendment History                                                    *
* ~~~~~~~~~~~~~~~~~                                                    *
* Ref | Date     | Abaper      | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~~               *
*----------------------------------------------------------------------*

REPORT  ZPPI_UP_DL_PO_JR.
INCLUDE Z_PROG_INFO.
DATA : V_PROG LIKE ZPROGINFO-PGMNA VALUE 'ZPPI_UP_DL_PO_JR'.

SELECTION-SCREEN: SKIP,
BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-100,
                  BEGIN OF LINE.
PARAMETERS:     BUT1  RADIOBUTTON GROUP GRP1.
SELECTION-SCREEN: POSITION 4, COMMENT (45) TEXT-110,
                  POSITION 30.
SELECTION-SCREEN: END OF LINE,
                  BEGIN OF LINE.
PARAMETERS:     BUT2 RADIOBUTTON GROUP GRP1.
SELECTION-SCREEN: POSITION 4, COMMENT (50) TEXT-120,
                  END OF LINE,
                  BEGIN OF LINE.
PARAMETERS:     BUT3 TYPE C RADIOBUTTON GROUP GRP1 .
SELECTION-SCREEN: POSITION 4, COMMENT (50) TEXT-130,
                  END OF LINE,
END OF BLOCK BLOCK1.

SELECTION-SCREEN BEGIN OF BLOCK INFO1 WITH FRAME.
SELECTION-SCREEN PUSHBUTTON /12(79) INFO USER-COMMAND INFO.
SELECTION-SCREEN END OF BLOCK INFO1.

START-OF-SELECTION.

INITIALIZATION.
  INFO = 'Program Information'.

AT SELECTION-SCREEN.
  "-> upload & revisi process jumbo roll
  CASE SY-UCOMM.
    WHEN 'ONLI'.
      IF BUT1 = 'X'.
        SUBMIT ZPPI_UP_REV_PR_JR VIA SELECTION-SCREEN AND RETURN.

        "-> Download process jumbo roll
      ELSEIF BUT2 = 'X'.
        SUBMIT ZPPI_DL_PO_JR VIA SELECTION-SCREEN AND RETURN.

        "-> gant chart
      ELSEIF BUT3 = 'X'.
        SUBMIT ZPPI_GCHART_PR_JR VIA SELECTION-SCREEN AND RETURN.

      ENDIF.
    WHEN 'INFO'.
      PERFORM F_PROG_INFO USING V_PROG.
  ENDCASE.

END-OF-SELECTION.