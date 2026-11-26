*---------------------------------------------------------------------*
*       FORM FCODE_UMA1                                               *
*---------------------------------------------------------------------*
*       Positionsvorschlag via Dialogbaustein Übersicht 1             *
*---------------------------------------------------------------------*
FORM FCODE_UMA1 USING US_T185F US_T185 US_T185V.

  DATA: MV45A_DATALOSS LIKE R185D-DATALOSS.

  MV45A_DATALOSS = R185D-DATALOSS.
  T185F = US_T185F.
  T185  = US_T185.
  T185V = US_T185V.

  CALL DIALOG 'RV_BELEG_KOPIEREN_DIALOG'
       EXPORTING
            VBAK-VBELN         FROM CVBAK-VBELN
            *tvak              FROM tvak
            TVCPA
            T185F
            T185
            T180
            T185V
            RV45A-KPRGRS
            RV45A-KEDATU
            POSITIONSVORSCHLAG FROM CHARX
            XVBAP              FROM CVBAP
       IMPORTING
            XVBAP              TO CVBAP
            XVBEP              TO CVBEP
            VBAK               TO CVBAK
            XVBKD              TO CVBKD
            RV45A-KPRGRS
            RV45A-KEDATU
            T185F
            T185
            T185V
            R185D.

  US_T185F = T185F.
  US_T185  = T185.
  US_T185V = T185V.

  IF MV45A_DATALOSS NE SPACE AND R185D-DATALOSS EQ SPACE.
    R185D-DATALOSS = MV45A_DATALOSS.
  ENDIF.

ENDFORM.