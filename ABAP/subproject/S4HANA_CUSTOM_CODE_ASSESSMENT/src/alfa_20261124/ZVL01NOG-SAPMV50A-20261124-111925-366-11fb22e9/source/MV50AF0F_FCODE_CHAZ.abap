*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_CHAZ                                        *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_CHAZ                                               *
*---------------------------------------------------------------------*
*       Anzeigen der Chargenfindung auf Splitbild                     *
*---------------------------------------------------------------------*
FORM FCODE_CHAZ.

*...Positionierung der xlips sicherstellen
  READ TABLE XLIPS with key vbeln = clips-vbeln
                            posnr = clips-posnr.

*... Chargenfindung möglich?
  IF LIKP-KALSM_CH IS INITIAL.
    MESSAGE I218.
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

  PERFORM CHARGENFINDUNG(SAPFV50D) USING 'Z'.

ENDFORM.