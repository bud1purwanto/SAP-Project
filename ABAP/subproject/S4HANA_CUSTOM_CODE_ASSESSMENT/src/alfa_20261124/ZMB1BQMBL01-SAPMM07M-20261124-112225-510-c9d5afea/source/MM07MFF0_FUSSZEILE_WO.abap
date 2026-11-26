*eject
*---------------------------------------------------------------------*
*        FORM FUSSZEILE_WO                                            *
*---------------------------------------------------------------------*
*        Die Fusszeile fuer die Verrechnung von Beistellpositionen    *
*        wird bearbeitet.                                             *
*---------------------------------------------------------------------*
FORM fusszeile_wo.

  DATA: LS_ISU_FUSSZEILE_WA_PRUEFEN TYPE ISU_FUSSZEILE_WA_PRUEFEN."IS2ERP

  CHECK t158-trtyp = h.
  IF NOT fcausw-xselp IS INITIAL AND NOT fcausw-xlist IS INITIAL.
    IF NOT t063o-auswa IS INITIAL AND t063o-auswa NE p.
      rm07m-xselk = kreuz.
      IF rm07m-zeile IS INITIAL.
        rm07m-zeile = mseg-zeile.
      ENDIF.
    ENDIF.
    READ TABLE biwe INDEX 1.
    IF sy-subrc IS INITIAL.
      IF biwe-zeile NE mseg-zeile.
        MESSAGE e001 WITH 'BIWE' mseg-zeile.
      ENDIF.
      a_zeile = mseg-zeile.
      PERFORM segment_lesen USING i.
      IF rc NE 0.
        MESSAGE e001 WITH 'FUSS' mseg-zeile.
      ENDIF.
*     Fields that are actual in biwe but old mseg (always the last
*     item of the screen) needs to be protected.
*     Internal table biwe is used for filter issue so that only screen
*     fields gets changed in internal table fuss. But this can only work
*     if all fields in table biwe are on the screen, because only in
*     that case the corresponding mseg fields have already the newest
*     values via screen-transport.
      mseg-xauto = biwe-xauto.
      mseg-urzei = biwe-urzei.
      mseg-lgort = biwe-lgort.                                  "439479
      MOVE-CORRESPONDING mseg TO biwe.
      MOVE-CORRESPONDING dm07m TO biwe.
      MOVE-CORRESPONDING biwe TO fuss.
      IF dm07m-dimng = 0.
        fuss-erfmg = 0.
      ELSE.
*       Get movement type for component and take negative quantity into
*       account.
        perform mvt_component_get using    dm07m-dimng
                                           fuss-rshkz
                                  changing fuss-bwart
                                           fuss-erfmg.
        CLEAR rm07m-kzbew.
        MOVE-CORRESPONDING fuss TO dm07m.
        MOVE-CORRESPONDING fuss TO vm07m.
        MOVE-CORRESPONDING fuss TO mseg.
        PERFORM fusszeile_wa_pruefen USING x
                                           LS_ISU_FUSSZEILE_WA_PRUEFEN."IS2ERP
        MOVE-CORRESPONDING dm07m TO fuss.
        MOVE-CORRESPONDING vm07m TO fuss.
        MOVE-CORRESPONDING mseg TO fuss.
        rm07m-kzbew = t158-kzbew.
        fuss-xprue = x.
      ENDIF.
      fuss-xselk = rm07m-xselk.
      MODIFY fuss INDEX a_zeile.
      DELETE biwe INDEX 1.
    ELSE.
      CLEAR xkont.
    ENDIF.
  ENDIF.
ENDFORM.