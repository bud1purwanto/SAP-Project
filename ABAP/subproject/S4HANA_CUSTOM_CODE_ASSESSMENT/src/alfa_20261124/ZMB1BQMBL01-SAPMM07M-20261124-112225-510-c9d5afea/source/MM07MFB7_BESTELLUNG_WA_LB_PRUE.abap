*eject
*---------------------------------------------------------------------*
*       FORM BESTELLUNG_WA_LB_PRUEFEN                                 *
*---------------------------------------------------------------------*
*       Die Bestellung wird für den Warenausgang zur Lohnbearbeiter-  *
*       bestellung wird gelesen.                                      *
*---------------------------------------------------------------------*
  FORM BESTELLUNG_WA_LB_PRUEFEN USING B-EBELN LIKE MSEG-EBELN
                                      B-EBELP LIKE MSEG-EBELP.

    CALL FUNCTION 'ME_READ_COMP_GOODS_ISSUE'
         EXPORTING
              EBELN         = B-EBELN  "Einkaufsbelegnummer
              EBELP         = B-EBELP  "Einkaufsbelegposition
         TABLES
              XMDGI =
                 XMDGI "die is Materialien enth. Komponenten
         EXCEPTIONS
              NOT_FOUND_ANY = 01       "keine Position vorhanden
              NOT_FOUND_ONE = 02  "angegebene Position nicht vorhanden
              NOT_VALID_ANY = 03       "keine Position gültig für WE
              NOT_VALID_ONE = 04.      "angegebene Position nicht gültig
    IF T158-TRTYP = H.
      CASE SY-SUBRC.
         WHEN 0.                                                 "367129
           IF XMDGI[] IS INITIAL.                                "367129
             MESSAGE E033 WITH B-EBELN.                          "367129
           ENDIF.                                                "367129
        WHEN 1.
          MESSAGE E033 WITH B-EBELN.
        WHEN 2.
          MESSAGE E150 WITH B-EBELN B-EBELP.
        WHEN 3.
          MESSAGE E151 WITH B-EBELN.
        WHEN 4.
          IF NOT B-EBELP IS INITIAL.
            MESSAGE E152 WITH B-EBELP B-EBELN.
          ELSE.
            MESSAGE E153 WITH B-EBELN.
          ENDIF.
      ENDCASE.
      SORT xmdgi BY matnr ASCENDING.                             "660265
    ENDIF.
  ENDFORM.