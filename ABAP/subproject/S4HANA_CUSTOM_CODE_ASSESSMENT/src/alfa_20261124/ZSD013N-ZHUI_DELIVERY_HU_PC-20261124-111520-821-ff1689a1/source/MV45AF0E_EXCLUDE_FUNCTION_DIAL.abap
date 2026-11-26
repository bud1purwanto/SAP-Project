*---------------------------------------------------------------------*
*       FORM EXCLUDE_FUNCTION_DIALOG                                  *
*---------------------------------------------------------------------*
*       Bei Call Dialog sind gewisse Fcode nicht zulässig             *
*---------------------------------------------------------------------*
FORM EXCLUDE_FUNCTION_DIALOG.

  DATA: DA_FCODE LIKE CUA_EXCLUDE-FUNCTION,
        L_SD_SALES_BASIC_EXIT TYPE REF TO IF_EX_BADI_SD_SALES_BASIC,
        ACTIVE TYPE XFELD,
        DA_NO_EXCLUDE TYPE XFELD.

* Prepare SD Sales BAdI
  CALL FUNCTION 'GET_HANDLE_SD_SALES_BASIC'
    IMPORTING
      HANDLE = L_SD_SALES_BASIC_EXIT
      ACTIVE = ACTIVE.

  DO VARYING DA_FCODE FROM CUA_EXCLU_DIALOG-F01
                      NEXT CUA_EXCLU_DIALOG-F02.
    IF DA_FCODE EQ CUA_EXCLU_DIALOG-F99.
      EXIT.
    ENDIF.

    CUA_EXCLUDE-FUNCTION = DA_FCODE.
* Call SD Sales BAdI
    IF ACTIVE = CHARX.
      CLEAR DA_NO_EXCLUDE.
      CALL METHOD L_SD_SALES_BASIC_EXIT->MAINTAIN_CUA_PART2
        EXPORTING
          I_FCODE      = DA_FCODE
        CHANGING
          C_NO_EXCLUDE = DA_NO_EXCLUDE.
    ENDIF.
    IF DA_NO_EXCLUDE NE CHARX.
      APPEND CUA_EXCLUDE.
    ENDIF.
  ENDDO.

ENDFORM.                    "EXCLUDE_FUNCTION_DIALOG