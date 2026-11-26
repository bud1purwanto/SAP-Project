*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_PREP                                        *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_PREP_40                                            *
*---------------------------------------------------------------------*
*       Übergang zur Reparaturabwicklung                              *
*---------------------------------------------------------------------*
FORM FCODE_PREP_40 USING H185F STRUCTURE T185F
                         H185  STRUCTURE T185
                         H185V STRUCTURE T185V.

  DATA: DA_FEHLER(1) TYPE C.
  DATA: DA_POSNR LIKE VBAP-POSNR.
  DATA: DA_ACTIVITY(4).
  DATA: DA_FLG_VE,
        DA_FLG_PAKT,
        DA_FLG_IREP,
        DA_FLG_TREP,
        DA_FLG_REPA,
        DA_FLG_KZEN,
        DA_FLG_KENT.

* Übersichtsbild nur für Reparaturanforderung verfügbar
  IF VBAP-VKGRU NE VKGRU_REP_REPARATURANFO.
    MESSAGE I875.
    H185F-FCODE = C_TAXI_DEFAULT_ITEM_FCODE.
    EXIT.
  ENDIF.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

* Sicherstellen, daß Bildgruppenwechsel erkannt werden (TAXI)
  PERFORM CUA_SETZEN.
  PERFORM TAXI_INITIALIZE_CARRIERSCREEN.

* Fehlerprotokoll ?
* clear da_fehler.
* if fehler = 'X'.
*   da_fehler = charx.
*   t185v-panel = 'PREP'.
* endif.

* Anwendungsdaten vorbereiten
  DATA: DA_DATALOSS LIKE R185D-DATALOSS.
  DATA: DA_HEADKOM LIKE V46R_HEADKOM.
  DATA: DA_REPAIRFLAGS LIKE V46R_REPAIRFLAGS.
  DATA: DA_ITEMKOM LIKE V46R_ITEMKOM  OCCURS 0 WITH HEADER LINE.
  DATA: DA_REPAKOM LIKE V46R_REPAKOM OCCURS 0 WITH HEADER LINE.
  DATA: DA_SERIKOM LIKE V46R_SERIKOM OCCURS 0 WITH HEADER LINE.
  DATA: DA_STAGE LIKE TVRMAV-ZEITP.

* Aufruf Dialog
  TAXI_PROGRAM                 = T185V-CPROG.
  TAXI_HEADER_SUBSCREEN        = T185V-DYBS1.
  TAXI_GUI_PROGRAM             = T185V-AGIDV.
  TAXI_GUI_STATUS              = T185V-STATUS.
  TAXI_GUI_TITLE               = T185V-CTITEL.
  TAXI_GUI_TITLE_PARAM         = RV02P-TITLE.
  CONDENSE TAXI_GUI_TITLE_PARAM.

  DA_POSNR = VBAP-POSNR.
  DA_ACTIVITY = ACT_DIALOG.

  PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).

* Schnittstelle füllen
  PERFORM REPAIRITEMS_PREPARE(SAPFV45P) TABLES   DA_ITEMKOM
                                                 DA_SERIKOM
                                        USING    DA_POSNR
                                        CHANGING DA_HEADKOM.
  PERFORM REPAIRITEMS_PREP_STATUS(SAPFV45P)
    USING    DA_POSNR
    CHANGING DA_REPAIRFLAGS
             DA_HEADKOM.
  PERFORM REPAIRITEMS_PREP_STAGE(SAPFV45P)
    TABLES   DA_ITEMKOM
    USING    DA_POSNR
             DA_REPAIRFLAGS
    CHANGING DA_STAGE
             DA_HEADKOM.

  IF DA_STAGE EQ REPARATURANNAHME AND
     DA_REPAIRFLAGS-FLG_KZEN IS INITIAL AND
     DA_REPAIRFLAGS-FLG_KENT IS INITIAL.
*   Beim Anlegen soll gleich der Status sitzen
    PERFORM REPAIRSTATUS_SETFIRST(SAPFV45P) USING DA_POSNR
                             CHANGING DA_REPAIRFLAGS-FLG_KZEN
                                                  DA_HEADKOM.
  ENDIF.

* Pull Fall: Kundenauftrag frägt die Ergebnisse der Rückmeldung ab,
*            da Rückmeldung aus Prüflos, Q-Meldung oder Serviceauftrag
*            nicht erfolgreich war
  PERFORM REPAIRITEMS_CONFIRMATION_PULL(SAPFV45P)
    TABLES   DA_ITEMKOM
             DA_REPAKOM
             DA_SERIKOM
    USING    DA_POSNR
             DA_REPAIRFLAGS
             DA_STAGE
             DA_HEADKOM
    CHANGING DA_ACTIVITY.

  CALL FUNCTION 'SD_REPAIRORDER_DIALOG'
       EXPORTING
            I_CALL_ACTIVITY          = DA_ACTIVITY
            I_STAGE                  = DA_STAGE
            I_T185                   = T185
            I_T185F                  = T185F
            I_T185V                  = T185V
            I_TITEL                  = RV02P-TITLE
            I_FEHLERPROTOKOLL        = DA_FEHLER
            I_TAXI_TABSTRIP_CAPTIONS = TAXI_TABSTRIP_CAPTIONS
            I_TAXI_PROGRAM           = TAXI_PROGRAM
            I_TAXI_HEADER_SUBSCREEN  = TAXI_HEADER_SUBSCREEN
            I_TAXI_GUI_PROGRAM       = TAXI_GUI_PROGRAM
            I_TAXI_GUI_STATUS        = TAXI_GUI_STATUS
            I_TAXI_GUI_TITLE         = TAXI_GUI_TITLE
            I_TAXI_GUI_TITLE_PARAM   = TAXI_GUI_TITLE_PARAM
       IMPORTING
            E_DATALOSS               = DA_DATALOSS
            E_T185                   = T185
            E_T185F                  = T185F
            E_T185V                  = T185V
       TABLES
            T_ITEMKOM                = DA_ITEMKOM
            T_REPAKOM                = DA_REPAKOM
            T_SERIKOM                = DA_SERIKOM
       CHANGING
            C_HEADKOM                = DA_HEADKOM
            C_TAXI_TABSTRIP          = TAXI_TABSTRIP_ITEM.

  IF NOT DA_DATALOSS IS INITIAL.
*   Generieren Unterpositionen
    PERFORM REPAIRITEMS_GENERATE(SAPFV45P) TABLES DA_ITEMKOM
                                                  DA_SERIKOM
                                           USING  DA_POSNR.
  ENDIF.

* Reparaturstatus aktualisieren
  PERFORM REPAIRITEMS_PREPARE(SAPFV45P) TABLES   DA_ITEMKOM
                                                 DA_SERIKOM
                                        USING    DA_POSNR
                                        CHANGING DA_HEADKOM.
  PERFORM REPAIRITEMS_PREP_STATUS(SAPFV45P)
    USING    DA_POSNR
    CHANGING DA_REPAIRFLAGS
             DA_HEADKOM.
  PERFORM REPAIRITEMS_PREP_STAGE(SAPFV45P)
    TABLES   DA_ITEMKOM
    USING    DA_POSNR
             DA_REPAIRFLAGS
    CHANGING DA_STAGE
             DA_HEADKOM.

  PERFORM REPAIRSTATUS_MAINTAIN(SAPFV45P) USING DA_POSNR
                                                DA_STAGE
                                                CHARX
                                                DA_REPAIRFLAGS
                                                DA_HEADKOM.

  PERFORM REPAIRORDER_INCOMPLETION(SAPFV45P) USING DA_POSNR.

  CALL FUNCTION 'TAXI_CONVERT_FCODE'
       EXPORTING
            FCODE_IN        = T185F-FCODE
       IMPORTING
            FCODE_OUT       = T185F-FCODE
       EXCEPTIONS
            FCODE_NOT_FOUND = 1
            OTHERS          = 2.

  IF DA_DATALOSS NE SPACE.
    R185D-DATALOSS = CHARX.
  ENDIF.

  H185  = T185.
  H185F = T185F.
  H185V = T185V.
  FCODE = T185F-FCODE.

ENDFORM.