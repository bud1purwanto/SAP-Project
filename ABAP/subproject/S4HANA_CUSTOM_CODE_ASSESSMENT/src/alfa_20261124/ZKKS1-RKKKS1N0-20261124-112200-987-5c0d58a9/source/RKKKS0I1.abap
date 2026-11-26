*---------------------------------------------------------------------*
* START-OF-SELECTION
*---------------------------------------------------------------------*
*START-OF-SELECTION.
FORM START_OF_SELECTION_MAIN.
* Database commit to free lock on joblog...
* CALL FUNCTION 'DB_COMMIT'.
* Sender selection...
  PERFORM SENDER_SELECTION
    TABLES    IT_SENDER
    CHANGING  HLP_SELART HLP_VARIANT HLP_ONE.
* Set selection criterias...
  CALL FUNCTION 'K_OBJECT_SELECTION_CRIT_FILL'
    EXPORTING
      SELART                  = hlp_selart
      ONEOBJECT               = hlp_one
      VARIANT                 = hlp_variant
*   IMPORTING
*     SELART_TXT              =
    TABLES
      IT_COSEL2               = it_sender.

* Selected target versions...
* GET PARAMETER ID 'TVS' FIELD PA_VSSEL.

* PA_INCLF PA_INCLP PA_INCLI have to be set in order to check
* the proper target version
 IF NOT hlp_selart = con_selart-wl.
* w/o worklists parameters are taken from kass selection crit.
   LOOP AT it_sender.
     IF     it_sender-low(10) = 'INCL_FAUF '.
       pa_inclf = it_sender-low+10(1).
     ELSEIF it_sender-low(10) = 'INCL_PKOSA'.
       pa_inclp = it_sender-low+10(1).
     ELSEIF it_sender-low(10) = 'INCL_PIAUF'.
       pa_incli = it_sender-low+10(1).
     ENDIF.
   ENDLOOP.
 ELSE.
* otherwise they are always set
   pa_inclf = 'X'.
   pa_inclp = 'X'.
   pa_incli = 'X'.
 ENDIF.

 DATA: LS_WITEM LIKE SCMA_WITEM.                             "OSS 451629
 LS_WITEM-WF_WITEM = WF_WITEM.                               "OSS 451629
 LS_WITEM-WF_WLIST = WF_WLIST.                               "OSS 451629

* Central routine for the background processing...
  PERFORM EXTERN_BATCHLAUF_STARTEN IN PROGRAM SAPMKKS0
    USING    PA_KOKRS  PA_WERKS PA_GJAHR PA_POPER
             PA_AUFNR  PA_AUFNB PA_AUART PA_AUTYP
             P_PROCNR  P_PROCNB
             PA_SAFNR  PA_SAFNB PA_VERID PA_MATNR PA_MATNB
             PA_KDAUF  PA_KDAUB PA_KDPOS PA_PROJN PA_PROJB
             PA_AWVAL  PA_AWVSE PA_VSSEL PA_TESTL PA_BATCH
             PA_LISTF  PA_PRIMS
             PA_OKCOD  PA_TCODE PA_DYNNR
             P_KKS00C
             PA_VERWS  PA_STAKZ PA_STAMD PA_STANO PA_FORTS
             PA_TSTKZ
             PA_INCLF  PA_INCLP PA_INCLI
             LS_WITEM  WF_OKEY RFCGROUP.                     "OSS 451629
ENDFORM.

*---------------------------------------------------------------------*
* VALUE-REQUEST
*---------------------------------------------------------------------*
*at selection-screen on value-request for ..........

*---------------------------------------------------------------------*
* HELP-REQUEST
*---------------------------------------------------------------------*
*at selection-screen on help-request for ............

*---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*---------------------------------------------------------------------*
*at selection-screen ............

*---------------------------------------------------------------------*
* TOP-OF-PAGE (DURING LINE-SELECTION)
*---------------------------------------------------------------------*
TOP-OF-PAGE.
  PERFORM TITEL_AUSGEBEN IN PROGRAM SAPMKKS0.
TOP-OF-PAGE DURING LINE-SELECTION.
  PERFORM TITEL_AUSGEBEN IN PROGRAM SAPMKKS0.