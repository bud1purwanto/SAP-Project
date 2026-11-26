*&---------------------------------------------------------------------*
*&  Include           MV45AF0T_TEXT_CONTROL_DATALOSS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TEXT_CONTROL_DATALOSS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TEXT_CONTROL_DATALOSS .

  DATA:          LV_STATUS  TYPE I.
  FIELD-SYMBOLS: <LFS_TEXT> TYPE REF TO CL_GUI_TEXTEDIT.

* Nur Text im Text Edit Control bei Text in Übersichtsbild geändert?
  IF R185D-DATALOSS IS INITIAL AND
     SY-DYNGR EQ DYNGR_UEBERSICHT AND
     ( FCODE = 'BAC1' OR FCODE = 'BABA' OR FCODE = 'ABBA' ).
    ASSIGN ('(SAPLV70T)GV_TEXT_EDITOR') TO <LFS_TEXT>.
    IF SY-SUBRC = 0 AND
       NOT <LFS_TEXT> IS INITIAL.
      CALL METHOD <LFS_TEXT>->GET_TEXTMODIFIED_STATUS
        IMPORTING
          STATUS                 = LV_STATUS
        EXCEPTIONS
          ERROR_CNTL_CALL_METHOD = 1
          OTHERS                 = 2.
      IF SY-SUBRC <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
        IF NOT LV_STATUS IS INITIAL.
          R185D-DATALOSS = CHARX.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " TEXT_CONTROL_DATALOSS