*&---------------------------------------------------------------------*
*&  Include           ZPPI_CHANGE_BOM_PO_PBO
*&---------------------------------------------------------------------*

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC1'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC1_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE T_CEKLIST LINES TC1-LINES.
ENDMODULE.                    "TC1_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC1'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE TC1_GET_LINES OUTPUT.
  G_TC1_LINES = SY-LOOPC.
ENDMODULE.                    "TC1_GET_LINES OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  PERFORM F_STATUS_100.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_STATUS_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_STATUS_100 .
  DATA ITAB_DISABLE TYPE TABLE OF SY-UCOMM.

  CLEAR ITAB_DISABLE.
  REFRESH ITAB_DISABLE.
  IF CODE = 'P'.
    APPEND '&DATA_SAVE' TO ITAB_DISABLE.
    APPEND '&EXPORT' TO ITAB_DISABLE.
    APPEND '&IMPORT' TO ITAB_DISABLE.
  ENDIF.

  SET PF-STATUS 'PF100' EXCLUDING ITAB_DISABLE.
  SET TITLEBAR '100'.

  LOOP AT SCREEN.
    CASE CODE.
      WHEN 'P'.
        IF SCREEN-NAME = 'W_CEKLIST-CHARG_A'.
          SCREEN-INPUT = 1.
        ELSEIF SCREEN-NAME = 'W_CEKLIST-MENGE_A'.
          SCREEN-INPUT = 1.
        ELSEIF SCREEN-NAME = 'W_CEKLIST-LGORT_A'.
          SCREEN-INPUT  = 1.
        ELSEIF SCREEN-NAME = 'W_CEKLIST-MATNR_A'.
          SCREEN-INPUT  = 1.
        ELSEIF SCREEN-NAME = 'B_ADD'.
          SCREEN-INPUT = 1.
          SCREEN-INVISIBLE = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                    " F_STATUS_100