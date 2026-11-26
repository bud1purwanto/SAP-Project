*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_SLEG                                        *
*----------------------------------------------------------------------*
FORM FCODE_SLEG.

  DATA: LT_DD07V_TAB TYPE DD07V OCCURS 0 WITH HEADER LINE,
        LT_STATV_DISP TYPE SHP_STATV_DISP OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'DDUT_DOMVALUES_GET'
       EXPORTING
            NAME          = 'STATV'
            LANGU         = SY-LANGU
            TEXTS_ONLY    = ' '
       TABLES
            DD07V_TAB     = LT_DD07V_TAB
       EXCEPTIONS
            ILLEGAL_INPUT = 1
            OTHERS        = 2.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

  LOOP AT LT_DD07V_TAB.
    MOVE-CORRESPONDING LT_DD07V_TAB TO LT_STATV_DISP.
    APPEND LT_STATV_DISP.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            DDIC_STRUCTURE  = 'SHP_STATV_DISP'
            RETFIELD        = 'LF_DUMMY'
            WINDOW_TITLE    = TEXT-071
            VALUE_ORG       = 'S'
            DISPLAY         = 'X'
       TABLES
            VALUE_TAB       = LT_STATV_DISP
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.


ENDFORM.