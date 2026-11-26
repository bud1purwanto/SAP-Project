***INCLUDE FV50XF0B_BELEG_KOMMILISTE_ANST .
*---------------------------------------------------------------------*
*       FORM BELEG_KOMMILISTE_ANSTOSSEN                               *
*---------------------------------------------------------------------*
*       Es wird geprüft, ob für die Lieferung eine Kommissioniernach- *
*       richt nötig ist und falls ja, wird eine NAST-Anforderung      *
*       aufgebaut                                                     *
*                                                                     *
*       Der aktuelle Kopf steht in XLIKP                              *
*---------------------------------------------------------------------*
FORM BELEG_KOMMILISTE_ANSTOSSEN.
  TABLES: VBLKK.
  DATA: BEGIN OF TVBLKP OCCURS 0.
          INCLUDE STRUCTURE VBLKP.
  DATA: END OF TVBLKP.
  DATA: BKA_POS TYPE C.
  DATA: NRIV_NUMBER(10).

  CHECK XLIKP_UPDKZ NE UPDKZ_DELETE.
  CHECK NO_MESSAGES_UPDATE = SPACE.

* ist für diese Versandstelle der Kommilistendruck aktiv?
  IF TVST-VSTEL <> XLIKP-VSTEL.
    SELECT SINGLE * FROM TVST WHERE VSTEL = XLIKP-VSTEL.
  ENDIF.
  IF TVST-KSCHL EQ SPACE.
    EXIT.
  ENDIF.

* muß eine Kommissionierliste gedruckt werden?
  VBUKKEY-MANDT = XLIKP-MANDT.
  VBUKKEY-VBELN = XLIKP-VBELN.
  READ TABLE XVBUK WITH KEY VBUKKEY BINARY SEARCH.

* Kommissioniersperre
  IF XLIKP-LIFSK <> TVLS-LIFSP.
    SELECT SINGLE * FROM TVLS WHERE LIFSP = XLIKP-LIFSK.
    IF SY-SUBRC <> 0. CLEAR TVLS. ENDIF.
  ENDIF.

  IF XVBUK-KOSTK EQ SPACE OR           "nicht zu kommissionieren
     XVBUK-KOSTK EQ CHARC OR           "voll kommissioniert
     TVLS-SPEKO NE SPACE.              "Kommissioniersperre
    BKA_POS = SPACE.
    read table yvbuk transporting no fields                    "n_529544
                     with key vbeln = xlikp-vbeln.
    check sy-subrc eq 0.
  ELSE.                                "etwas ist zu kommissionieren
    IF XVBUK-LVSTK EQ SPACE.           "nicht mit LVS
      BKA_POS = CHARX.
    ELSE.                              "teilweise/ganz mit LVS
      BKA_POS = SPACE.
      LOOP AT XLIPS WHERE VBELN EQ XLIKP-VBELN.
        IF XLIPS-KOMKZ = CHARA  OR
           XLIPS-KOMKZ = CHARB.
          PERFORM XVBUP_LESEN(SAPFV50P) USING XLIKP-VBELN XLIPS-POSNR.
          IF XVBUP-KOSTA NE CHARC.
            BKA_POS = CHARX.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

* beschaffen der Druckparameter
*  IF TVST-NACHA EQ '1'.                "v N442278 (needs T685B)
   IF TVST-NACHA CA '15'.               "^ N442278
    IF TVST-KSCHL NE TNAD5-KSCHL OR
       LIKP-VSTEL NE TNAD5-VSTEL.

      SELECT SINGLE * FROM TNAD5 WHERE KAPPL = 'V4'       AND
                                       KSCHL = TVST-KSCHL AND
                                       VSTEL = LIKP-VSTEL.
      IF SY-SUBRC NE 0.
        CLEAR: TNAD5.
        EXIT.
      ENDIF.
    ENDIF.
    IF T685B-KSCHL NE TVST-KSCHL.
      SELECT SINGLE * FROM T685B WHERE KAPPL = 'V4'
                                 AND   KSCHL = TVST-KSCHL.
      IF SY-SUBRC NE 0 OR
         TNAD5-LDEST IS INITIAL.
        CLEAR T685B.
      ENDIF.
    ENDIF.
  ENDIF.

* erzeugen NAST-Satz
  CLEAR NAT.
  NAT-TCODE = T685B-STRATEGY.
  MOVE-CORRESPONDING TVST  TO NAT.                             "SADR40A
  IF TVST-NACHA CA '15'.                                     "n_1243443
    MOVE-CORRESPONDING TNAD5 TO NAT.
    NAT-TDARMOD = T685B-TDARMOD.
  ENDIF.
  NAT-MANDT = XLIKP-MANDT.
  NAT-KAPPL = 'V4'.
  NAT-OBJKY = XLIKP-VBELN.
  LIKP = XLIKP.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
            INPUT  = XLIKP-VSTEL
       IMPORTING
            OUTPUT = NAT-PARNR
       EXCEPTIONS
            OTHERS = 9.

  NAT-PARVW = '01'.
  NAT-VSDAT = XLIKP-KODAT.
* line deleted                                                 n_614627
* bestimmen der notwendigen Aktion
  IF BKA_POS EQ CHARX.
    APPEND NAT.                                               "n_614627
    CALL FUNCTION 'RV_MESSAGES_INSERT'
         TABLES
              TAB_XNAST = NAT.
  ELSE.
    CALL FUNCTION 'RV_MESSAGES_DELETE_PARTNER'
         EXPORTING
              MSG_OBJKY = NAT-OBJKY
              MSG_PARNR = NAT-PARNR
              MSG_PARVW = NAT-PARVW.
  ENDIF.

ENDFORM.