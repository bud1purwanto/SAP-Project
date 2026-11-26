*----------------------------------------------------------------------*
*   INCLUDE MV45AF0E_EXCLUDE_FUNCTION_RFC                              *
*----------------------------------------------------------------------*
*   Bei RFC sind gewisse Fcodes nicht zulässig                         *
*----------------------------------------------------------------------*
FORM EXCLUDE_FUNCTION_RFC.

  DATA: DA_FCODE LIKE CUA_EXCLUDE-FUNCTION.

  DO VARYING DA_FCODE FROM CUA_EXCLU_RFC-F01
                      NEXT CUA_EXCLU_RFC-F02.
    IF DA_FCODE EQ CUA_EXCLU_RFC-F99.
      EXIT.
    ENDIF.
    CUA_EXCLUDE-FUNCTION = DA_FCODE.
    APPEND CUA_EXCLUDE.
  ENDDO.

ENDFORM.