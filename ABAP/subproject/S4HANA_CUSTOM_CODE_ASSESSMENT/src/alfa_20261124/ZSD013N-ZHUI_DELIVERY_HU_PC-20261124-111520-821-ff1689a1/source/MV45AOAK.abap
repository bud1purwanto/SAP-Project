************************************************************************
*                                                                      *
* PAI Module Auftragsababwicklung                                      *
*     Module alphabetisch geordnet; hier Datei VBAK                    *
*                                                                      *
************************************************************************


*&---------------------------------------------------------------------*
*&      Module  VBAK_BEARBEITEN_VOR  OUTPUT
*&---------------------------------------------------------------------*
*       Bearbeiten des Auftragskopfes                                 *
*----------------------------------------------------------------------*
MODULE VBAK_BEARBEITEN_VOR OUTPUT.

  PERFORM VBAK_BEARBEITEN_VORBEREITEN(SAPFV45K).
ENHANCEMENT-POINT VBAK_BEARBEITEN_VOR_10 SPOTS ES_SAPMV45A.
  Data: lv_lcnum type vbkd-lcnum.
  IF NOT FCODE_IFDH_ACTIVATED IS INITIAL AND
    vbkd-lcnum is initial.
    GET PARAMETER ID 'AKN' FIELD LV_LCNUM.
    IF NOT LV_LCNUM IS INITIAL.
      VBKD-LCNUM = LV_LCNUM.
      perform vbkd_kopf_bearbeiten(SAPFV45K).
    ENDIF.
    CLEAR FCODE_IFDH_ACTIVATED.
  ENDIF.
* Damit die kaufmännischen Daten auf Kopfebene immer eingabebereit
* sind, auch wenn es auf der Position nicht erlaubt ist.
* Relevant vor allem für Übersichtsbilder
  CLEAR VBAP.

ENDMODULE.                 " VBAK_BEARBEITEN_VOR  OUTPUT