*&---------------------------------------------------------------------*
*&      Form  PARTNER_PUT_DATA
*&---------------------------------------------------------------------*
*       save information whether partner was changed
*----------------------------------------------------------------------*
FORM PARTNER_PUT_DATA.

  CALL FUNCTION 'SD_PARTNER_CHANGED_PUT_DATA'
       EXPORTING
            I_AG_CHANGED = RV02P-AGUPD.
ENDFORM.
***INCLUDE MV45AF0P_PARTNER_PUT_DATA .