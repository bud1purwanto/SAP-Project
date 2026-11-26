*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TXT_INSMK_SELECT                                  *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  TXT_INSMK_SELECT
*&---------------------------------------------------------------------*
FORM TXT_INSMK_SELECT USING    VALUE(IF_INSMK) TYPE MB_INSMK
                      CHANGING CF_TEXT         TYPE VAL_TEXT.

  DATA: LS_DD07V TYPE DD07V,
        LF_VALUE TYPE DD07V-DOMVALUE_L.

  LF_VALUE = IF_INSMK.

  CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
       EXPORTING
            NAME          = 'INSMK'
            VALUE         = LF_VALUE
            LANGU         = SY-LANGU
            TEXTS_ONLY    = 'X'
       IMPORTING
            DD07V_WA      = LS_DD07V
       EXCEPTIONS
            NOT_FOUND     = 1
            ILLEGAL_INPUT = 2
            OTHERS        = 3.

  IF SY-SUBRC NE 0.
    CLEAR CF_TEXT.
  ELSE.
    CF_TEXT = LS_DD07V-DDTEXT.
  ENDIF.

ENDFORM.                               " TXT_INSMK_SELECT





























