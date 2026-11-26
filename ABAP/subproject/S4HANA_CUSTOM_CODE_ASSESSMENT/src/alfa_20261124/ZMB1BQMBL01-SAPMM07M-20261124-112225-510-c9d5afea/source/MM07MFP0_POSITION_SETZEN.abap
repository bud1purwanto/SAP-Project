*eject
*---------------------------------------------------------------------*
*       FORM POSITION_SETZEN                                          *
*---------------------------------------------------------------------*
*       Setzen der Positionsnummer beim Erfassen von Warenbewegungen  *
*       ueber Liste                                                   *
*       Setzen der darstellbaren Loopzeilen aus SY-LOOPC. (MAX_ANZPO) *
*---------------------------------------------------------------------*
FORM POSITION_SETZEN.

  MAX_ANZPO = SY-LOOPC.
  IF XPF02 = X.
    READ TABLE OLD INDEX 1.
    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING OLD TO MSEG.
      DM07M-MAKTX = OLD-MAKTX.
      RM07M-XSELK = OLD-XSELK.
      DELETE OLD INDEX 1.
    ELSE.
      IF FCAUSW-XLIST NE SPACE.
        EXIT FROM STEP-LOOP.
      ENDIF.
    ENDIF.
  ELSE.
    IF FCAUSW-XNEUP IS INITIAL.
      IF A_ZEILE < 1.
        A_ZEILE = 1.
      ENDIF.
      PERFORM SEGMENT_UEBERNEHMEN USING O.
      IF SY-STEPL = 1 AND NOT MSEG-MATNR IS INITIAL.
        XMATE = X.
      ENDIF.
      IF AUFSETZEN IS INITIAL.
        AUFSETZEN = MSEG-ZEILE.
      ENDIF.
      IF RC IS INITIAL.
        IF NOT FCAUSW-XSELP IS INITIAL.
          RM07M-XSELK = FUSS-XSELK.
        ENDIF.
        L_ZEILE = A_ZEILE.
        A_ZEILE = A_ZEILE + 1.
        IF ( NOT FCAUSW-XAENP IS INITIAL OR
             NOT FCAUSW-XSELP IS INITIAL ).
          IF T158-KZBEW IS INITIAL OR XKZBEW = 1 OR
             XKZBEW = 3.
            IF FCAUSW-XSELP NE SPACE AND NOT FCAUSW-XLIST IS INITIAL.
              MOVE-CORRESPONDING FUSS TO BILD.
            ELSEIF FCAUSW-XAENP NE SPACE.
              MOVE-CORRESPONDING MSEG TO BILD.
            ENDIF.
            APPEND BILD.
          ELSE.
            IF NOT FCAUSW-XSELP IS INITIAL.
              MOVE-CORRESPONDING FUSS TO BIWE.
            ENDIF.
            IF FCAUSW-XAENP NE SPACE.
              MOVE-CORRESPONDING MSEG TO BIWE.
              BIWE-MHDAT = DM07M-MHDAT.
              BIWE-VFDAT_INPUT = DM07M-VFDAT_INPUT.
              BIWE-HSDAT_INPUT = DM07M-HSDAT_INPUT.
              BIWE-EAN11_BME = DM07M-EAN11_BME.
              BIWE-IDNLF = DM07M-IDNLF.
            ENDIF.
            APPEND BIWE.
          ENDIF.
        ENDIF.
      ELSE.
        IF ( NOT T158-KZBEW IS INITIAL AND XKZBEW IS INITIAL )
           OR T158-TRTYP NE H OR VGART_OLD IS INITIAL.
          IF NOT FCAUSW-XLIST IS INITIAL.
            EXIT FROM STEP-LOOP.
          ENDIF.
        ELSE.
          IF NOT FCAUSW-XLIST IS INITIAL AND
             FCAUSW-XAENP IS INITIAL AND
             FCAUSW-XNEUP IS INITIAL OR RC = EINS OR NOT MSEGK-RSNUM
             IS INITIAL OR ( NOT MSEGK-EBELN IS INITIAL
             AND MSEGK-EBELN NE AUTO_BEST ).
            EXIT FROM STEP-LOOP.
          ENDIF.
          IF NEUE_POS IS INITIAL.
            A_ZEILE = A_ZEILE - 1.
          ENDIF.
          NEUE_POS = X.
        ENDIF.
      ENDIF.
    ELSE.
      NEUE_POS = X.
    ENDIF.
    IF NEUE_POS = X.
      IF A_ZEILE < MAX_ZEILE.
        IF NOT FCAUSW-XLIST IS INITIAL.
          data: h_jahr like mseg-gjahr.
          h_jahr = mseg-gjahr.
          DATA: H_PARBU LIKE MSEG-PARBU.          "note 0318466
          H_PARBU = MSEG-PARBU.                   "note 0318466
          CLEAR MSEG.                             "note 0135947
          MSEG-GJAHR = H_JAHR.                    "note 0135947
          MSEG-PARBU = H_PARBU.                   "note 0318466
          MSEG-WERKS = RM07M-WERKS.
          MSEG-LGORT = RM07M-LGORT.
          MSEG-SOBKZ = RM07M-SOBKZ.
          MSEG-BWART = RM07M-BWART.
        ENDIF.
        A_ZEILE = A_ZEILE + 1.
        MSEG-ZEILE = A_ZEILE.
        IF AUFSETZEN IS INITIAL.
          AUFSETZEN = MSEG-ZEILE.
        ENDIF.
      ELSE.
        IF FCAUSW-XLIST NE SPACE.
          EXIT FROM STEP-LOOP.
        ENDIF.
        FCODE = FCOD-AB.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.