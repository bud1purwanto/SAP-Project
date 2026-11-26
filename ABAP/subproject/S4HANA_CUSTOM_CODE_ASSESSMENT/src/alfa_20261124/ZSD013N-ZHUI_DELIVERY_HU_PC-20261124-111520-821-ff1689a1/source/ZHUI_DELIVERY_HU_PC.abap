*----------------------------------------------------------------------*
* Interface ZHUI_DELIVERY_HU_PC
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
* Description      : Create Outbound Delivery from HU
*
* Application Area - SD
* ABAPer           - Fina Oktavia Manurung
* Date             - August 06, 2012
*----------------------------------------------------------------------*
* Amendment History
* ~~~~~~~~~~~~~~~~~
* Ref | Date     | Programmer  | Correction | Description
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~
*----------------------------------------------------------------------*

INCLUDE ZHUI_DELIVERY_HU_PC_TOP.
INCLUDE ZABAPALV.
INCLUDE Z_PROG_INFO.
INCLUDE ZHUI_DELIVERY_HU_PC_ALV.
INCLUDE ZHUI_DELIVERY_HU_PC_F01.

START-OF-SELECTION.

AT SELECTION-SCREEN.
  PERFORM F_SELECTION_SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

INITIALIZATION.
  SET PF-STATUS 'MAIN_SCREEN'.
  MOVE 'Program Information' TO INFO.

"- F4 for Help Shipping Point
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VSTEL.
  "-GET DATA VSTEL
  SELECT VSTEL
  INTO CORRESPONDING FIELDS OF TABLE IT_VSTEL
  FROM VBAP
  WHERE VBAP~VBELN = V_VBELN
    AND VBAP~POSNR = V_POSNR.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'VSTEL'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = 'P_VSTEL'
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_VSTEL.

  IF SY-SUBRC <> 0.
*  Implement suitable error handling here
  ENDIF.


AT SELECTION-SCREEN OUTPUT.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'GRP'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

INCLUDE ZHUI_DELIVERY_HU_PC_STATUS_O01.

INCLUDE ZHUI_DELIVERY_HU_PC_USER_COI01.