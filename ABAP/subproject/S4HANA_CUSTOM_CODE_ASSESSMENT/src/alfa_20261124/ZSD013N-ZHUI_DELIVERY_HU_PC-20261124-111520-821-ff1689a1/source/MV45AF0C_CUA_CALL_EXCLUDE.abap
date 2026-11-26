*---------------------------------------------------------------------*
*       FORM CUA_CALL_EXCLUDE                                         *
*---------------------------------------------------------------------*
*       Bei Call Transaction sind gewisse Fcode nicht zulässig        *
*---------------------------------------------------------------------*
FORM CUA_CALL_EXCLUDE.

  DATA: DA_FCODE LIKE CUA_EXCLUDE-FUNCTION,
        LV_BEFAERL TYPE C.

  IMPORT LV_BEFAERL FROM MEMORY ID 'SD_CALL_BEFAERL'.

  DO VARYING DA_FCODE FROM CUA_EXCLU_CALL-F01
                      NEXT CUA_EXCLU_CALL-F02.
    IF DA_FCODE EQ CUA_EXCLU_CALL-F99.
      EXIT.
    ENDIF.

    CASE DA_FCODE.

     WHEN 'FLI1'.
      IF NOT LV_BEFAERL IS INITIAL.
        CUA_EXCLUDE-FUNCTION = DA_FCODE.
        APPEND CUA_EXCLUDE.
      ENDIF.

     WHEN 'FFA1'.
      IF NOT LV_BEFAERL IS INITIAL.
        CUA_EXCLUDE-FUNCTION = DA_FCODE.
        APPEND CUA_EXCLUDE.
      ENDIF.

     WHEN 'FAU1'.
      IF NOT LV_BEFAERL IS INITIAL.
        CUA_EXCLUDE-FUNCTION = DA_FCODE.
        APPEND CUA_EXCLUDE.
      ENDIF.

     WHEN OTHERS.
      CUA_EXCLUDE-FUNCTION = DA_FCODE.
      APPEND CUA_EXCLUDE.

    ENDCASE.
  ENDDO.

ENDFORM.