*eject
*---------------------------------------------------------------------*
*       FORM F-SEGMENTE_BEWERTEN                                      *
*---------------------------------------------------------------------*
*       Die Währungssegmente des Buchhaltungsbelegs werden erstellt.  *
*---------------------------------------------------------------------*
FORM F-SEGMENTE_BEWERTEN USING    F-CNT02 LIKE T156W-CNT02
                                  F-XBNK  TYPE C
                         CHANGING F-SHKZG LIKE MSEG-SHKZG      "HW578078
                                  L_SHKZG LIKE MSEG-SHKZG.     "HW578078

  REFRESH yacccr. CLEAR yacccr.                            "1275858
  DATA ML10.
  CLEAR: ML10, F-SHKZG.
  IF F-XBNK IS INITIAL.
    LOOP AT XZCXCM WHERE CNT02 = F-CNT02.
      MOVE-CORRESPONDING XZCXCM TO YACCCR.
      CASE XZCXCM-SHKZG.
        WHEN S.
          YACCCR-WRBTR = XZCXCM-DMBTR.
*         if yacccr-bualt < 0.
* Der Bualt wird auch negativ an die RW-Schnittstelle übergeben
* da das xzcxcm-shkzg von dem DMBTR abhängt.
*           clear yacccr-bualt.
*         endif.
        WHEN H.
          YACCCR-WRBTR = 0 - XZCXCM-DMBTR.
          YACCCR-BUALT = 0 - XZCXCM-BUALT.

          PERFORM J_1B_YACCCR USING BRAZIL
                                    YACCCR-WRBTR
                                    YACCCR-FWBAS.
*         if yacccr-bualt > 0.
* Der Bualt wird auch negativ an die RW-Schnittstelle übergeben
* da das xzcxcm-shkzg von dem DMBTR abhängt.
*           clear yacccr-bualt.
*         endif.
        WHEN OTHERS.
          CLEAR: YACCCR-WRBTR, YACCCR-BUALT.
      ENDCASE.
      IF F-SHKZG IS INITIAL.
        F-SHKZG = XZCXCM-SHKZG.
      ELSEIF ( ( F-SHKZG = S AND XZCXCM-SHKZG = H ) OR
               ( F-SHKZG = H AND XZCXCM-SHKZG = S ) ).
        F-SHKZG = X.
      ENDIF.
      IF YACCCR-CURTP = CURTP10.
        ML10 = X.
        L_SHKZG = XZCXCM-SHKZG.                                "HW578078
      ENDIF.
      APPEND YACCCR.
    ENDLOOP.
    IF NOT SY-SUBRC IS INITIAL OR ML10 IS INITIAL.
      MESSAGE E001 WITH 'XZCXCM' F-CNT02.
    ENDIF.
  ELSE.
    DATA XAUTO. CLEAR XAUTO.
    IF F-XBNK = X.
      XAUTO = X.
    ENDIF.

    IF x156w-vorsl NE vorsl_kdm.                            "N980402

ENHANCEMENT-SECTION     MM07MFF9_F_SEGMENTE_BEWERTE_01 SPOTS ES_SAPMM07M.

LOOP AT XZCXCB WHERE STUNR = YEKBNK-STUNR
                   AND   ZAEHK = YEKBNK-ZAEHK
                   AND   XAUTO = XAUTO
                   AND   vorsl NE vorsl_kdm.                  "N980402

      MOVE-CORRESPONDING XZCXCB TO YACCCR.
      IF XZCXCB-SHKZG = S.
        YACCCR-WRBTR = XZCXCB-DMBTR.
      ELSE.
        YACCCR-WRBTR = 0 - XZCXCB-DMBTR.
      ENDIF.
      IF F-SHKZG IS INITIAL.
        F-SHKZG = XZCXCB-SHKZG.
      ELSEIF ( ( F-SHKZG = S AND XZCXCB-SHKZG = H ) OR
               ( F-SHKZG = H AND XZCXCB-SHKZG = S ) ).
        F-SHKZG = X.
      ENDIF.
      IF YACCCR-CURTP = CURTP10.
        ML10 = X.
      ENDIF.
      APPEND YACCCR.

    ENDLOOP.

END-ENHANCEMENT-SECTION.

    IF ML10 IS INITIAL.
      MESSAGE E001 WITH 'XZCXCB' YEKBNK-STUNR YEKBNK-ZAEHK.
    ENDIF.
* Begin N980402
    ELSEIF x156w-vorsl = vorsl_kdm.
      LOOP AT xzcxcb WHERE stunr = yekbnk-stunr
                         AND   zaehk = yekbnk-zaehk
                         AND   xauto = xauto
                         AND   vorsl = vorsl_kdm.
        MOVE-CORRESPONDING xzcxcb TO yacccr.
        IF xzcxcb-shkzg = s.
          yacccr-wrbtr = xzcxcb-dmbtr.
        ELSE.
          yacccr-wrbtr = 0 - xzcxcb-dmbtr.
        ENDIF.
        IF f-shkzg IS INITIAL.
          f-shkzg = xzcxcb-shkzg.
        ELSEIF ( ( f-shkzg = s AND xzcxcb-shkzg = h ) OR
                 ( f-shkzg = h AND xzcxcb-shkzg = s ) ).
          f-shkzg = x.
        ENDIF.
        APPEND yacccr.
      ENDLOOP.
    ENDIF.
* End N980402
  ENDIF.

ENDFORM.                    "F-SEGMENTE_BEWERTEN