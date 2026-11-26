*---------------------------------------------------------------------*
*       FORM FPLAN_KOPF_WERT_VERTEILEN                                *
*---------------------------------------------------------------------*
*       Differenzen auf die Positionen verteilen.                     *
*---------------------------------------------------------------------*
FORM FPLAN_KOPF_WERT_VERTEILEN.
  DATA: DA_DATALOSS LIKE R185D-DATALOSS.
  DATA: DA_KFPLNR   LIKE VBKD-FPLNR.

* nur wenn Kopffakturierungsplan zugelassen
  CHECK NOT TVAK-FPART IS INITIAL.

* Lesen der VBKD
  PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING POSNR_LOW
                                             SVBKD-TABIX.

* Wenn es keinen Kopffakturierungsplan gibt, dann muß auch nichts
* verteilt werden.
  CHECK NOT XVBKD-FPLNR IS INITIAL.
  MOVE XVBKD-FPLNR TO DA_KFPLNR.
* Mögliche Differenz verteilen I_ACTION = B

  CALL FUNCTION 'BILLING_SCHEDULE_VALUE_BASED'
       EXPORTING
            I_ACTION   = CHARB
            I_KFPLNR   = DA_KFPLNR
            I_WAERS    = VBAK-WAERK
*           I_NOMSG    =
       IMPORTING
            E_DATALOSS = DA_DATALOSS
*           E_ADJUST   =
       TABLES
            FPLA_NEW   = XFPLA
            FPLA_OLD   = YFPLA
            FPLT_NEW   = XFPLT
            FPLT_OLD   = YFPLT
            T_XVBAP    = XVBAP
            T_XVBKD    = XVBKD.

  IF DA_DATALOSS NE SPACE AND R185D-DATALOSS EQ SPACE.
    R185D-DATALOSS = DA_DATALOSS.
  ENDIF.

ENDFORM.