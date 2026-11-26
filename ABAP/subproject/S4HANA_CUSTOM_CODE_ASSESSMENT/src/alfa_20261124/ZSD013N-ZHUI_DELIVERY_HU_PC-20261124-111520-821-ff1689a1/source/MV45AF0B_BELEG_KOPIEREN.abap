*---------------------------------------------------------------------*
*       FORM BELEG_KOPIEREN                                           *
*---------------------------------------------------------------------*
*       Ein Beleg soll kopiert werden                                 *
*---------------------------------------------------------------------*
FORM BELEG_KOPIEREN USING US_T185F STRUCTURE T185F
                          US_T185  STRUCTURE T185
                          US_T185V STRUCTURE T185V.

  PERFORM BELEG_KOPIEREN_VORBEREITEN(SAPFV45C) USING VBAK-AUART.

* Für mehrfaches Kopieren wird Fluß und Status mit übergeben
  REFRESH CVBFA.
  APPEND LINES OF XVBFA TO CVBFA.
  REFRESH CVBUP.
  APPEND LINES OF XVBUP TO CVBUP.
ENHANCEMENT-POINT BELEG_KOPIEREN_10 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT BELEG_KOPIEREN_11 SPOTS ES_SAPMV45A.


ENHANCEMENT-SECTION     BELEG_KOPIEREN_01 SPOTS ES_SAPMV45A.
  CALL FUNCTION 'RV_SALES_DOCUMENT_COPY'
       EXPORTING
            F185F           = US_T185F
            F185            = US_T185
            F185V           = US_T185V
            FVAK            = TVAK
            FVBAK           = VBAK
            FVBPA           = VBPA
            FBODY_SUBSCREEN = TAXI_BODY_SUBSCREEN
       IMPORTING
            FVBRK           = CVBRK
            FVBAK           = CVBAK
            FPRGRS          = RV45A-KPRGRS
            FEDATU          = RV45A-KEDATU
            FABHOV          = RV45A-ABHOV
            FABHOB          = RV45A-ABHOB
            FABHOD          = RV45A-ABHOD
            FVCPA           = TVCPA
            FVBUK           = CVBUK
            F185F           = US_T185F
            F185            = US_T185
            F185V           = US_T185V
       TABLES
            FXVBRP          = CVBRP
            FXVBAP          = CVBAP
            FXVBEP          = CVBEP
            FXVBFA          = CVBFA
            FYVBFA          = YVBFA
            FXVBKD          = CVBKD
            FXVBPA          = CVBPA
            FXVBUP          = CVBUP
            FXVBUK          = XVBUK
            FXVBUV          = XVBUV
            FXFPLA          = CFPLA
            FXFPLT          = CFPLT
            FXVBSN          = CVBSN.
END-ENHANCEMENT-SECTION.

     GESPERRT = CHARX.


ENDFORM.