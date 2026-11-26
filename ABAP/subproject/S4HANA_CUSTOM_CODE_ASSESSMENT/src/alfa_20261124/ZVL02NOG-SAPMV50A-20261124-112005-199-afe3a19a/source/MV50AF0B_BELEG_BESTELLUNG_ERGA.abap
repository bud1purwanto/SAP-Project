*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BELEG_BESTELLUNG_ERGA                             *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM BELEG_BESTELLUNG_ERGAENZEN                               *
*---------------------------------------------------------------------*
*       Die Lieferung wird zum Buchen des Wareneingangs mit Daten     *
*       aus der Bestellung komplettiert                               *
*---------------------------------------------------------------------*
FORM BELEG_BESTELLUNG_ERGAENZEN.

  DATA: BBE_EXIST VALUE ' '.

  REFRESH XMSEG.

* setze Kennzeichen daß es sich um die Wareneingansgtransaktion handelt
  KZ_WARENEINGANG = CHARX.

  LOOP AT XLIPS.
    CLEAR XMSEG.

*   Falls Vorgaenger keine Bestellung dann dummy-satz
    IF XLIPS-VGBEL IS INITIAL OR
       XLIPS-VGTYP NE CHARV.
      XMSEG-MATNR = XLIPS-MATNR.
      XMSEG-ERFME = XLIPS-MEINS.
      XMSEG-ERFMG = XLIPS-LGMNG.
      XMSEG-MENGE = XLIPS-LGMNG.
      XMSEG-MEINS = XLIPS-MEINS.
      SELECT * FROM T001W WHERE KUNNR = LIKP-KUNNR.
        XMSEG-WERKS = T001W-WERKS.
        EXIT.
      ENDSELECT.
* empfangendes Werk muß vorhanden sein
      CHECK NOT XMSEG-WERKS IS INITIAL.
      IF NOT XLIPS-BWART IS INITIAL.
        IF XLIPS-BWART NE T156N-BWART.
          SELECT SINGLE * FROM T156N WHERE FCODE EQ 'WEUB'
                                       AND BWART EQ XLIPS-BWART.
          IF SY-SUBRC NE 0.
            CLEAR T156N.
            MESSAGE E651 WITH XLIPS-BWART.
          ENDIF.
        ENDIF.
        XMSEG-BWART = T156N-BWART_NEXT.
      ENDIF.
*   Chargenpflicht im empfangenden Werk
      PERFORM MAEPV_SELECT(SAPFV50P) USING XLIPS-MATNR
                                           XMSEG-WERKS
                                           XMSEG-LGORT
                                           XLIPS-BERID         "n_987304
                                           SPACE
                                           SPACE
                                           SY-SUBRC.
      IF NOT MAEPV-XCHPF IS INITIAL.
        XMSEG-SOBKZ = MAEPV-XCHPF.
        XMSEG-CHARG = XLIPS-CHARG.
      ENDIF.

      APPEND XMSEG.
      CHECK 1 = 2.
    ENDIF.

*   lesen Bestellposition
    SELECT SINGLE *
           INTO EKPO
           FROM EKPO
           WHERE EBELN = XLIPS-VGBEL  AND
                 EBELP = XLIPS-VGPOS.
    IF SY-SUBRC NE 0.
      MESSAGE I650 WITH XLIPS-VGBEL XLIPS-VGPOS.
      APPEND XMSEG.
      EXIT.
    ENDIF.

*   fuellen MSEG als Eatab
    XMSEG-WERKS = EKPO-WERKS.
    XMSEG-LGORT = EKPO-LGORT.
    XMSEG-EBELN = EKPO-EBELN.
    XMSEG-EBELP = EKPO-EBELP.
    XMSEG-INSMK = EKPO-INSMK.
    XMSEG-XAUTO = EKPO-INSNC.
    XMSEG-ERFME = EKPO-MEINS.
    XMSEG-ERFMG = XLIPS-LGMNG * EKPO-UMREN / EKPO-UMREZ.
    XMSEG-MENGE = XLIPS-LGMNG.
    XMSEG-MEINS = XLIPS-MEINS.

    IF NOT XLIPS-BWART IS INITIAL.
      IF XLIPS-BWART NE T156N-BWART.
        SELECT SINGLE * FROM T156N WHERE FCODE EQ 'WEUB'
                                     AND BWART EQ XLIPS-BWART.
        IF SY-SUBRC NE 0.
          CLEAR T156N.
          MESSAGE I651 WITH T156N-FCODE T156N-BWART.
        ENDIF.
      ENDIF.
      XMSEG-BWART = T156N-BWART_NEXT.
    ENDIF.

*   Chargenpflicht im empfangenden Werk
    PERFORM MAEPV_SELECT(SAPFV50P) USING XLIPS-MATNR
                                         XMSEG-WERKS
                                         XMSEG-LGORT
                                         XLIPS-BERID           "n_987304
                                         SPACE
                                         SPACE
                                         SY-SUBRC.
    IF NOT MAEPV-XCHPF IS INITIAL.
      XMSEG-SOBKZ = MAEPV-XCHPF.
      XMSEG-CHARG = XLIPS-CHARG.
    ENDIF.

*   speichern mseg.
    BBE_EXIST = CHARX.
    APPEND XMSEG.
  ENDLOOP.

* setzen Fcode fuer Folgebild
  IF BBE_EXIST NE CHARX.
    MESSAGE E652.
  ENDIF.

* interpretieren Tabelle 158 wegen Selektionskennzeichen
  SELECT SINGLE * FROM T158 WHERE TCODE EQ T180-TCODE.
  IF SY-SUBRC EQ 0.
    IF T158-XSELE EQ CHARX.
      LOOP AT ILIPS.
        READ TABLE XMSEG INDEX ILIPS-TABIX.
        ILIPS-SELKZ = CHARX.
        MODIFY ILIPS.
      ENDLOOP.
    ENDIF.
  ENDIF.

* setzen Folgefcode
  FCODE = 'UEWE'.

ENDFORM.