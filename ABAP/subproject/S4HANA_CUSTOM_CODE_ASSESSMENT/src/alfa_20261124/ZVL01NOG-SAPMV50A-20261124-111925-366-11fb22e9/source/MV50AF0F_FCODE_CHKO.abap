*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_CHKO                                        *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_CHKO                                               *
*---------------------------------------------------------------------*
*       korrigieren der Chargenfindung auf Splitbild                  *
*---------------------------------------------------------------------*
FORM FCODE_CHKO.

data: lf_msgty like sy-msgty value 'E',                      "v_n_504233
      lf_rcode like sy-subrc.                                "^_n_504233

*...Positionierung der xlips sicherstellen
  READ TABLE XLIPS with key vbeln = clips-vbeln
                            posnr = clips-posnr.

*... Chargenfindung möglich?
  IF LIKP-KALSM_CH IS INITIAL.
    MESSAGE I218.
    EXIT.
  ENDIF.

*... Artikel gesperrt
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
*...   Material chargenpflichtig?
  IF XLIPS-XCHPF IS INITIAL.
    MESSAGE I162.
    EXIT.
  ENDIF.

*... Derzeit keine Chargenfindung bei Sonderbeständen außer E, V und W
  IF NOT ( XLIPS-SOBKZ IS INITIAL OR XLIPS-SOBKZ = 'E' OR
           XLIPS-SOBKZ = 'V'      OR XLIPS-SOBKZ = 'W' OR   "v_n_1066711
           XLIPS-SOBKZ = 'Q' ).                             "^_n_1066711
    MESSAGE I197.
    EXIT.
  ENDIF.

*...   WA schon gebucht?
  IF XVBUP-WBSTA = 'C'.
    MESSAGE S602.
    EXIT.
  ENDIF.

*...                            Kopfstatus der Lieferung aktualisieren
  PERFORM XVBUK_PFLEGEN(SAPFV50K).

*...  Positionsstatus der Lieferung lesen
  PERFORM XVBUP_LESEN(SAPFV50P) USING CLIPS-VBELN
                                      CLIPS-POSNR.

*...  Faktura erfolgt?
  IF XVBUK-FKSTK CA 'BC'.
*   MESSAGE S186.                                            "v_n_504233
*  EXIT.
* ENDIF.

     perform message_handling_variabel
                                using lips-posnr
                                      '186'
                                      lf_msgty
                                      'VL'
                                      space
                                      space
                                      space
                                      space
                                      gs_mhpar
                                      v50agl-msgvs
                             changing lf_msgty
                                      lf_rcode.
     if lf_msgty ca 'AEX'.
       exit.
     endif.
  endif.                                                     "^_n_504233


*...  LVS aktiv?
  IF XVBUP-LVSTA = 'B'.
    MESSAGE S235.
    EXIT.
  ENDIF.

*...  LVS fertig?
  IF XVBUP-LVSTA = 'C'.
    MESSAGE I236.
  ENDIF.

*...  gibt es offene Kommiaufträge ?
  IF XVBUP-KOQUA = 'B' AND XVBUP-LVSTA = SPACE.
    MESSAGE S237.
    EXIT.
  ENDIF.

*...  Kommissionierung quittiert ?
  IF XVBUP-KOQUA = 'C' AND XVBUP-LVSTA = SPACE.
    MESSAGE I238.
  ENDIF.

  PERFORM CHARGENFINDUNG(SAPFV50D) USING 'K'.

ENDFORM.