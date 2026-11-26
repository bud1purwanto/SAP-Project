*----------------------------------------------------------------------*
*   INCLUDE KKA07F01                                                   *
*----------------------------------------------------------------------*
* Hinweis! Dieses Include kann nur über Rahmenprogramm geprüft werden.
*
* Historie:
* P30K049339/3.0D: Include angelegt für Umstellung auf Parallelisierung
* P30K081591/3.0E: Umstellung auf Parallelisierung fortgesetzt
* P30K090477/3.0F: Bei RK003 den Msg-Handler zuvor mit Aufnr versorgen
* ALRK008526(40A_0WIP): Flag 0-WIP-Aufträge ausblenden
* 40A: Modularisierung der WIP-Ermittlung
* 40A: Umschalten auf Bukrs-Währung (CompanyCodeCurrency) (40A_CCC)
INCLUDE KKA07T01.

TYPES:
     BEGIN OF T_USER_PARAM,
         TO_DO         LIKE SY-TABIX,
         PARAMS        LIKE KKAPARA_IN,
         OBJECTS       LIKE KKAPARA_TA  OCCURS 0,                  "40A
         VERSIONS      LIKE KKAPARA_VS  OCCURS 0,                  "40A
     END   OF T_USER_PARAM.

*&---------------------------------------------------------------------*
*&      Form  WIP_ERMITTELN_PARALLEL
*&---------------------------------------------------------------------*
*  WIP-Ermittlung wird parallel ausgeführt unter Verw. von Fugr. KKPA  *
*----------------------------------------------------------------------*
*  -->  p_kkapara_in  Struktur mit Ablaufparametern
*                     (direkt an RFC-FB weitergegeben)
*----------------------------------------------------------------------*
FORM WIP_ERMITTELN_PARALLEL
    TABLES
        PT_AUFTRAG     STRUCTURE KKAPARA_TA
        PT_VERSION     STRUCTURE KKAPARA_VS
    USING
        P_KKAPARA_IN   LIKE KKAPARA_IN.

DATA: LD_USERPARAM      TYPE T_USER_PARAM,
      LD_TABLE_LENGTH   TYPE I,         "# Zeilen in Tabelle
      LD_REPID          LIKE SY-REPID.

* Spezielle Variablen fürs Testen
DATA: LD_DEBUG_MODE,                 "zum Schreiben des Debug-Logs
      LD_TASK_LIMIT TYPE I VALUE 0.  "zum Testen im ser. Modus: =0

* Initialisiere Parallelisierung
  GD_OBJ_DONE   = 0.   "Starte mit 1. Auftrag => keine Objekte abgearb.
  DESCRIBE TABLE PT_AUFTRAG LINES  LD_TABLE_LENGTH. "# aller Auft.
  LD_USERPARAM-PARAMS   = P_KKAPARA_IN.
  LD_USERPARAM-OBJECTS  = PT_AUFTRAG[].
  LD_USERPARAM-VERSIONS = PT_VERSION[].
  LD_USERPARAM-TO_DO    = LD_TABLE_LENGTH.   "# zubearbeitender Auft.
  LD_REPID = SY-REPID.

* ZUM DEBUGGEN *********************************************************
  IF NOT PARDEBUG IS INITIAL.
    LD_DEBUG_MODE = 'X'.
  ENDIF.
  IF NOT PARSINGL IS INITIAL.
    LD_TASK_LIMIT = 1.
  ENDIF.
* ZUM DEBUGGEN *********************************************************
  CALL FUNCTION 'KKPA_PARA_PROCESS_START'
         EXPORTING
              RFC_GROUP         = P_KKAPARA_IN-RFC_GROUP
              START_TASK_FORM   = 'WIP_START_PARALLEL_TASK'
              RECEIVE_TASK_FORM = 'WIP_PARA_RESULTS'
              CALLBACK_PROG     = LD_REPID
              MAX_NO_OF_TASKS   = LD_TASK_LIMIT
              DEBUG_MODE        = LD_DEBUG_MODE
*        importing
*             statistics        =
         CHANGING
              USER_PARAM        = LD_USERPARAM.
*        exceptions
*             no_tasks_left     = 1
*             others            = 2.
* Exceptions nicht abgefangen => Message direkt vom FB ausgegeben.

ENDFORM.                    " WIP_ERMITTELN_PARALLEL

*eject
*&---------------------------------------------------------------------*
*&      Form  WIP_START_PARALLEL_TASK
*&---------------------------------------------------------------------*
*      Wird von Parallel-Handler aufgerufen:
*      - Portioniert in Pakete zur parallelen Bearbeitung
*      - Ruft RFC-FB zur Ermittlung des WIP
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM WIP_START_PARALLEL_TASK
   USING
      P_PARA_IMP      TYPE KKPA_T_PARA_IMP
   CHANGING
      P_PARA_EXP      TYPE KKPA_T_PARA_EXP
      P_FAILED_OBJS   TYPE KKPA_T_FAILED_OBJECTS
      P_PENDING_OBJS  TYPE KKPA_T_PENDING_OBJECTS
      P_USER_PARAM    TYPE T_USER_PARAM.

DATA: LT_DUMMY_PROT LIKE CMFMSG OCCURS 0, "leere Fehlerprot.tabelle
      LT_OBJECTS    LIKE KKAPARA_TA OCCURS 0 WITH HEADER LINE,
      LT_DUMMY_FEHLAUFT LIKE KKAPARA_FA OCCURS 0.
DATA: LD_NR_OBJ_LEFT   LIKE SY-INDEX,
      LD_PACKAGE_SIZE  LIKE SY-INDEX,
      LD_PACKAGE_START TYPE I,              " From-Index des Pakets
      LD_PACKAGE_END   TYPE I,              "   To-Index des Pakets
      LD_TABIX         LIKE SY-TABIX,
      LD_PEND_OBJ      TYPE LINE OF KKPA_T_PENDING_OBJECTS,
      LD_FAIL_OBJ      TYPE LINE OF KKPA_T_FAILED_OBJECTS,
      LD_OBJDATA       LIKE KKAPARA_TA,
      LD_RFC_MSG       TYPE KKPA_T_RFCMSG,
      LD_SUBRC         TYPE N.   "Konvertierung des SUBRC zur Ausgabe
DATA: SCMA_WORKLISTS_CONTEXT type SPTA_INDXTAB.    "I_46A_SCMA

  GD_EOT-FORM = P_PARA_IMP-EOT_FORM.
  GD_EOT-PROG = P_PARA_IMP-EOT_PROG.

  IF P_FAILED_OBJS[] IS INITIAL.
*  keine fehlerhaften Objekte -> neues Paket abschicken
*   Logik zur Aufteilung in Pakete
*   Strategie: Die Paketgröße wird derart gewählt, daß mit der Restmenge
*              an Aufträgen alle Workprozesse noch con_par_divider-mal
*              verwendet werden,
*              die Mindestgröße pro Paket ist con_package_min Aufträge,
*              die Maximalgröße pro Paket ist con_package_max Aufträge.
    LD_NR_OBJ_LEFT = P_USER_PARAM-TO_DO - GD_OBJ_DONE.
    IF LD_NR_OBJ_LEFT IS INITIAL.
*     Keine Objekte mehr zu verarbeiten
      P_PARA_EXP-ALL_SUBMIT = 'X'.
    ELSE.
*     Neues Paket erstellen
      LD_PACKAGE_SIZE =
          LD_NR_OBJ_LEFT / P_PARA_IMP-NR_TOTAL_TASKS / CON_PAR_DIVIDER.
      IF LD_PACKAGE_SIZE < CON_PACKAGE_MIN.
        LD_PACKAGE_SIZE = CON_PACKAGE_MIN.
      ELSEIF LD_PACKAGE_SIZE > CON_PACKAGE_MAX.
        LD_PACKAGE_SIZE = CON_PACKAGE_MAX.
      ENDIF.
*     Auftragstabelle abarbeiten
      LD_PACKAGE_START = GD_OBJ_DONE + 1.               "From-Index
      LD_PACKAGE_END   = GD_OBJ_DONE + LD_PACKAGE_SIZE. "To-Index
      CLEAR LD_PEND_OBJ.
      CLEAR LD_OBJDATA.
      LOOP AT P_USER_PARAM-OBJECTS INTO LD_OBJDATA
          FROM LD_PACKAGE_START
          TO   LD_PACKAGE_END.
        APPEND LD_OBJDATA TO LT_OBJECTS.
*       Setze Index der noch zu bearbeitenden Aufträge hoch
        ADD 1 TO GD_OBJ_DONE.
        LD_PEND_OBJ-OBJ_ID = GD_OBJ_DONE.    "entspricht Index in Tab.
        APPEND LD_PEND_OBJ TO P_PENDING_OBJS.
      ENDLOOP.
    ENDIF.
  ELSE.
*   Failed_Objects war gefüllt  => genau ersten Auftrag in Einzelpaket
    READ TABLE P_FAILED_OBJS INTO LD_FAIL_OBJ INDEX 1.
*   Pending_Objects wie Failed_Objects füllen
    APPEND LD_FAIL_OBJ TO P_PENDING_OBJS.
    LD_TABIX = LD_FAIL_OBJ-OBJ_ID.
    READ TABLE P_USER_PARAM-OBJECTS INDEX LD_TABIX INTO LD_OBJDATA.
    APPEND LD_OBJDATA TO LT_OBJECTS.
    DELETE P_FAILED_OBJS INDEX 1. "Abgesch. Eintrag aus failed_objs raus
  ENDIF."p_failed_objs[] is initial.

* Überprüfe, ob danach noch weitere Aufträge abzuarbeiten
  IF GD_OBJ_DONE EQ P_USER_PARAM-TO_DO AND P_FAILED_OBJS[] IS INITIAL.
*   Keine weiteren Aufträge und keine fehlerhaften Objekte mehr
    P_PARA_EXP-ALL_SUBMIT = 'X'.
  ENDIF.

* Falls keine Aufträge bereitgestellt (sollte nicht auftreten)
  READ TABLE LT_OBJECTS INDEX 1.
  IF SY-SUBRC <> 0.
    P_PARA_EXP-RFC_SUBRC  = KKPA_RFC_SUBRC-RFC_NOT_STARTED.
    P_PARA_EXP-ALL_SUBMIT = 'X'.
    EXIT. "zurück zum aufrufenden Parallel-Handler (KKPA)
  ENDIF.

  if gd_scma_worklists_active = yes.                         "I_46A_SCMA
* Hole SCMA-Worklists-Kontext für externe Task               "I_46A_SCMA
    CALL FUNCTION 'KPEP_WLA_RFC_CONTEXT_PREPARE'             "I_46A_SCMA
         IMPORTING                                           "I_46A_SCMA
              WL_CONTEXT = SCMA_WORKLISTS_CONTEXT            "I_46A_SCMA
              .                                              "I_46A_SCMA
  endif.                                                     "I_46A_SCMA

*    Starte Task
  CALL FUNCTION 'KKA_PARA_ORDER_WIP'
        STARTING NEW TASK P_PARA_IMP-TASKNAME
        DESTINATION P_PARA_IMP-TASKDEST
        PERFORMING END_OF_TASK_PROC ON END OF TASK
        EXPORTING
             I_KKAPARA_IN  = P_USER_PARAM-PARAMS
        TABLES
             OBJECTS_TAB   = LT_OBJECTS
             VERSION_TAB   = P_USER_PARAM-VERSIONS
             PROTOKOLL_TAB = LT_DUMMY_PROT
             FEHLAUFT_TAB  = LT_DUMMY_FEHLAUFT
             SCMA_WORKLISTS_CONTEXT = SCMA_WORKLISTS_CONTEXT
        EXCEPTIONS
             SYSTEM_FAILURE        = 1 MESSAGE LD_RFC_MSG
             COMMUNICATION_FAILURE = 2 MESSAGE LD_RFC_MSG
             OTHERS                = 3.
* Achtung: Die nachfolgende Coding-Strecke darf nur mittels Breakpoint
********** angehalten werden, wenn auch vor receive results BP gesetzt.
  LD_SUBRC = SY-SUBRC.
* ZUM DEBUGGEN *********************************************************
  IF     NOT SY-BATCH IS INITIAL
     AND NOT SY-SUBRC IS INITIAL
     AND NOT P_PARA_IMP-DEBUG_MODE IS INITIAL.
*   Anweisungen für Debug-Mode im Batch
    DATA: MSGV1(80) TYPE C.
    CONCATENATE 'Taskstart RC' LD_SUBRC  "#EC NOTEXT
        P_PARA_IMP-TASKNAME P_PARA_IMP-TASKDEST
        INTO MSGV1 SEPARATED BY SPACE.
    MESSAGE I002(RK) WITH MSGV1 ' ' ' ' ' '.
    IF NOT LD_RFC_MSG IS INITIAL.
*     message i002(rk) with 'Message was: ' ld_rfc_msg. "#EC NOTEXT D46A
*     NICHT MEHR ERLAUBT: Fuehrt zum DUMP                           D46A
    ENDIF.
  ENDIF.
* ZUM DEBUGGEN *********************************************************

  CASE LD_SUBRC.
    WHEN 0. "nichts zu tun
    WHEN 1. "system_failure
      P_PARA_EXP-RFC_SUBRC = KKPA_RFC_SUBRC-SYSTEM_FAILURE.
      P_PARA_EXP-RFC_MSG   = LD_RFC_MSG.
    WHEN 2. "communication_failure
      P_PARA_EXP-RFC_SUBRC = KKPA_RFC_SUBRC-COMMUNICATION_FAILURE.
      P_PARA_EXP-RFC_MSG   = LD_RFC_MSG.
    WHEN 3. "others
      P_PARA_EXP-RFC_SUBRC = KKPA_RFC_SUBRC-APPLICATION_ERROR.
    WHEN OTHERS.
      RAISE KKA07F01_UNEXPECTED_SUBRC.
  ENDCASE.
ENDFORM.                    " WIP_START_PARALLEL_TASK

*eject
*&---------------------------------------------------------------------*
*&      Form  WIP_PARA_RESULTS
*&---------------------------------------------------------------------*
*       Asynchrone Entgegennahme des Ergebnisses eines WIP-Tasks
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM WIP_PARA_RESULTS
   USING
      P_PARA_IMP      TYPE KKPA_T_PARA_IMP
      P_PENDING_OBJS  TYPE KKPA_T_PENDING_OBJECTS
   CHANGING
      P_PARA_EXP      TYPE KKPA_T_PARA_EXP
      P_USER_PARAM    TYPE T_USER_PARAM.

DATA:
    LD_RFC_MSG   TYPE KKPA_T_RFCMSG,
    LD_SUBRC     LIKE SY-SUBRC,
    LD_TABIX     LIKE SY-TABIX,
    LD_PEND_OBJ  TYPE LINE OF KKPA_T_PENDING_OBJECTS,
    LD_OBJ_TOTAL LIKE SY-TABIX,
    LD_OBJ_ERROR LIKE SY-TABIX,
    LD_OBJ_NOT_REL LIKE SY-TABIX,                            "46B
    LT_PROTOKOLL  LIKE CMFMSG OCCURS 0 WITH HEADER LINE,"gefülltes Prot
    LT_OBJECTS    LIKE KKAPARA_TA OCCURS 0 WITH HEADER LINE,
    LT_FEHLAUFT   LIKE KKAPARA_FA OCCURS 0 WITH HEADER LINE,
    LT_VERS       LIKE KKAPARA_VS OCCURS 0 WITH HEADER LINE.
DATA: SCMA_WORKLISTS_CONTEXT type SPTA_INDXTAB.    "I_46A_SCMA

* Ergebnisse abholen
  RECEIVE RESULTS FROM FUNCTION 'KKA_PARA_ORDER_WIP'
       IMPORTING
            OBJ_TOTAL     = LD_OBJ_TOTAL
            OBJ_ERROR     = LD_OBJ_ERROR
            OBJ_NOT_REL   = LD_OBJ_NOT_REL                   "46B
       TABLES
            OBJECTS_TAB   = LT_OBJECTS
            VERSION_TAB   = LT_VERS      "only used as dummy here
            PROTOKOLL_TAB = LT_PROTOKOLL
            FEHLAUFT_TAB  = LT_FEHLAUFT
            SCMA_WORKLISTS_CONTEXT = SCMA_WORKLISTS_CONTEXT  "I_46A_SCMA
       EXCEPTIONS
            SYSTEM_FAILURE        = 1 MESSAGE LD_RFC_MSG
            COMMUNICATION_FAILURE = 2 MESSAGE LD_RFC_MSG
            OTHERS                = 3.

  LD_SUBRC = SY-SUBRC.
* ZUM DEBUGGEN *********************************************************
  IF     NOT SY-BATCH IS INITIAL
     AND NOT SY-SUBRC IS INITIAL
     AND NOT P_PARA_IMP-DEBUG_MODE IS INITIAL.
*   Anweisungen für Debug-Mode im Batch
    DATA: MSGV1(80) TYPE C, MSGV2(80) TYPE C,
          LD_RC_SHOW(4) TYPE N.
    LD_RC_SHOW = LD_SUBRC.
    CONCATENATE 'Receive   RC' LD_RC_SHOW      "#EC NOTEXT
        P_PARA_IMP-TASKNAME P_PARA_IMP-TASKDEST
        INTO MSGV1 SEPARATED BY SPACE.
    MESSAGE I002(RK) WITH MSGV1 ' ' ' ' ' '.
    IF NOT LD_RFC_MSG IS INITIAL.
      MESSAGE I002(RK)
         WITH 'Message was: ' LD_RFC_MSG ' ' ' ' . "#EC NOTEXT
    ENDIF.
  ENDIF.
* ZUM DEBUGGEN *********************************************************

  CASE LD_SUBRC.
    WHEN 0.
      CLEAR P_PARA_EXP-RFC_SUBRC.
* Erhaltenes Fehlerprotokoll an globales Protokoll anfügen
      IF ANZEIGEN NE YES.                               "NUR ANZEIGEN
        CALL FUNCTION 'CM_F_CMFMSG_MESSAGES_PUT'
         EXPORTING
               APPEND_SAME_MSG = 'X' "weil z.Z. noch Meldungen pro Auft
*              APLID           = ' '
           TABLES
               I_MSGPROT       =  LT_PROTOKOLL.
      ENDIF.                                            "NUR ANZEIGEN
* Einträge der zurückgegebenen Tab. LT_OBJECTS an T_AUFTLST anhängen
      APPEND LINES OF LT_OBJECTS TO T_AUFTLST.
* Einträge der zurückgeg. Tab. LT_FEHLAUFT in Arbeitsvorrat schreiben
      IF NOT P_ALOG IS INITIAL.
        LOOP AT LT_FEHLAUFT.
          CALL FUNCTION 'CO_APPL_LOG_APPEND_AUFNR'
            EXPORTING AUFNR = LT_FEHLAUFT-AUFNR.
*           exceptions others  = 1.
        ENDLOOP.
      ENDIF. "not p_alog

* Beginning I_46A_SCMA:
      IF gd_scma_worklists_active = yes.
        CALL FUNCTION 'KPEP_WLA_RFC_CONTEXT_INTERPRET'
             EXPORTING
                  wl_context = SCMA_WORKLISTS_CONTEXT
                  .
      ENDIF.
* End I_46A_SCMA

* Erhaltene Auftragszähler aufaddieren
      ADD LD_OBJ_TOTAL TO ABGR_OBJ_TOTAL.
      ADD LD_OBJ_ERROR TO ABGR_OBJ_NOT_DONE.
      ADD LD_OBJ_NOT_REL TO GD_NOT_RELEVANT.                 "46B

    WHEN 1. "System_failure
      P_PARA_EXP-RFC_SUBRC = KKPA_RFC_SUBRC-SYSTEM_FAILURE.
      P_PARA_EXP-RFC_MSG   = LD_RFC_MSG.
      DESCRIBE TABLE P_PENDING_OBJS LINES LD_TABIX.
* Nur 1 Objekt in Pending-Objects (nur 1 Auftrag war zu bearbeiten)
* => Diesen Auftrag als fehlerhaft im Protokoll vermerken
* Bei mehreren Objekten dagegen Einzel-Verarbeitung in Start-form
      IF LD_TABIX = 1.
*       Fehler in Protokoll ausgeben. An Dispatcher OK melden
        P_PARA_EXP-RFC_SUBRC = KKPA_RFC_SUBRC-NO_ERROR.
        READ TABLE P_PENDING_OBJS INDEX 1 INTO LD_PEND_OBJ.
*       Über Index Auftragsnummer für Message besorgen
        READ TABLE T_AUFTRAG INDEX LD_PEND_OBJ-OBJ_ID.
        IF ANZEIGEN NE YES.                             "NUR ANZEIGEN
*         call function 'CM_F_SET_OBJECT'                    "30F_rk003
*              exporting                                     "30F_rk003
*                  object    = t_auftrag-aufnr               "30F_rk003
*                  object_id = abgr_object_id.               "30F_rk003
          LT_VERS-VERSA = T_AUFTRAG-VERSN.                       "I_40C
          PERFORM CM_F_SET_OBJECT                                "I_40C
              USING T_AUFTRAG                                    "I_40C
                    LT_VERS.                                     "I_40C
*                   lcon_step.                                   "*_40C
          CALL FUNCTION 'CM_F_MESSAGE'
            EXPORTING
               ARBGB            = 'RK'
               MSGNR            = '003'
               MSGTY            = 'E'
               MSGV1            = T_AUFTRAG-AUFNR
               MSGV2            = P_PARA_IMP-TASKDEST
               MSGV3            = KKPA_RFC_SUBRC_TXT-SYSTEM_FAILURE
               MSGV4            = LD_RFC_MSG
               OBJECT_DEPENDENT = 'X'.
* Beginning I_46A_SCMA:
*  gd_num_msgs_new = gd_num_msgs_new + 1.                      "187150
* Wert muß immer aus Messagehandler geholt werden, da wg.
* flexibler Fehlersteuerung Meldung möglicherweise nicht
* ausgegeben wird.
  CALL FUNCTION 'CM_F_INFO'                                    "187150
       EXPORTING
            all             = 'X'
            aplid           = abgr_aplid
            object          = abgr_object_id
       IMPORTING
            msg_counter_pro = gd_num_msgs_new
       EXCEPTIONS
            wrong_object_id = 0
            OTHERS          = 0.
* End I_46A_SCMA
       ENDIF.                                          "NUR ANZEIGEN
*       Außerdem Auftrag in Liste, falls Schalter FEHLAUFT gesetzt
        IF NOT FEHLAUFT IS INITIAL.
          MOVE-CORRESPONDING T_AUFTRAG TO T_AUFTLST.
          T_AUFTLST-AMPEL = CON_ROT.
          T_AUFTLST-MAXNT = 'E'.
          APPEND T_AUFTLST.
        ENDIF. "not fehlauft
*       Falls Arbeitsvorrat zu erzeugen, muß Auftrag hinein
        IF NOT P_ALOG IS INITIAL.
         CALL FUNCTION 'CO_APPL_LOG_APPEND_AUFNR'
            EXPORTING AUFNR = T_AUFTRAG-AUFNR.
*           exceptions others  = 1.
        ENDIF. "not p_alog
* Beginning I_46A_SCMA:
        IF gd_scma_worklists_active = yes.
          perform handle_status_wl
            using
              t_auftrag
              KPEPW_OBJSTAT-ERROR
              no.   "changed
        ENDIF.
* End I_46A_SCMA
      ENDIF. "ld_tabix
    WHEN 2. "Communication_failure
      P_PARA_EXP-RFC_SUBRC = KKPA_RFC_SUBRC-COMMUNICATION_FAILURE.
      P_PARA_EXP-RFC_MSG   = LD_RFC_MSG.
    WHEN OTHERS. "Eigene Exception des RFC-FB => APPLICATION ERROR
*     Coding wie bei System_failure, nur ohne ld_rfc_msg
      P_PARA_EXP-RFC_SUBRC = KKPA_RFC_SUBRC-APPLICATION_ERROR.
      DESCRIBE TABLE P_PENDING_OBJS LINES LD_TABIX.
      IF LD_TABIX = 1.
*       Fehler in Protokoll ausgeben. An Dispatcher OK melden
        P_PARA_EXP-RFC_SUBRC = KKPA_RFC_SUBRC-NO_ERROR.
        READ TABLE P_PENDING_OBJS INDEX 1 INTO LD_PEND_OBJ.
*       Über Index Auftragsnummer für Message besorgen
        READ TABLE T_AUFTRAG INDEX LD_PEND_OBJ-OBJ_ID.
        IF ANZEIGEN NE YES.                             "NUR ANZEIGEN
*         call function 'CM_F_SET_OBJECT'                    "30F_rk003
*              exporting                                     "30F_rk003
*                  object    = t_auftrag-aufnr               "30F_rk003
*                  object_id = abgr_object_id.               "30F_rk003
          LT_VERS-VERSA = T_AUFTRAG-VERSN.                       "I_40C
          PERFORM CM_F_SET_OBJECT                                "I_40C
              USING T_AUFTRAG                                    "I_40C
                    LT_VERS.                                     "I_40C
*                   lcon_step.                                   "*_40C
          CALL FUNCTION 'CM_F_MESSAGE'
            EXPORTING
               ARBGB            = 'RK'
               MSGNR            = '003'
               MSGTY            = 'E'
               MSGV1            = T_AUFTRAG-AUFNR
               MSGV2            = P_PARA_IMP-TASKDEST
               MSGV3            = KKPA_RFC_SUBRC_TXT-APPLICATION_ERROR
               MSGV4            = LD_RFC_MSG
               OBJECT_DEPENDENT = 'X'.
* Beginning I_46A_SCMA:
*  gd_num_msgs_new = gd_num_msgs_new + 1.                      "187150
* Wert muß immer aus Messagehandler geholt werden, da wg.
* flexibler Fehlersteuerung Meldung möglicherweise nicht
* ausgegeben wird.
  CALL FUNCTION 'CM_F_INFO'                                    "187150
       EXPORTING
            all             = 'X'
            aplid           = abgr_aplid
            object          = abgr_object_id
       IMPORTING
            msg_counter_pro = gd_num_msgs_new
       EXCEPTIONS
            wrong_object_id = 0
            OTHERS          = 0.
* End I_46A_SCMA
        ENDIF.                                          "NUR ANZEIGEN
*       Außerdem Auftrag in Liste, falls Schalter FEHLAUFT gesetzt
        IF NOT FEHLAUFT IS INITIAL.
          MOVE-CORRESPONDING T_AUFTRAG TO T_AUFTLST.
          T_AUFTLST-AMPEL = CON_ROT.
          T_AUFTLST-MAXNT = 'E'.
          APPEND T_AUFTLST.
        ENDIF. "not fehlauft
*       Falls Arbeitsvorrat zu erzeugen, muß Auftrag hinein
        IF NOT P_ALOG IS INITIAL.
         CALL FUNCTION 'CO_APPL_LOG_APPEND_AUFNR'
            EXPORTING AUFNR = T_AUFTRAG-AUFNR.
*           exceptions others  = 1.
        ENDIF. "not p_alog
* Beginning I_46A_SCMA:
        IF gd_scma_worklists_active = yes.
          perform handle_status_wl
            using
              t_auftrag
              KPEPW_OBJSTAT-ERROR
              no.   "changed
        ENDIF.
* End I_46A_SCMA
      ENDIF. "ld_tabix
  ENDCASE.

ENDFORM.                    " WIP_PARA_RESULTS

*&---------------------------------------------------------------------*
*&      Form  END_OF_TASK_PROC
*&---------------------------------------------------------------------*
*   Bei einem RFC wird autom. diese FORM nach Ende des Tasks aufgerufen
*   und sorgt hier für das Anstoßen der entsprechende WIP-Ende Routine
*----------------------------------------------------------------------*
*  -->  p_taskname
*----------------------------------------------------------------------*
FORM END_OF_TASK_PROC
   USING
      P_TASKNAME.
   PERFORM (GD_EOT-FORM) IN PROGRAM (GD_EOT-PROG)
      USING
         P_TASKNAME.
ENDFORM.  " END_OF_TASK_PROC

*eject
*&---------------------------------------------------------------------*
*&      Form  WIP_PARA_CALC
*&---------------------------------------------------------------------*
*      Durchführung der parallelen WIP-Ermittlung                      *
*----------------------------------------------------------------------*
* pt_auftrag_par: --> Liste der zu bearbeitenden Aufträge
* pt_auftrag_par: <-- Liste mit den Ausgabezeilen
*----------------------------------------------------------------------*
FORM WIP_PARA_CALC
  TABLES
    PT_AUFTRAG_PAR     STRUCTURE KKAPARA_TA
    PT_ABGRVERS        STRUCTURE KKAPARA_VS
    PT_PROTOKOLL       STRUCTURE CMFMSG
    PT_FEHLAUFT        STRUCTURE KKAPARA_FA
    PT_SCMA_WL_CONTEXT TYPE      SPTA_INDXTAB             "I_46A_SCMA
  USING
    P_PARAMS           LIKE KKAPARA_IN
    P_OBJ_NOT_REL      LIKE SY-TABIX                      "46B
    P_OBJ_TOTAL        LIKE SY-TABIX
    P_OBJ_ERROR        LIKE SY-TABIX.

* Datendefinitionen
CONSTANTS NO_ALOG  LIKE KKAPARA_IN-P_ALOG  VALUE SPACE.
* Liste der Ausgabezeilen (am Schluß in pt_auftrag_par zurückgegeben)
DATA: LT_AUFTLST LIKE KKAPARA_TA OCCURS 0 WITH HEADER LINE.
DATA: LD_WAEHR LIKE T001-WAERS,   "gerechnete Währung, pro Auftr. erm.
      LD_FEHLERAUFTRAG(1) TYPE C.     "zeigt fehlerhaften Auftrag an

* Versorge benötigte Tabellen
* 1. pt_auftrag_par enthält Aufträge wie in T_AUFTRAG         +*********
LOOP AT PT_AUFTRAG_PAR.
  MOVE-CORRESPONDING PT_AUFTRAG_PAR TO T_AUFTRAG.
  APPEND T_AUFTRAG.
ENDLOOP.
* refresh pt_auftrag_par.                                    "D_40A_XBN
* "Löschen, da später neu versorgt für Rückgabe              "D_40A_XBN
APPEND LINES OF PT_ABGRVERS TO ABGR_VSN.   " Versionstabelle versorgen
* refresh pt_abgrvers.       " und leer zurückgeben          "D_40A_XBN
*  Initialisiere globale Variablen nicht, da direkt verwendet
*abgrmona    = p_params-abgrmona.                               "40A
*abgrjahr    = p_params-abgrjahr.                               "40A
*gd_ta_waehr = p_params-waehr.                                  "40A
*fehlauft    = p_params-fehlauft.                               "40A
*p_maxnta    = p_params-p_maxnta.                               "40A
*no_0_wip    = p_params-no_0_wip.                            "I_40A_0WIP
*withimsg    = p_params-withimsg.                               "40A
*ausfuehr    = p_params-ausfuehr.                               "40A
*simulati    = p_params-simulati.                               "40A
*anzeigen    = p_params-anzeigen.                               "40A
P_OBJ_TOTAL = 0.
P_OBJ_ERROR = 0.
P_OBJ_NOT_REL = 0.                                              "46B
CLEAR: GS_OLDTOTAL, GS_NEWTOTAL.

* Erneute Verprobung von Berechtigung (wegen RFC)
  PERFORM BERECHTIGUNG_PRUEFEN USING '03' 'KABG'.
  PERFORM BERECHTIGUNG_PRUEFEN USING '03' 'KABM'.
  IF P_PARAMS-AUSFUEHR EQ YES.
    PERFORM BERECHTIGUNG_PRUEFEN USING '02' 'KABG'.
  ELSEIF P_PARAMS-SIMULATI EQ YES.
    PERFORM BERECHTIGUNG_PRUEFEN USING '48' 'KABG'.
  ENDIF.

* Beginning I_46A_SCMA:
  if p_params-scma_worklists_active = yes.
    CALL FUNCTION 'KPEP_WLA_RFC_CONTEXT_INIT'
         EXPORTING
              wl_context = PT_SCMA_WL_CONTEXT[]
              .
  endif.
* End I_46A_SCMA

* Initialisiere Message-Handler für diesen Task (nicht im AnzeigenMode)
IF P_PARAMS-ANZEIGEN NE YES.               "NICHT IM ANZEIGEN
  CALL FUNCTION 'CM_F_INITIALIZE'
      EXPORTING ABORT_MSGTY            = ABGR_ABORT_MSGTY
                APLID                  = ABGR_APLID
                MSG_ON_SCREEN          = NO
                OBJECT_ID              = ABGR_OBJECT_ID
                OCS_ACTIV              = NO
                REFRESH_OLD_LOG        = YES
                NO_OTHER_INITIALIZE    = YES                    "H400509
                NO_DISPLAY_ON_ABORT    = 'X'                   "45B_RFC
                SMSG_INITIALIZE        = NO.
*     EXCEPTIONS MESSAGE_TYPE_NOT_VALID = 01
*                UNKNOWN_APLID          = 02
*                UNKNOWN_OBJECT_ID      = 03.
ENDIF.
LOOP AT PT_AUFTRAG_PAR.
  PERFORM AUFTRAG_LOOP
              TABLES PT_ABGRVERS
                     LT_AUFTLST
              USING  PT_AUFTRAG_PAR
                     P_PARAMS
                     P_OBJ_NOT_REL                                 "46B
                     P_OBJ_TOTAL
                     P_OBJ_ERROR
                     LD_FEHLERAUFTRAG.
* Wenn fehlerhafter Auftrag, dann muß dieser in Actionlog-Tabelle
  IF NOT LD_FEHLERAUFTRAG IS INITIAL.
*   Kopfzeile füllen
    PT_FEHLAUFT = PT_AUFTRAG_PAR-AUFNR.
    APPEND PT_FEHLAUFT.
  ENDIF.
  CLEAR LD_FEHLERAUFTRAG.         "clearen für nächsten Auft.
ENDLOOP. " loopt über Auftragspaket (in T_AUFTRAG kopiert)

* Protokoll zurückgeben
IF P_PARAMS-ANZEIGEN NE YES.
  CALL FUNCTION 'CM_F_MESSAGES_GET'
*      EXPORTING
*           APLID      = ' '
      TABLES
            E_MSGPROT  = PT_PROTOKOLL.
ENDIF.

* Rückgabeparameter versorgen
REFRESH PT_AUFTRAG_PAR.
PT_AUFTRAG_PAR[] = LT_AUFTLST[].
REFRESH PT_ABGRVERS.                  " leer zurückgeben

* Beginning I_46A_SCMA:
  if p_params-scma_worklists_active = yes.
    CALL FUNCTION 'KPEP_WLA_RFC_CONTEXT_EXIT'
         IMPORTING
              WL_CONTEXT = PT_SCMA_WL_CONTEXT[]
              .
  endif.
* End I_46A_SCMA

ENDFORM.                    " WIP_PARA_CALC