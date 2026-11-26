***INCLUDE MV50AF0F_FCODE_CHSL .
*---------------------------------------------------------------------*
*       FORM FCODE_CHSL                                               *
*---------------------------------------------------------------------*
*       Chargenselektion auf Splitbild                                *
*---------------------------------------------------------------------*
FORM FCODE_CHSL.

  DATA: DA_SUBRC LIKE SY-SUBRC.
  DATA ATP_TYPE TYPE LES_ATP_TYPE.
  CALL FUNCTION 'LE_ATP_GET_VERSION'
      IMPORTING
           ATP_TYPE         = ATP_TYPE.

  IF ATP_TYPE EQ CHARO.
    PERFORM BEDARF_LESEN(SAPFV50V)
            USING LIPS-MATNR CLIPS-MTVFP CLIPS-WERKS
                  CLIPS-VBELN CLIPS-POSNR CLIPS-VPMAT
                  CLIPS-VPWRK
                  CLIPS-BEDAR_LF SPACE DA_SUBRC.
  ELSE.
    PERFORM BEDARF_LESEN_NEU CHANGING DA_SUBRC.
  ENDIF.

  IF  DA_SUBRC NE 0.
    MESSAGE S155 WITH LIPS-MATNR.
    EXIT.
  ENDIF.


*...   Selektion noch durchführbar ?
*...   Material bewertungsartenabhängig oder chargenpflichtig?
  IF XLIPS-XCHAR IS INITIAL.
    MESSAGE I162.
    EXIT.
  ENDIF.

*... keine Chargenselektion bei Sonderbeständen !
  IF NOT XLIPS-SOBKZ IS INITIAL.
    MESSAGE I197.
    EXIT.
  ENDIF.

*...   WA schon gebucht?
  IF XVBUP-WBSTA = 'C'.
    MESSAGE S602.
    EXIT.
  ENDIF.

*...   WM noch aktiv?
  IF XVBUP-LVSTA = 'B'.
    MESSAGE S620.
    EXIT.
  ENDIF.

*   Lagerort?
  IF CLIPS-LGORT IS INITIAL.
    MESSAGE S604 WITH  CLIPS-POSNR.
    EXIT.
  ENDIF.

*...           Ermitteln der Mengen, die bereits verfügt wurden
  REFRESH SEL_CHARGEN.
  CLEAR SEL_CHARGEN.
  LOOP AT XLIPS.
    CHECK XLIPS-UPDKZ <> 'D'.          " gelöscht Position
    CHECK XLIPS-UPDKZ <> ' '.          " nicht verändert
    IF CLIPS-MATNR = XLIPS-MATNR AND
       CLIPS-WERKS = XLIPS-WERKS AND
       CLIPS-LGORT = XLIPS-LGORT AND
       NOT XLIPS-CHARG IS INITIAL.
      SEL_CHARGEN-CHARG = XLIPS-CHARG.
      IF XLIPS-UPDKZ = 'I'.            " neue Position
        SEL_CHARGEN-MENGE = XLIPS-LGMNG.
      ELSE.                            " geänderte Position
        IF XLIPS-UPDKZ = 'D'.          " gelöschte Position
          CLEAR YLIPS.
          READ TABLE YLIPS WITH KEY VBELN = XLIPS-VBELN
                                    POSNR = XLIPS-POSNR.
          IF SY-SUBRC = 0.
            SEL_CHARGEN-MENGE =  - YLIPS-LGMNG.
          ELSE.                        " hier ist ein Fehler!!
            SEL_CHARGEN-MENGE = XLIPS-LGMNG.
          ENDIF.
        ELSE.
          IF XLIPS-UPDKZ = 'U'.        " gelöschte Position
            CLEAR YLIPS.
            READ TABLE YLIPS WITH KEY VBELN = XLIPS-VBELN
                                      POSNR = XLIPS-POSNR.
            IF SY-SUBRC = 0.
              SEL_CHARGEN-MENGE = XLIPS-LGMNG - YLIPS-LGMNG.
            ELSE.                      " hier ist ein Fehler!!
              SEL_CHARGEN-MENGE = XLIPS-LGMNG.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      COLLECT SEL_CHARGEN.
    ENDIF.
  ENDLOOP.

*...           Aufruf der Chargenselektion
  CALL FUNCTION 'SD_BATCH_QUANTITY'
       EXPORTING
            CH_MATNR = CLIPS-MATNR
            CH_WERKS = CLIPS-WERKS
            CH_LGORT = CLIPS-LGORT
            CH_MEINS = CLIPS-MEINS
            CH_LFDAT = LIKP-LFDAT
*           Uhrzeiten bei Chargen nicht relevant
       TABLES
            CH_BATCH = SEL_CHARGEN.


*...   Aufruf des Chargengenerierens
  SAVE_CLIPS = CLIPS.

  LOOP AT SEL_CHARGEN.
    CLEAR LIPS.
    CLEAR: *LIPS,
          HLIPS,
          XLIPS,
          LIPS,
          LIPSD.
    LIPS-MATNR = CLIPS-MATNR.
    LIPS-WERKS = CLIPS-WERKS.

    LIPS-CHARG = SEL_CHARGEN-CHARG.
    SLIPS-TABIX = 0.
    PERFORM USEREXIT_BATCH_QUAN_ALLOCATION.
    PERFORM LIPS_CHARGEN_SPLIT_BEARBEITEN(SAPFV50P)
                                     USING SPACE.            "SP_375923
  ENDLOOP.

*... wurde eine Charge selektiert?
  IF SY-SUBRC > 0.
    MESSAGE I225.
  ELSE.

    SAVE_ILIPS_TABIX = ILIPS_TABIX_AKTUELL.
    SAVE_ILIPS_POSNR = ILIPS-POSNR.
    PERFORM POSITION_GEWICHTSUPDATE_CHSP(SAPFV50P) USING SPACE.
    IF SAVE_ILIPS_TABIX NE 0.
      READ TABLE ILIPS INDEX SAVE_ILIPS_TABIX.
      IF SAVE_ILIPS_POSNR NE ILIPS-POSNR.
        READ TABLE ILIPS WITH KEY SAVE_ILIPS_POSNR BINARY SEARCH.
      ENDIF.
      READ TABLE XLIPS INDEX ILIPS-TABIX.
    ENDIF.
  ENDIF.
ENDFORM.