*----------------------------------------------------------------------*
*   INCLUDE MM07MFK1                                                   *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       FORM KONSIENTWICKLUNG_GENERIEREN
*----------------------------------------------------------------------*
*       Die Konsignationsentwicklung wird generiert.
*----------------------------------------------------------------------*
FORM konsientwicklung_generieren using segindex like sy-tabix.
  CLEAR xrkwa.
  MOVE-CORRESPONDING zdm07m TO xrkwa.
  MOVE-CORRESPONDING xvm07m TO xrkwa.
  MOVE-CORRESPONDING xmkpf TO xrkwa.
  MOVE-CORRESPONDING xmseg TO xrkwa.
  IF tcurm-konsi IS INITIAL.
    xrkwa-bwaer = xmseg-waers.
    xrkwa-bstmg = xmseg-menge.
    xrkwa-bstme = xmseg-meins.
  ENDIF.
  xrkwa-wrbtr = xvm07m-netwr.
  xrkwa-mwskz = xvm07m-mb_mwskz.

  read table ymbuz index segindex.
  if not sy-subrc is initial.
    message e001 with 'YMBUZ' xmseg-zeile.
  endif.
ENHANCEMENT-POINT MM07MFK1_01 SPOTS ES_MM07MFK1 INCLUDE BOUND.

ENHANCEMENT-SECTION     MM07MFK1_02 SPOTS ES_MM07MFK1 INCLUDE BOUND .
  LOOP AT yfbuz WHERE zeile = ymbuz-zeilz
                AND   ktosl = 'KON'.
    xrkwa-shkzg = yfbuz-shkzg.
    xrkwa-hkont = yfbuz-hkont.
    xrkwa-gsber = yfbuz-gsber.
    xrkwa-prctr = yfbuz-prctr.
    IF tcurm-konsi IS INITIAL.
      xrkwa-wrbtr = yfbuz-dmbtr.
    ENDIF.
  ENDLOOP.
  CHECK sy-subrc IS INITIAL.                 "Nur bewertungsrelevant
  CLEAR: xrkwa-status, xrkwa-belnr, xrkwa-gjahr, xrkwa-buzei.
  APPEND xrkwa.
END-ENHANCEMENT-SECTION.
ENDFORM.