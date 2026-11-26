*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TXT_ABRUF_PART                                    *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TXT_ABRUF_PART
*&---------------------------------------------------------------------*
FORM TXT_ABRUF_PART.

  TABLES: DD07V.
  DATA: DA_VALUE_ABRUF_PART LIKE DD07V.
  DATA: DA_ABRUF_PART LIKE DD07V-DOMVALUE_L.

  CLEAR RV45A-TXT_ABRUF_PART.
  CHECK NOT VBAK-ABRUF_PART IS INITIAL.

* Alle Vorgänge aus der Festwerttabelle lesen
  DA_ABRUF_PART = VBAK-ABRUF_PART.
  CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
       EXPORTING
            NAME          = 'ABRUF_PART'
            VALUE         = DA_ABRUF_PART
            LANGU         = SY-LANGU
            TEXTS_ONLY    = 'X'
       IMPORTING
            DD07V_WA      = DA_VALUE_ABRUF_PART
       EXCEPTIONS
            NOT_FOUND     = 1
            ILLEGAL_INPUT = 2
            OTHERS        = 3.
  IF SY-SUBRC EQ 0.
    RV45A-TXT_ABRUF_PART = DA_VALUE_ABRUF_PART-DDTEXT.
  ENDIF.

ENDFORM.                               " TXT_ABRUF_PART