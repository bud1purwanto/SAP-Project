*---------------------------------------------------------------------*
*       FORM RV45A-DWERK_PRUEFEN                                      *
*---------------------------------------------------------------------*
*       Kopfwerk pruefen                                              *
*---------------------------------------------------------------------*
FORM RV45A-DWERK_PRUEFEN USING US_WERKS
                               US_ERROR
                               CH_SUBRC.

  IF US_WERKS NE SPACE.
* Ist das Werk erlaubt ?
    CLEAR T001W-WERKS.                 " Forced select
    PERFORM T001W_SELECT USING US_WERKS
                               US_ERROR
                               SY-SUBRC.
    IF SY-SUBRC NE 0.
* Eingabe übernehmen
      CH_SUBRC = 4.
      US_WERKS = SPACE.
    ENDIF.

* TVTA lesen, weil sie an dieser Stelle evtl. noch nicht gefüllt ist
* DWERK gilt positionsübergreifend, deshalb lesen mit Kopfsparte
    PERFORM TVTA_SELECT USING VBAK-VKORG
                              VBAK-VTWEG
                              VBAK-SPART.

    PERFORM TVKWZ_SELECT(SAPMV45A) USING VBAK-VKORG
                                         TVTA-VTWKU
                                         US_WERKS
                                         US_ERROR
                                         SY-SUBRC.
    IF SY-SUBRC NE 0.
* Eingabe übernehmen
      CH_SUBRC = 4.
      US_WERKS = SPACE.
    ENDIF.
    IF VBAK-VKORG IS INITIAL.
      DATA: DA_ACTVT(2).
      CASE T180-TRTYP.
        WHEN CHARH.
          DA_ACTVT = CHARH.
        WHEN CHARV.
          DA_ACTVT = CHARV.
        WHEN CHARA.
          DA_ACTVT = CHARA.
      ENDCASE.

*- Authority-Check
      AUTHORITY-CHECK OBJECT 'C_PPBD'
         ID 'AKTTYP' FIELD DA_ACTVT
         ID 'WERKS' FIELD US_WERKS.
*- Fehlerhandling.
      IF SY-SUBRC > 0.
        IF US_ERROR NE SPACE.
          MESSAGE E141 WITH DA_ACTVT US_WERKS.
        ELSE.
          CH_SUBRC = 6.
          CLEAR US_WERKS.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.