*----------------------------------------------------------------------*
*   INCLUDE FV50XF0K_KOMKG_KOMPG_FUELLEN                               *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM KOMKG_KOMPG_FUELLEN.                                     *
*---------------------------------------------------------------------*
*       Zur Vorbereitung von Artikellistung und Ausschluß             *
*       wird der Kommunikationsbereich KOMKG und KOMPG gefüllt        *
*                                                                     *
*---------------------------------------------------------------------*
FORM KOMKG_KOMPG_FUELLEN.

  CLEAR: KOMKG.
* Kundendaten gemäß Kopf bereitstellen
* PERFORM KUWEV_SELECT_XVBPA(SAPMV45A).
* KOMKG füllen
  MOVE-CORRESPONDING KUWEV TO KOMKG.
  MOVE-CORRESPONDING LIKP  TO KOMKG.
  KOMKG-KUNAG = LIKP-KUNAG.
  IF KOMKG-KUNAG IS INITIAL.
    KOMKG-KUNAG = KUWEV-KUNNR.
  ENDIF.
  KOMKG-KUNWE = KUWEV-KUNNR.
  KOMKG-KUNNR = LIKP-KUNAG.
  IF KOMKG-KUNNR IS INITIAL.
    KOMKG-KUNNR = KUWEV-KUNNR.
  ENDIF.
  KOMKG-BUKRS = TVKO-BUKRS.
  IF LIPS-WERKS NE SPACE.
    PERFORM T001W_SELECT(SAPMV45A) USING LIPS-WERKS
                                         SPACE
                                         SY-SUBRC.
  ELSE.
    IF KUWEV-DWERK NE SPACE.
      PERFORM T001W_SELECT(SAPMV45A) USING KUWEV-DWERK
                                           SPACE
                                           SY-SUBRC.
    ENDIF.
  ENDIF.
  IF SY-SUBRC = 0.
    KOMKD-ALAND   = T001W-LAND1.
    KOMKD-WKREG   = T001W-REGIO.
    KOMKD-WKCOU   = T001W-COUNC.
    KOMKD-WKCTY   = T001W-CITYC.
  ENDIF.

  IF NOT LIPS-VTWEG IS INITIAL AND
     NOT LIPS-SPART IS INITIAL.
     PERFORM TVTA_SELECT(SAPMV50A) USING LIKP-VKORG
                                         LIPS-VTWEG
                                         LIPS-SPART.
     KOMKG-VTWEG   = TVTA-VTWKU.
     KOMKG-SPART   = TVTA-SPAKU.
  ELSE.
    IF LIPS-VTWEG NE SPACE.
       PERFORM TVKOV_SELECT(SAPMV50A) USING LIKP-VKORG
                                            LIPS-VTWEG
                                            SY-SUBRC.
       IF SY-SUBRC EQ 0.
          KOMKG-VTWEG   = TVKOV-VTWKU.
       ENDIF.
    ENDIF.
  ENDIF.

  KOMKG-AUART   = TVAK-AUART.

* Userexit
  PERFORM USEREXIT_MOVE_FIELD_TO_KOMKG(SAPMV50A).

* KOMPG füllen
  CLEAR KOMPG.
  MOVE-CORRESPONDING LIKP  TO KOMPG.
  MOVE-CORRESPONDING LIPS  TO KOMPG.
  MOVE-CORRESPONDING LIPSD TO KOMPG.
  MOVE-CORRESPONDING MAAPV TO KOMPG.

* Userexit
  PERFORM USEREXIT_MOVE_FIELD_TO_KOMPG(SAPMV50A).

ENDFORM.