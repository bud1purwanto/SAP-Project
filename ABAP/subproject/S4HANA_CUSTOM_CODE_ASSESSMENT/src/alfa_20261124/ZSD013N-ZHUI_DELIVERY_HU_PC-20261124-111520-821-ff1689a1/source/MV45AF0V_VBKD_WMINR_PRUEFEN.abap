*----------------------------------------------------------------------*
*   INCLUDE MV45AF0V_VBKD_WMINR_PRUEFEN                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  VBKD_WMINR_PRUEFEN
*&---------------------------------------------------------------------*
*       bei Existenz von WMINR Produktkatalog und CCODE_HEAD Produkt-
*       katalogkürzel deren 'Verträglichkeit' prüfen
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VBKD_WMINR_PRUEFEN.

  DATA: BEGIN OF D_WWMI OCCURS 0.
          INCLUDE STRUCTURE WWMI.
  DATA: END OF D_WWMI.


  CHECK NOT VBKD-WMINR IS INITIAL OR NOT RV45A-CCODE_HEAD IS INITIAL.

* Katalog und Katalogkürzel vorhanden
  IF NOT VBKD-WMINR IS INITIAL.
    IF NOT RV45A-CCODE_HEAD IS INITIAL.
*      passen die beiden zusammen?

      CALL FUNCTION 'PRODCAT_GET_LIST_BY_CCODE'
           EXPORTING
                PI_CCODE  = RV45A-CCODE_HEAD
           TABLES
                PE_T_WWMI = D_WWMI.

      LOOP AT D_WWMI WHERE WMINR = VBKD-WMINR.
      ENDLOOP.
      IF SY-SUBRC NE 0.
*       fehlermeldung: passen nicht zusammen, da vbkd-wminr nicht in
*                      d_wwmi-liste
        SET CURSOR FIELD 'VBKD-WMINR'.
        MESSAGE E201(WVA) WITH VBKD-WMINR RV45A-CCODE_HEAD.
      ENDIF.
    ENDIF.
  ENDIF.

* nur Katalogkürzel vorhanden
  IF VBKD-WMINR IS INITIAL AND NOT RV45A-CCODE_HEAD IS INITIAL.
    CALL FUNCTION 'PRODCAT_GET_LIST_BY_CCODE'
         EXPORTING
              PI_CCODE  = RV45A-CCODE_HEAD
         TABLES
              PE_T_WWMI = D_WWMI.


    READ TABLE D_WWMI INDEX 1.
    IF SY-SUBRC EQ 0.
      VBKD-WMINR = D_WWMI-WMINR.
    ENDIF.
  ENDIF.

* nur Katalog vorhanden
  IF NOT VBKD-WMINR IS INITIAL AND RV45A-CCODE_HEAD IS INITIAL.
    CALL FUNCTION 'ADV_MED_READ'
         EXPORTING
              PI_ADV_MED        = VBKD-WMINR
*             PI_WITH_TEXT      = ' '
*             PI_LANGUAGE       = ' '
*        TABLES
*             PE_T_WWMIT        =
         CHANGING
              PE_WWMI           = D_WWMI
*             PE_WWMIT          =
         EXCEPTIONS
              ADV_MED_NOT_FOUND = 1
              OTHERS            = 2
              .
    IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
*     make falls d_wwmi struktur ist
      RV45A-CCODE_HEAD = D_WWMI-CCODE.
    ENDIF.
  ENDIF.


ENDFORM.                               " VBKD_WMINR_PRUEFEN























