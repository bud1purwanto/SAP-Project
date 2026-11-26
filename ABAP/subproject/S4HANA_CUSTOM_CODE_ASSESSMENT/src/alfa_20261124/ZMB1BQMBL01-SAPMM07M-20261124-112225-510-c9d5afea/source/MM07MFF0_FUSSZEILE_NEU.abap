*eject
*---------------------------------------------------------------------*
*        FORM FUSSZEILE_NEU                                           *
*---------------------------------------------------------------------*
*        Die Erfassung einer neuen Fusszeile wird eingeleitet.        *
*---------------------------------------------------------------------*
FORM fusszeile_neu.
  CHECK t158-trtyp = h.
  PERFORM steuerflags_initialisieren(sapfm07m).
  CHECK fcausw-xneup NE space OR fcausw-xselp NE space OR
        NOT t063c-aufruf IS INITIAL.
  IF NOT bcode IS INITIAL.
    IF rm07m-kzbew IS INITIAL AND xkzbew IS INITIAL.
      IF NOT t063c-aufruf IS INITIAL.
        old_bwartwa = rm07m-bwartwa.
        old_sobkz   = rm07m-sobkz.
      ENDIF.
      rm07m-bwart = rm07m-bwartwa = bcode-bwart.
      rm07m-sobkz = bcode-sobkz.
    ELSE.
      rm07m-bwart = rm07m-bwartwe = bcode-bwart.
    ENDIF.
  ELSE.
    IF NOT next_xkzbew IS INITIAL AND anf_bild IS INITIAL.
      IF t158-kzbew = b AND t158b-bwart NE rm07m-bwart.
        SELECT SINGLE * FROM t158b WHERE tcode = sy-tcode
                                   AND   bwart = rm07m-bwart.
      ENDIF.
      IF t158b-xkzbew = 3.
        IF ccode = ccod-nfsl.
          CLEAR ccode.
          fcode_next = old_fcode.
          MESSAGE w019 WITH rm07m-bwart rm07m-sobkz.
          EXIT.
        ENDIF.
        rm07m-kzbew = b.
        next_xkzbew = 3.
      ELSEIF t158b-xkzbew = 1.
        CLEAR rm07m-kzbew.
        next_xkzbew = 1.
      ENDIF.
    ENDIF.
    IF rm07m-kzbew IS INITIAL.
      rm07m-bwart = rm07m-bwartwa.
    ELSE.
      rm07m-bwart = rm07m-bwartwe.
    ENDIF.
  ENDIF.
  IF NOT anf_bild IS INITIAL.
    IF t063c-aufruf = x AND NOT t063f-xneup IS INITIAL AND
       NOT rm07m-bwart IS INITIAL AND t063c-ccode = ccod-nfnl.
      IF t156-bwart IS INITIAL.
        PERFORM bewegungsart_lesen(sapfm07m) USING rm07m-bwart.
      ENDIF.
      CLEAR: t063o, t063c, ccode.
*     IF NOT t156-kzbwa IS INITIAL AND t156-kzbwa NE kzbwa-02.  "208873
*                   * Einstieg über BWA 317, 319 ist erlaubt    "208873
      IF NOT t156-kzbwa IS INITIAL AND t156-kzbwa NE kzbwa-02   "208873
                                   AND t156-kzbwa NE kzbwa-sz.  "208873
        MESSAGE e019 WITH rm07m-bwart.
      ENDIF.
    ENDIF.
  ENDIF.
  IF t063c-aufruf = x.
    IF NOT rm07m-werks IS INITIAL.
      DATA: L_GRUND LIKE RM07M-GRUND.
*     save reason for movement. reason should only be taken from
*     default in t159l in case of physical inventory.
      L_GRUND = RM07M-GRUND.
      SELECT SINGLE * FROM t159l WHERE werks = rm07m-werks.
      MOVE-CORRESPONDING t159l TO rm07m.
      RM07M-GRUND = L_GRUND.
    ENDIF.
    ccode = t063c-ccode.
    IF ccode EQ ccod-nfsl.
      IF rm07m-bwart IS INITIAL.
        PERFORM no_input(sapfm07m) USING 'MSEG' 'BWART'.
      ELSEIF rm07m-werks IS INITIAL.
        PERFORM no_input(sapfm07m) USING 'MSEG' 'WERKS'.
      ENDIF.
      MOVE-CORRESPONDING rm07m TO mseg.
      msegk-sobkz = rm07m-sobkz.
      PERFORM fusszeile_bew_pruefen.
      PERFORM fuss_ergaenzen.
    ENDIF.
    CLEAR t063c-ccode.
    PERFORM dynpro_call.
    IF abbrechen = x AND NOT anf_bild IS INITIAL.
      CLEAR: abbrechen, t063o, t063c, t063f, xsele, ccode.
      SET SCREEN sy-dynnr.
      LEAVE SCREEN.
    ENDIF.
  ELSE.
    CHECK fcausw-xselp IS INITIAL.
    IF rm07m-kzbew IS INITIAL OR
       ( fcode = fcod-nl AND rm07m-kzbew = b ).
      IF anf_bild IS INITIAL.
        PERFORM bewegungsart_pruefen(sapfm07m) USING rm07m-bwart
                                                     space.
        IF t156-kzbwa IS INITIAL.
          rm07m-bukrs = mseg-bukrs.
        ELSE.
          IF bcode-bwart IS INITIAL.
            bcode-bwart = rm07m-bwartwa.
            bcode-sobkz = rm07m-sobkz.
          ENDIF.
          IF t156-kzbwa = kzbwa-01 OR t156-kzbwa = kzbwa-05.
            SELECT SINGLE * FROM t063c WHERE ccode = ccod-nful.
            IF NOT sy-subrc IS INITIAL.
              MESSAGE e001 WITH 'T063C' 'NFUL'.
            ENDIF.
            ccode = t063c-ccode.
            fcode_next = fcod-sl.
            PERFORM dynpro_call.
          ENDIF.
          EXIT.
        ENDIF.
      ELSE.
        IF rm07m-werks IS INITIAL.
          PERFORM no_input(sapfm07m) USING 'RM07M' 'WERKS'.
        ENDIF.
        PERFORM werk_pruefen(sapfm07m) USING    x
                                            rm07m-werks
                                            vm07m-bwkey
                                            dm07m-bwmod
                                            dm07m-xeink
                                            dm07m-xbkng
                                            vm07m-xvkbw
                                            rm07m-bukrs
                                            dm07m-ktopl
                                            dm07m-periv
                                             mseg-waers
                                             mkpf-budat
                                             mseg-gjahr
                                            vm07m-monat
                                             mseg-xruem
                                             mseg-xruej
                                            vm07m-lfgja
                                            vm07m-lfmon
                                            dm07m-fabkl
                                            dm07m-kzxab.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.