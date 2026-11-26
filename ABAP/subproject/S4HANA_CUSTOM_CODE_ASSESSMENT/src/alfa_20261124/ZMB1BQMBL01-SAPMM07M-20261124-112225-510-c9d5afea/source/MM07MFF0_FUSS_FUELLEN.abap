*eject
*---------------------------------------------------------------------*
*       FORM FUSS_FUELLEN                                             *
*---------------------------------------------------------------------*
*       Die interne Tabelle FUSS wird gefuellt.                       *
*---------------------------------------------------------------------*
FORM fuss_fuellen USING f-yfuss TYPE c.

* Temporary correct KZBEW is not necessary here
* In case of subcontracting PO this routine is called from
* LOHNBEARBEITUNG. For 543 items RM07M-KZBEW is cleared and it is
* correct so. In case of GR for inbound delivery (VL32N) same coding
* is needed so KZBEW cannot be L
  case rm07m-kzbew.
    WHEN space.
      IF mseg-matnr IS INITIAL.
        EXIT.
      ENDIF.
      IF NOT omseg-kzbew IS INITIAL
         AND rm07m-xhell IS INITIAL.
        CLEAR fuss-xhell.
        IF NOT xmbwl IS INITIAL AND t158-kzbew IS INITIAL AND
           NOT mseg-bwart IS INITIAL.
          msegk-bwart = mseg-bwart.
          msegk-sobkz = mseg-sobkz.
          msegk-lifnr = mseg-lifnr.
          msegk-ebeln = mseg-ebeln.
        ENDIF.
      ENDIF.
    WHEN b.
      IF mseg-ebeln IS INITIAL OR
         ( mseg-ebeln = auto_best AND
*           mseg-ebelp IS INITIAL ).                       " 303452
           MSEG-EBELP IS INITIAL ) OR                      " 303452
         ( MSEG-EBELN = AUTO_BEST AND                      " 303452
           FCAUSW-XAENP IS INITIAL ).                      " 303452
        IF xdeliv = x.                                      "HUM
          CLEAR xdeliv.                                     "HUM
          MESSAGE e453.                                     "HUM
        ENDIF.                                              "HUM
        mseg-ebeln = auto_best.
        vm07m-xnebe = x.
      ENDIF.
      IF mseg-ebeln IS INITIAL.
        EXIT.
      ENDIF.
    WHEN f.
      IF mseg-aufnr IS INITIAL.
        EXIT.
      ENDIF.
    WHEN o.
      IF mseg-ebeln IS INITIAL.
        EXIT.
      ENDIF.
    WHEN OTHERS.
      EXIT.
  ENDCASE.
  IF NOT fcausw-xneup IS INITIAL OR NOT fcausw-xlist IS INITIAL.
    PERFORM fuss_ergaenzen.
    IF NOT xmbwl IS INITIAL AND fuss-ebeln = auto_best.
      EXIT.
    ENDIF.
    IF NOT fcausw-xlist IS INITIAL AND rm07m-kzbew IS INITIAL.
      IF ( NOT t158-kzbew IS INITIAL AND xkzbew = 1 ) OR
          t158-kzbew IS INITIAL.
        DATA: shkzg LIKE mseg-shkzg.
        shkzg = fuss-shkzg.
        MOVE-CORRESPONDING msegk TO fuss.
* bei Umbuchungen Material an Material zu Leergutpositionen: empfangen-
* des Material wird immer gleich abgebendes Material gesetzt
        IF NOT fuss-ummat IS INITIAL AND
           fuss-ummat NE fuss-matbf AND
           fuss-uptyp = uptyp_lg AND
           NOT fuss-urzei IS INITIAL.
          fuss-ummat = fuss-matnr.
        ENDIF.
        IF fuss-shkzg IS INITIAL.
          fuss-shkzg = shkzg.
        ENDIF.
      ENDIF.
    ENDIF.
    IF f-yfuss IS INITIAL.
      f_zeile = f_zeile + 1.
      s_zeile = s_zeile + 1.
      APPEND fuss.
    ELSE.
      y_zeile = y_zeile + 1.
      yfuss = fuss.
      APPEND yfuss.
    ENDIF.
    CLEAR fuss.
  ENDIF.

ENDFORM.