*---------------------------------------------------------------------*
*       FORM N_TEXT_SYMBOL_REPLACE                                     *
*---------------------------------------------------------------------*
*       Textvariablenersetzung                                        *
*---------------------------------------------------------------------*
FORM N_TEXT_SYMBOL_REP TABLES XTLINES STRUCTURE TLINE
                       USING  XTHEAD STRUCTURE THEAD
                              SNAST  STRUCTURE NAST.
DATA: LV_VBELN LIKE VBAK-VBELN,
      LV_POSNR LIKE VBAP-POSNR.
* Besorgen der Positionsdaten
  IF T180-TRTYP EQ CHARH.
    LV_VBELN = SPACE.
  ELSE.
    LV_VBELN = SNAST-OBJKY.
  ENDIF.
  LV_POSNR = SNAST-OBJKY+10(6).
  LOOP AT XVBAP WHERE VBELN EQ LV_VBELN
                AND POSNR EQ LV_POSNR
                AND UPDKZ NE UPDKZ_DELETE.
    EXIT.
  ENDLOOP.
  CHECK SY-SUBRC = 0.
  PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
* Textsymbolersetzung
  PERFORM TEXT_SYMBOL_REPLACE TABLES XTLINES
                                     USING XTHEAD
                                           SNAST.

ENDFORM.