*----------------------------------------------------------------------*
*   INCLUDE FV50XF0K_KOMKD_KOMPD_FUELLEN                               *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM KOMKD_KOMPD_FUELLEN.                                     *
*---------------------------------------------------------------------*
*       Zur Vorbereitung von Artikelsubstitution                      *
*       wird der Kommunikationsbereich KOMKD und KOMPD gefüllt        *
*                                                                     *
*---------------------------------------------------------------------*
FORM KOMKD_KOMPD_FUELLEN.

  CLEAR: KOMKD.
* Kundendaten bereitstellen gemäß Belegkopf
* PERFORM KUWEV_SELECT_XVBPA(SAPMV45A).
* KOMKD füllen
  MOVE-CORRESPONDING KUWEV TO KOMKD.
  MOVE-CORRESPONDING LIKP  TO KOMKD.
  KOMKD-KUNAG = LIKP-KUNAG.
  IF KOMKD-KUNAG IS INITIAL.
    KOMKD-KUNAG = KUWEV-KUNNR.
  ENDIF.
  KOMKD-KUNWE = KUWEV-KUNNR.
  KOMKD-KUNNR = LIKP-KUNAG.
  IF KOMKD-KUNNR IS INITIAL.
    KOMKD-KUNNR = KUWEV-KUNNR.
  ENDIF.
  KOMKD-BUKRS = TVKO-BUKRS.
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
  KOMKD-AUART   = TVAK-AUART.
  IF NOT LIPS-VTWEG IS INITIAL AND                       "v_n_568614
     NOT LIPS-SPART IS INITIAL.
    PERFORM TVTA_SELECT(SAPMV50A) USING LIKP-VKORG
                                        LIPS-VTWEG
                                        LIPS-SPART.
    KOMKD-VTWEG   = TVTA-VTWKU.
    KOMKD-SPART   = TVTA-SPAKU.
  ELSEIF NOT RV50A-VTWEG IS INITIAL AND
         NOT RV50A-SPART IS INITIAL.
    PERFORM TVTA_SELECT(SAPMV50A) USING LIKP-VKORG
                                        RV50A-VTWEG
                                        RV50A-SPART.
    KOMKD-VTWEG   = TVTA-VTWKU.
    KOMKD-SPART   = TVTA-SPAKU.
  ENDIF.                                                 "^_n_568614

* Userexit
  PERFORM USEREXIT_MOVE_FIELD_TO_KOMKD(SAPMV50A).

* KOMPD füllen
  CLEAR KOMPD.
  MOVE-CORRESPONDING LIKP  TO KOMPD.
  MOVE-CORRESPONDING LIPS  TO KOMPD.
  MOVE-CORRESPONDING LIPSD TO KOMPD.
  MOVE-CORRESPONDING MAAPV TO KOMPD.

* Userexit
  PERFORM USEREXIT_MOVE_FIELD_TO_KOMPD(SAPMV50A).

ENDFORM.
*eject