*----------------------------------------------------------------------*
* Interface  ZQMI_PACKING_STATUS
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
* Description      : QC Status for Packing (Daftar Pengepakan)
*
* Application Area - QM
* ABAPer           - Fina Oktavia Manurung
* Date             - July 25, 2012
*----------------------------------------------------------------------*
* Amendment History
* ~~~~~~~~~~~~~~~~~
* Ref | Date     | Programmer  | Correction | Description
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~
*----------------------------------------------------------------------*

INCLUDE ZQMI_PACKING_STATUS_TOP.
INCLUDE ZQMI_PACKING_STATUS_F01.
INCLUDE Z_PROG_INFO.

START-OF-SELECTION.
    CLEAR : RET_CODE, ZTEXT.
    PERFORM CHECK_AUTH_PLANT USING S_WERKS.
    IF RET_CODE <> 0.
      CONCATENATE  'Anda tidak bisa melakukan transaksi di Plant' S_WERKS INTO ZTEXT SEPARATED BY SPACE.
      MESSAGE ZTEXT TYPE 'I'.
      STOP.
    ENDIF.

    PERFORM READ_HANDLING_UNIT.
    IF R1 = 'X'.
      PERFORM DISPLAY_DATA USING ''.
    ELSE.
      PERFORM DISPLAY_DATA_NON USING ''.
    ENDIF.

TOP-OF-PAGE.
  IF SY-UCOMM NE 'CLOG'.
    IF R1 = 'X'.
      PERFORM HEADER_DATA.
    ELSE.
      PERFORM HEADER_DATA_NON.
    ENDIF.
  ENDIF.

TOP-OF-PAGE DURING LINE-SELECTION. "ADD BY IRMA
  IF SY-UCOMM NE 'CLOG'.
    IF R1 = 'X'.
      PERFORM HEADER_DATA.
    ELSE.
      PERFORM HEADER_DATA_NON.
    ENDIF.
  ENDIF.

AT LINE-SELECTION.
  PERFORM EDIT_STATUS.

AT USER-COMMAND.
  PERFORM USER_COMMAND USING SY-UCOMM RS_SELFIELD.

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

INITIALIZATION.
  S_ERDAT-HIGH = SY-DATUM.
  APPEND S_ERDAT.
  MOVE 'Program Information' TO INFO.


AT SELECTION-SCREEN OUTPUT.
  NAME = 'P_LIST'.
  VALUE-KEY = 'QA OK'.
  APPEND VALUE TO LIST.

  VALUE-KEY = 'QA IN'.
  APPEND VALUE TO LIST.

  SORT LIST ASCENDING BY KEY.
  DELETE ADJACENT DUPLICATES FROM LIST COMPARING KEY.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = NAME
      VALUES = LIST.