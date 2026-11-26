*---------------------------------------------------------------------*
*       FORM FPLAN_POS_WERT_VERTEILEN                                 *
*---------------------------------------------------------------------*
*       Verteilen von wertmäßigen Termine auf die zug. Pos.Fakt.pläne *
*---------------------------------------------------------------------*
FORM FPLAN_POS_WERT_VERTEILEN USING US_VERTEILEN.

LOCAL: VBAP, *VBAP, XVBAP, TVAP,
       SVBAP-TABIX.

  DATA: DA_DATALOSS LIKE R185D-DATALOSS.
  DATA: DA_KFPLNR   LIKE VBKD-FPLNR.
  DATA: DA_ADJUST.

* US_VERTEILEN = 'X' bedeutet:
* Bei einem wertmäßigen Kopffakturierungsplan werden die Werte
* sofort, ohne nochmals auf Differenzen zu prüfen, auf die
* zugehörigen Positionsfakturierungspläne verteilt.
* Sitzt dieses Flag nicht, wird nochmal auf Differenz geprüft.
* Beträge aus dem Kopf neu verteilt.
  IF NOT US_VERTEILEN IS INITIAL.
    MOVE CHARX TO DA_ADJUST.
  ENDIF.

* nur wenn Kopffakturierungsplan zugelassen
  CHECK NOT TVAK-FPART IS INITIAL.

* Lesen der VBKD
  PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING POSNR_LOW
                                             SVBKD-TABIX.

* Wenn es keinen Kopffakturierungsplan gibt, dann muß auch nichts
* verteilt werden.
  CHECK NOT XVBKD-FPLNR IS INITIAL.
  MOVE XVBKD-FPLNR TO DA_KFPLNR.
* Prüfen, ob es sich um einen wertmäßigen Kopffakturierungsplan handelt
  CALL FUNCTION 'BILL_SCHED_VALUE_BASED_CHECK'
       EXPORTING
            I_KFPLNR       = DA_KFPLNR
       TABLES
            FPLT_NEW       = XFPLT
       EXCEPTIONS
            VALUE_BASED_OK = 1
            OTHERS         = 2.
  CHECK SY-SUBRC = 1.

  IF US_VERTEILEN IS INITIAL.
*   Mögliche Differenz ermitteln, wenn es von außen erwünscht
*   ist (I_ACTION = A)
    CLEAR DA_ADJUST.

    CALL FUNCTION 'BILLING_SCHEDULE_VALUE_BASED'
         EXPORTING
              I_ACTION   = CHARA
              I_KFPLNR   = DA_KFPLNR
              I_WAERS    = VBAK-WAERK
*             I_NOMSG    =
         IMPORTING
              E_DATALOSS = DA_DATALOSS
              E_ADJUST   = DA_ADJUST
         TABLES
              FPLA_NEW   = XFPLA
              FPLA_OLD   = YFPLA
              FPLT_NEW   = XFPLT
              FPLT_OLD   = YFPLT
              T_XVBAP     = XVBAP
              T_XVBKD     = XVBKD.
  ENDIF.
  CHECK NOT DA_ADJUST IS INITIAL.

* Bevor die Differenzen verteilt werden können, muß erst der
* Kopffakturierungsplan aktualisiert werden

  PERFORM FPLAN_KOPF_AKTUALISIEREN_CALL USING  SPACE.

* Nach der Aktualisierung des Kopfes müssen alle Fakturierungspläne,
* die am Kopf hängen aktualisiert werden und danach die Differenz
* verteilt verteilt werden.

  PERFORM FPLAN_AKTUALISIEREN(SAPMV45A)
    USING POSNR_FIRST POSNR_HIGH
          SPACE.

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
            T_XVBAP     = XVBAP
            T_XVBKD     = XVBKD.

  IF DA_DATALOSS NE SPACE AND R185D-DATALOSS EQ SPACE.
    R185D-DATALOSS = DA_DATALOSS.
  ENDIF.

ENDFORM.