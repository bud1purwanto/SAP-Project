*---------------------------------------------------------------------*
*       FORM NMAILAKTIONSPARAMETER                                    *
*---------------------------------------------------------------------*
*       Parameter der Mailaktion ersetzen
*----------------------------------------------------------------------*
FORM N_MAIL_PARAMETER USING PARAFELD PARAWERT
                            PNAST STRUCTURE NAST.

DATA: LV_VBELN LIKE VBAK-VBELN,
      LV_POSNR LIKE VBAP-POSNR.
* Besorgen der Positionsdaten
  IF T180-TRTYP EQ CHARH.
    LV_VBELN = SPACE.
  ELSE.
    LV_VBELN = PNAST-OBJKY.
  ENDIF.
  LV_POSNR = PNAST-OBJKY+10(6).
  LOOP AT XVBAP WHERE VBELN EQ LV_VBELN
                AND POSNR EQ LV_POSNR
                AND UPDKZ NE UPDKZ_DELETE.
    EXIT.
  ENDLOOP.
  CHECK SY-SUBRC = 0.
  PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
* Textsymbolersetzung
  PERFORM MAILAKTIONSPARAMETER USING PARAFELD PARAWERT
                                     PNAST.

ENDFORM.