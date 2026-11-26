*---------------------------------------------------------------------*
*       FORM FPLAN_POS_KOPFRELEVANT                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  US_POSNR                                                      *
*  -->  US_FPART_KOPF                                                 *
*  -->  US_FPART_POS                                                  *
*  -->  CH_RC                                                         *
*---------------------------------------------------------------------*
FORM FPLAN_POS_KOPFRELEVANT USING    US_POSNR US_FPART_POS US_FPART_KOPF
                            CHANGING CH_RC.
  CH_RC = 4.
  PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING POSNR_LOW
                                             SVBKD-TABIX.
  MOVE XVBKD-FPLNR TO VBKD-FPLNR.
  PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING US_POSNR
                                             SVBKD-TABIX.
  IF XVBKD-POSNR NE POSNR_LOW AND
     NOT XVBKD-FPLNR IS INITIAL.
*   Zeigt der Positionsfakturierungsplan auf den KopfFplan  ?
    CALL FUNCTION 'BILLING_SCHEDULE_RELATION'
         EXPORTING
              I_KFPLNR    = VBKD-FPLNR
              I_FPLNR     = XVBKD-FPLNR
         TABLES
              FPLA_NEW    = XFPLA
         EXCEPTIONS
              RELATION_OK = 1
              OTHERS      = 2.
    IF SY-SUBRC = 1.
      CH_RC = 0.
    ELSE.
      CH_RC = 4.
    ENDIF.
  ELSE.
    IF KOPIEREN    NE SPACE AND
       VBKD-FPLNR IS INITIAL.
*     wenn im Kopieren und es ist noch kein Kopf vorhanden ->
*     kein Kopf erzeugen, da dies ganz am Ende des Kopierens passiert
      CH_RC = 4.
    ELSE.
      IF US_FPART_POS EQ US_FPART_KOPF AND NOT VBKD-FPLNR IS INITIAL.
        CH_RC = 0.
      ELSE.
        CH_RC = 4.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.