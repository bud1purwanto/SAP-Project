*eject
*---------------------------------------------------------------------*
*       FORM RESERVIERUNG_FANGSCHALTUNG                               *
*---------------------------------------------------------------------*
*       Prüfen, ob ENMNG = 0 sinnvoll ist.                            *
*---------------------------------------------------------------------*
FORM reservierung_fangschaltung.
  DATA: enmng_d1 LIKE xmres-enmng,
        enmng_d2 LIKE xmres-enmng,
        enmng_d3 LIKE xmres-enmng.
ENHANCEMENT-POINT RESERVIERUNG_FANGSCHALTUNG_01 SPOTS ES_SAPMM07M.
  LOOP AT xmres WHERE enmng IS INITIAL.
    CLEAR: enmng_d1,
           enmng_d2,
           enmng_d3.

     LOOP AT xmseg WHERE rsnum = xmres-rsnum
                    AND   rspos = xmres-rspos
                    AND   rsart = xmres-rsart
                    AND   xauto IS INITIAL.
      READ TABLE ymbuz INDEX xmseg-zeile.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE a001 WITH 'YMBUZ' xmseg-zeile.
      ENDIF.
      READ TABLE zdm07m INDEX ymbuz-zeile TRANSPORTING rshkz.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE a001 WITH 'ZDM07M' ymbuz-zeile.
      ENDIF.
      IF zdm07m-rshkz = xmseg-shkzg.
        enmng_d1 = enmng_d1 + xmseg-menge.
      ELSE.
        enmng_d2 = enmng_d2 + xmseg-menge.
      ENDIF.
    ENDLOOP.
    enmng_d3 = xmres-enmng_old + enmng_d1 - enmng_d2.
    IF enmng_d3 NE xmres-enmng.
      MESSAGE a599 WITH xmres-rsnum xmres-rspos xmres-rsart.
    ENDIF.
  ENDLOOP.
ENDFORM.