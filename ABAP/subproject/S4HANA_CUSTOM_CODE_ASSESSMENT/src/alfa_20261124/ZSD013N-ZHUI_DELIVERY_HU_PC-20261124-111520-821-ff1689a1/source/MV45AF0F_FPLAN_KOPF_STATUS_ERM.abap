*---------------------------------------------------------------------*
*       FORM FPLAN_KOPF_STATUS_ERM                                    *
*---------------------------------------------------------------------*
*       Dynamischer Status des Kopffakturierungsplan ermitteln        *
*---------------------------------------------------------------------*
FORM FPLAN_KOPF_STATUS_ERM.

LOCAL: XVBKD, SVBKD-TABIX.

* nur wenn Kopffakturierungsplan zugelassen
  CHECK NOT TVAK-FPART IS INITIAL.

* Lesen der VBKD
  PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING POSNR_LOW
                                             SVBKD-TABIX.
* nur wenn es einen Kopffakturierungsplan gibt
  CHECK NOT XVBKD-FPLNR IS INITIAL.

* Dynamischer Kopfstatus ermitteln
  CALL FUNCTION 'BILLING_SCHEDULE_STATUS_HEAD'
       EXPORTING
            I_KFPLNR = XVBKD-FPLNR
       TABLES
            FPLA_NEW = XFPLA
            FPLT_NEW = XFPLT.

ENDFORM.