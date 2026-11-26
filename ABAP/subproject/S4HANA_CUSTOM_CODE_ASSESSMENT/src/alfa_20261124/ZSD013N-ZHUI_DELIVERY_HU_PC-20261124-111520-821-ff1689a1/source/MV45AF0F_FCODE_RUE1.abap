*---------------------------------------------------------------------*
*       form fcode_rue1                                               *
*---------------------------------------------------------------------*
*       übernehmen referenzbeleg via dialogbaustein übersicht 1       *
*---------------------------------------------------------------------*
FORM FCODE_RUE1 USING H185F STRUCTURE T185F H185  STRUCTURE T185
                                            H185V STRUCTURE T185V.

  DATA: MV45A_DATALOSS LIKE R185D-DATALOSS.

* Der Titel bezieht sich nach dem Dialogbaustein auf den Referenzbeleg.
* Deshalb darf der Titel nicht übernommen werden. Z.B. Kopieren von
* Mengenkontrakt nach Terminauftrag. Nach call dialog enthält TITEL
* anstatt 'Auftragsbearbeitung' den Wert 'Kontraktbearbeitung'.
  LOCAL: R185D-TITEL.

  MV45A_DATALOSS = R185D-DATALOSS.
  RV45A-AMODE    = CHARC.

  T185 = H185.
  T185F = H185F.
  T185V = H185V.

  CALL DIALOG 'RV_BELEG_KOPIEREN_DIALOG'
       EXPORTING
            VBAK-VBELN   FROM CVBAK-VBELN
            VBAK-TRVOG   FROM CVBAK-TRVOG
            *TVAK        FROM TVAK
            TVCPA
            T185F
            T185
            T180
            T185V
            RV45A-KPRGRS
            RV45A-KEDATU
            RV45A-AMODE
            RV45A-ABHOD
            RV45A-ABHOV
            RV45A-ABHOB
            XVBUP
            XVBFA
            YVBFA
            BI_INFO
       IMPORTING
            VBAK         TO CVBAK
            XVBAP        TO CVBAP
            XVBEP        TO CVBEP
            XVBFA        TO CVBFA
            XVBKD        TO CVBKD
            XVBUP        TO CVBUP
            XFPLA        TO CFPLA
            XFPLT        TO CFPLT
            RV45A-KPRGRS
            RV45A-KEDATU
            TVCPA
            T185F
            T185
            R185D.

  H185 = T185.
  H185F = T185F.
  H185V = T185V.

  CLEAR RV45A-AMODE.
  IF MV45A_DATALOSS NE SPACE AND R185D-DATALOSS EQ SPACE.
    R185D-DATALOSS = MV45A_DATALOSS.
  ENDIF.

ENDFORM.