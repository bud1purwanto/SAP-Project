*---------------------------------------------------------------------*
*       FORM SD_FILL_KOMKCV_KOMPCV_FPLT_ORD                           *
*---------------------------------------------------------------------*
*       Kommstrukturen fuer die Kontenfindungsanalyse, ManAuth, usw.
*       füllen
*---------------------------------------------------------------------*
*  -->  US_XFPLT                                                      *
*  -->  CH_KOMKCV                                                     *
*  -->  CH_KOMPCV                                                     *
*---------------------------------------------------------------------*
FORM CCARD_KONTENFIND_VORBEREITEN USING US_XFPLA  STRUCTURE FPLAVB
                                        US_XFPLT  STRUCTURE FPLTVB
                               CHANGING CH_KALSM  LIKE TVFK-KALSMCD
                                        CH_KOMKCV STRUCTURE KOMKCV
                                        CH_KOMPCV STRUCTURE KOMPCV.

* CCARD - Start
  CONSTANTS: CO_POSNR_INITIAL LIKE VBPA-POSNR VALUE IS INITIAL,
             CO_PARVW_RE      LIKE VBPA-PARVW VALUE 'RG'.
* Lese statische Info
  PERFORM XVBUK_LESEN(SAPFV45K) USING VBAK-VBELN.
  READ TABLE XVBKD
       WITH KEY POSNR = CO_POSNR_INITIAL.
  IF SY-SUBRC NE 0.
    MESSAGE E200(V/) WITH 'MV45AF0Z' 'READ XVBKD'.
  ENDIF.
  READ TABLE XVBPA
       WITH KEY POSNR = CO_POSNR_INITIAL
                PARVW = CO_PARVW_RE.
  IF SY-SUBRC NE 0.
    MESSAGE E200(V/) WITH 'MV45AF0Z' 'READ XVBPA'.
  ENDIF.
* Schemafindung
  CALL FUNCTION 'SD_PROCEDURE_DETERMINE_FPLT_OR'
       EXPORTING
            I_VBAK    = VBAK
            I_VBUK    = VBUK
       IMPORTING
            E_KALSMCD = CH_KALSM
       EXCEPTIONS
            NOT_FOUND = 4.
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
* Kommstrukturen
  CALL FUNCTION 'SD_FILL_KOMKCV_KOMPCV_FPLT_ORD'
       EXPORTING
            I_VBAK   = VBAK
            I_VBUK   = VBUK
            I_VBKDVB = XVBKD
            I_FPLAVB = US_XFPLA
            I_FPLTVB = US_XFPLT
       IMPORTING
            E_KOMKCV = CH_KOMKCV
            E_KOMPCV = CH_KOMPCV.
* CCARD - End

ENDFORM.