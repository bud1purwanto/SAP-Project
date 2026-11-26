*N744242 Clean up for Selection Screens
REPORT rqeeal10 MESSAGE-ID ih NO STANDARD PAGE HEADING.
ENHANCEMENT-POINT RQEEAL10_G4 SPOTS ES_RQEEAL10 STATIC.
ENHANCEMENT-POINT RQEEAL10_G5 SPOTS ES_RQEEAL10.
ENHANCEMENT-POINT RQEEAL10_G6 SPOTS ES_RQEEAL10 STATIC.
ENHANCEMENT-POINT RQEEAL10_G7 SPOTS ES_RQEEAL10.

INCLUDE rqalvtop.


TABLES: qals, qavp.

* INTERNAL TABLES
DATA: BEGIN OF object_tab OCCURS 0.
        INCLUDE STRUCTURE qals_d02.
DATA: kz_qave.
DATA: selected.
DATA: lights.
DATA: viewed TYPE pm_selected.
DATA: END OF object_tab.

*data: g_tabarg  like tih01-tabname.    "Tabellenargument Feldauswahl
*data: gt_extab type slis_t_extab.      "moved to TOP include
*data: g_structure like t370a-tabname value 'QALS_D02'.    "in TOP
*  Berechtigungspuffer
DATA: BEGIN OF g_auth,
      art         LIKE qals-art,
      werk        LIKE qals-werk,
      ok          LIKE qm00-qkz,
     END OF g_auth,
*  Anzahl Lose mit fehlender Berechtigung
   g_anz_no_auth    TYPE i.


DATA c_tcode           LIKE sy-tcode       VALUE 'QA33'.
DATA g_tcode           LIKE sy-tcode.

*data g_aktyp.       " has value V(display) or A(change)

* Datendeklaration für Unicodeumstellung
DATA: MESSAGE_TEXT TYPE SLIS_VARBZ.

* PARAMETERS --------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bottom WITH FRAME TITLE text-p00.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_alles RADIOBUTTON GROUP ud.
*SELECTION-SCREEN COMMENT 3(70) text-p03.                       "N744242
SELECTION-SCREEN COMMENT 3(70) text-p03 for field p_alles.      "N744242
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_no_ud RADIOBUTTON GROUP ud.
*SELECTION-SCREEN COMMENT 3(70) text-p01.                       "N744242
SELECTION-SCREEN COMMENT 3(70) text-p01 for field p_no_ud.      "N744242
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_ud RADIOBUTTON GROUP ud.
*SELECTION-SCREEN COMMENT 3(70) text-p02.                       "N744242
SELECTION-SCREEN COMMENT 3(70) text-p02 for field p_ud.         "N744242
SELECTION-SCREEN END OF LINE.

PARAMETERS: variant LIKE disvariant-variant.
PARAMETERS: monitor LIKE rqmonitor-qm_monitor
            as listbox visible length 30.
SELECTION-SCREEN END OF BLOCK bottom.
*-- Mit diesen Selektionskriterien wird der optimale Zugriff auf
*   Prüflose ohne Verwendungsentscheid.
SELECT-OPTIONS:
  s_stat35 FOR qals-stat35 NO-DISPLAY.
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR variant.
  PERFORM variant_inputhelp_f14 USING variant.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR monitor.
  PERFORM create_monitor_tab_f16.
  PERFORM monitor_inputhelp_f16 USING monitor.
*--------------------------------------------------------------------*
* AT SELECTION SCREEN OUTPUT                                         *
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  CHECK g_submit IS INITIAL.
* Fcode FC01 bei Variantenpflege deaktivieren
  PERFORM user_fc_steuern.

*--------------------------------------------------------------------*
* AT SELECTION SCREEN                                                *
*--------------------------------------------------------------------*
*------------------------------*
AT SELECTION-SCREEN ON RADIOBUTTON GROUP ud.
*
  REFRESH s_stat35.
  IF NOT p_no_ud IS INITIAL.
*-- nur Prueflose mit STAT35 = ' '
    s_stat35-low    = ' '.
    s_stat35-sign   = 'I'.
    s_stat35-option = 'EQ'.
    APPEND s_stat35.
  ELSEIF NOT p_ud IS INITIAL.
*-- nur Prueflose mit STAT35 = 'X'
    s_stat35-low    = 'X'.
    s_stat35-sign   = 'I'.
    s_stat35-option = 'EQ'.
    APPEND s_stat35.
  ENDIF.
*------------------------------*
AT SELECTION-SCREEN.
  PERFORM variant_existence_f14 USING variant.     "check for Cust. var.

  CHECK g_submit IS INITIAL.
  g_variant-variant = variant.
*== F-Code verarbeiten
  IF sscrfields-ucomm EQ 'FC01'.
*-- User-Variante einstellen
    PERFORM variant_f10.
*   neuer Aufruf um Variante zu uebernehmen
    IF sy-tcode = 'SE38'
    OR sy-tcode = 'SA38'.
      SUBMIT (sy-repid) VIA SELECTION-SCREEN.
    ELSE.
      LEAVE TO TRANSACTION sy-tcode.
    ENDIF.
  ENDIF.

*--------------------------------------------------------------------*
* INITIALIZATION                                                     *
*--------------------------------------------------------------------*
INITIALIZATION.

* Performance: Preread auf die JEST, da Vorgänge geprüft werden
* move g_x to G_STATUS_PREREAD.

*--- Aktivitätstyp bestimmen -----------------------------------------
  SELECT SINGLE * FROM t370a WHERE tcode = sy-tcode.
  IF sy-subrc <> 0.
    SELECT SINGLE * FROM t370a WHERE tcode = c_tcode.
    IF sy-subrc <> 0.
      RAISE tcode_not_in_t370a.
    ENDIF.
  ENDIF.

  MOVE 'QALS_D02' TO g_tabname.
  IF NOT sy-calld IS INITIAL.
    IMPORT g_submit g_fieldcat_tab FROM MEMORY ID 'SUBMIT'.
  ENDIF.

*-------------------------------------------------------------------*
  message_text = text-tes.
  PERFORM variant_init_f14 USING 'LOTS'
                                 'LOTS'
*                                text-tes.
                                 message_text.
  CHECK g_submit IS INITIAL.
*-- Report-Selektionsvariante lesen
  PERFORM variant_start_f10.
*-- ALV-Anzeigevariante vorschlagen
  IF NOT variant IS INITIAL.
    PERFORM get_default_variant_f14 USING variant.
*   Wenn die angegebene ALV-Anzeigevariante nicht existiert, ist der
*   Parameter variant jetzt leer.
  ENDIF.
  IF variant IS INITIAL.
*   Default-Anzeigevariante suchen
    PERFORM get_default_variant_f14 USING variant.
  ENDIF.

*---------------------------------------------------------------------*
  SELECTION-SCREEN
*-- FUNCTION KEYS
    FUNCTION KEY 1.
*-- DEFINE FUNCTION KEYS ON INITIAL SCREEN
  sscrfields-functxt_01 = 'Meine Vorbelegung   '(f01).

*---------------------------------------------------------------------*
* START OF SELECTION                                                  *
*---------------------------------------------------------------------*
START-OF-SELECTION.


*--- Aktivitätstyp bestimmen -----------------------------------------
  dy_tcode = sy-tcode.
  SELECT SINGLE * FROM t370a WHERE tcode = dy_tcode.
  IF sy-subrc <> 0.
    SELECT SINGLE * FROM t370a WHERE tcode = c_tcode.
    IF sy-subrc <> 0.
      RAISE tcode_not_in_t370a.
    ENDIF.
  ENDIF.

  IF g_submit IS INITIAL.
    PERFORM create_fieldcat_l USING g_tabname.
    PERFORM update_fieldcat_variant_f14.
  ENDIF.
  PERFORM select_fields_manip2_f16   USING g_fieldcat_tab.

*Stati are checked in this report. Therefore JEST is preread
  MOVE g_x TO preread.

*-------------------------------------------------------------------*
* GET                                                               *
*-------------------------------------------------------------------*

ENHANCEMENT-SECTION     RQEEAL10_03 SPOTS ES_RQEEAL10 STATIC .
GET qals FIELDS prueflos
                obtyp
                objnr
                aufpl
                art                    "for authorization
                werk                   "for authorization
                offennlzmk             "for monitor
                offen_lzmk             "for monitor
                pastrterm              "for monitor
                paendterm              "for monitor
                lmengezub              "for monitor
                aufnr_co
                plnty
                stat02
                stat07
                stat35.
END-ENHANCEMENT-SECTION.

* Prüfartenberechtigung prüfen mit Puffer
  IF    g_auth-art  NE qals-art
    OR g_auth-werk  NE qals-werk.
*   Berechtigung hat sich geändert, neu prüfen
    MOVE-CORRESPONDING qals TO g_auth.
    CALL FUNCTION 'QAUT_INSPTYPE'
         EXPORTING
              i_pruefart       = g_auth-art
              i_werk           = g_auth-werk
         EXCEPTIONS
              no_authorization = 1.

*     Berechtigung vorhanden
    IF sy-subrc IS INITIAL.
      MOVE g_x TO g_auth-ok.
    ELSE.
      CLEAR g_auth-ok.
      REJECT.
    ENDIF.
  ENDIF.
* Berechtigung prüfen
  IF g_auth-ok EQ space.
*   keine Berechtigung
    ADD 1 TO g_anz_no_auth.
    REJECT.
  ENDIF.

* FILL INTERNAL TABLE
  CLEAR object_tab.
  MOVE-CORRESPONDING qals TO object_tab.
  MOVE qals-stat35 TO object_tab-kz_qave.
  PERFORM set_monitor_f16.

* GENERATE STATUS AND USER TEXTS
  CALL FUNCTION 'STATUS_TEXT_EDIT'
       EXPORTING
            objnr            = qals-objnr
            flg_user_stat    = g_x
            spras            = sy-langu
       IMPORTING
            line             = object_tab-sttxt
            user_line        = object_tab-ustxt
       EXCEPTIONS
            object_not_found = 01.
  IF sy-subrc NE 0.
    CLEAR object_tab-sttxt.
    CLEAR object_tab-ustxt.
  ENDIF.

*Logic is as follows: If UD data is not required, object_tab is
*appended. If it is required, a flag is set which is then changed at GET
* QAVP to account for the dynamic selections.

if not p_no_ud is initial or
not p_alles is initial and qals-stat35 eq space.  " Ignore UD fields

*   kein VE zu lesen

ENHANCEMENT-POINT RQEEAL10_01 SPOTS ES_RQEEAL10 STATIC.

ENHANCEMENT-POINT RQEEAL10_02 SPOTS ES_RQEEAL10.

    APPEND object_tab.
    REJECT.
   else.
*elseif qals-stat35 eq g_x.
    move 'Y' to qals-stat35.
  ENDIF.

GET qavp FIELDS prueflos.
  MOVE-CORRESPONDING qavp TO object_tab.
  move g_x to qals-stat35.

GET qals LATE FIELDS prueflos obtyp objnr  aufpl
                     aufnr_co plnty stat02 stat07.

  if qals-stat35 eq g_x.
    APPEND object_tab.
  endif.


*GET qavp FIELDS prueflos.
*  MOVE-CORRESPONDING qavp TO object_tab.
*
*GET qals LATE FIELDS prueflos obtyp objnr  aufpl
*                     aufnr_co plnty stat02 stat07.
*  APPEND object_tab.
*
*--------------------------------------------------------------------*
* END OF SELECTION                                                   *
*--------------------------------------------------------------------*
END-OF-SELECTION.
  IF g_anz_no_auth GT 0.
*   Lose ohne Berechtigung vorhanden
    MESSAGE s046.
    CLEAR g_anz_no_auth.
  ENDIF.
  IF g_submit = 'X'.
* CALL MODUS FOR REFRESH
    EXPORT object_tab TO MEMORY ID g_repid.
  ELSE.
* TESTLAUF is set in DBPGQSEL. It has nothing to do with this report,
* but shows up in the selection criteria popup if it isn't cleared.
*   CLEAR TESTLAUF.
*   CLEAR G_FORM_TOP_OF_PAGE.
    CLEAR dy_tcode.
    PERFORM fill_events_f14.
    PERFORM fill_event_exit_tab_f14.
    PERFORM fill_layout_f16.
    PERFORM get_fieldcat_actual_f16.
    PERFORM fill_fieldgroups_f16.
    PERFORM CALL_LISTVIEWER_F14 using G_FIELDCAT_TAB[] OBJECT_TAB[].
  ENDIF.

*---------------------------------------------------------------------*
*       FORM USER_COMMAND_L             called dynamically            *
*---------------------------------------------------------------------*
*       handle locally defined f-codes                                *
*---------------------------------------------------------------------*
*  -->  P_UCOMM                                                       *
*  -->  P_SELFIELD                                                    *
*---------------------------------------------------------------------*
FORM user_command_l USING p_ucomm TYPE sy-ucomm
                          p_selfield TYPE slis_selfield.

  CASE p_ucomm.


    WHEN 'V-A '.                       " Display<->Change mode
      p_selfield-refresh = g_s.
      PERFORM change_aktyp_l.

    WHEN 'A-V '.                       " Display<->Change mode
      p_selfield-refresh = g_s.
      PERFORM change_aktyp_l.

    WHEN OTHERS.    " codes that require reading items from the list
* Codes are : PLOS QAMV VEAZ QMEL (display or change)
*             PRLS PRZG (print inspection report and certificate)
      PERFORM user_command_f16 USING p_ucomm p_selfield.

  ENDCASE.
ENDFORM.                               "USER_COMMAND_L
*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS_L               called dynamically
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM set_pf_stat_l  USING rt_extab TYPE slis_t_extab.
  IF sy-tcode = 'OQI4'.                " Customizing abklemmen.
    SET PF-STATUS 'CUST' OF PROGRAM 'RQEVAM10' EXCLUDING rt_extab.
    EXIT.
  ELSE.
*--- Tcode aus Parameterübergabe sichern -----------------------------*
    IF g_tcode IS INITIAL.
      IF dy_tcode IS INITIAL.
        g_tcode = sy-tcode.
      ELSE.
        g_tcode = dy_tcode.
      ENDIF.
    ENDIF.
    dy_tcode = g_tcode.

    IF sy-tcode <> 'SE38' AND sy-tcode <> 'SA38'.
      SELECT SINGLE * FROM tstct WHERE sprsl = sy-langu
                                 AND   tcode = t370a-tcode.
    ELSE.
      tstct-ttext = sy-title.
    ENDIF.

    SET TITLEBAR 'LVS' WITH tstct-ttext.

    g_aktyp = t370a-aktyp.

    IF g_aktyp IS INITIAL.
      g_aktyp = 'V'.
    ENDIF.
*   Zeugnis
    CALL FUNCTION 'QAUT_CHECK_TCODE'
         EXPORTING
              I_TCODE          = 'QC21'
         EXCEPTIONS
              NO_AUTHORIZATION = 01.
    IF NOT SY-SUBRC IS INITIAL. APPEND 'PRZG' TO RT_EXTAB.ENDIF.
*   Prüfbericht
    CALL FUNCTION 'QAUT_CHECK_TCODE'
         EXPORTING
              I_TCODE          = 'QGA3'
         EXCEPTIONS
              NO_AUTHORIZATION = 01.
    IF NOT SY-SUBRC IS INITIAL. APPEND 'PRLS' TO RT_EXTAB.ENDIF.

    IF g_aktyp = 'V'.
*   Prüflos
      CALL FUNCTION 'QAUT_CHECK_TCODE'
           EXPORTING
                i_tcode          = 'QA02'
           EXCEPTIONS
                no_authorization = 01.
      IF NOT sy-subrc IS INITIAL. APPEND 'PLOS' TO rt_extab.ENDIF.
*   Verwendungsentscheid
      CALL FUNCTION 'QAUT_CHECK_TCODE'
           EXPORTING
                i_tcode          = 'QA11'
           EXCEPTIONS
                no_authorization = 01.
      IF NOT sy-subrc IS INITIAL.
        CALL FUNCTION 'QAUT_CHECK_TCODE'
             EXPORTING
                  i_tcode          = 'QA12'
             EXCEPTIONS
                  no_authorization = 01.
        IF NOT sy-subrc IS INITIAL. APPEND 'VEAZ' TO rt_extab.ENDIF.
      ENDIF.
*   Ergebnisse
      CALL FUNCTION 'QAUT_CHECK_TCODE'
           EXPORTING
                i_tcode          = 'QE01'
           EXCEPTIONS
                no_authorization = 01.
      IF NOT sy-subrc IS INITIAL.
        CALL FUNCTION 'QAUT_CHECK_TCODE'
             EXPORTING
                  i_tcode          = 'QE11'
             EXCEPTIONS
                  no_authorization = 01.
        IF NOT sy-subrc IS INITIAL.
          CALL FUNCTION 'QAUT_CHECK_TCODE'
               EXPORTING
                    i_tcode          = 'QE14'
               EXCEPTIONS
                    no_authorization = 01.
          IF NOT sy-subrc IS INITIAL.  APPEND 'QAMV' TO rt_extab. ENDIF.
        ENDIF.
      ENDIF.
*   Fehler
      CALL FUNCTION 'QAUT_CHECK_TCODE'
           EXPORTING
                i_tcode          = 'QF01'
           EXCEPTIONS
                no_authorization = 01.
      IF NOT sy-subrc IS INITIAL.
        CALL FUNCTION 'QAUT_CHECK_TCODE'
             EXPORTING
                  i_tcode          = 'QF02'
             EXCEPTIONS
                  no_authorization = 01.
        IF NOT sy-subrc IS INITIAL. APPEND 'QMEL' TO rt_extab.ENDIF.
      ENDIF.
      SET PF-STATUS 'CHANGE' EXCLUDING rt_extab.
    ELSE.
*   Prüflos
      CALL FUNCTION 'QAUT_CHECK_TCODE'
           EXPORTING
                i_tcode          = 'QA03'
           EXCEPTIONS
                no_authorization = 01.
      IF NOT sy-subrc IS INITIAL. APPEND 'PLOS' TO rt_extab.ENDIF.
*   Verwendungsentscheid
      CALL FUNCTION 'QAUT_CHECK_TCODE'
           EXPORTING
                i_tcode          = 'QA13'
           EXCEPTIONS
                no_authorization = 01.
      IF NOT sy-subrc IS INITIAL. APPEND 'VEAZ' TO rt_extab.ENDIF.
*   Ergebnisse
      CALL FUNCTION 'QAUT_CHECK_TCODE'
           EXPORTING
                i_tcode          = 'QE03'
           EXCEPTIONS
                no_authorization = 01.
      IF NOT sy-subrc IS INITIAL. APPEND 'QAMV' TO rt_extab. ENDIF.
*   Fehler
      CALL FUNCTION 'QAUT_CHECK_TCODE'
           EXPORTING
                i_tcode          = 'QF03'
           EXCEPTIONS
                no_authorization = 01.
      IF NOT sy-subrc IS INITIAL. APPEND 'QMEL' TO rt_extab.ENDIF.
      SET PF-STATUS 'MAIN' EXCLUDING rt_extab.
    ENDIF.
  ENDIF.

ENDFORM.                               " SET_PF_STATUS_L

*---------------------------------------------------------------------*
*       FORM CHANGE_AKTYP_l                                       *
*---------------------------------------------------------------------*
*       Aktivitätstyp ändern                                          *
*---------------------------------------------------------------------*
FORM change_aktyp_l.

  DATA:   h_tabarg LIKE t370a-tabarg.
  DATA:   h_programm LIKE t370a-programm.
  DATA:   h_retc LIKE sy-subrc.
  DATA:   h_tcode LIKE t370a-tcode.

*--- Daten aus Kopfzeile Tabelle merken ----------------------------*
  h_tabarg   = t370a-tabarg.
  h_programm = t370a-programm.
  h_tcode    = t370a-tcode.

  CHECK sy-subrc = 0.

  IF g_aktyp = 'A'.
    SELECT        * FROM  t370a
           WHERE  programm    = h_programm
           AND    tabarg      = h_tabarg
           AND    aktyp      <> g_aktyp.
      EXIT.
    ENDSELECT.
  ELSE.
    SELECT        * FROM  t370a
           WHERE  tcode       = sy-tcode
           AND    tabarg      = h_tabarg
           AND    aktyp      <> g_aktyp.
      EXIT.
    ENDSELECT.
    SELECT        * FROM  t370a
           WHERE  programm    = h_programm
           AND    tabarg      = h_tabarg
           AND    aktyp      <> g_aktyp.
      EXIT.
    ENDSELECT.
  ENDIF.
  IF h_tcode CP 'Q*'.
*--- Berechtigungsobject Q_Tcode  ------------------------------*
    AUTHORITY-CHECK OBJECT 'Q_TCODE'
                        ID 'TCD' FIELD t370a-tcode.
      h_retc = sy-subrc.
  ENDIF.
  IF h_retc IS INITIAL.
    IF g_aktyp = 'A'.
      g_aktyp = 'V'.
    ELSE.
      g_aktyp = 'A'.
    ENDIF.

*--- Berechtigung ok ------------------------------------------------*
    SELECT SINGLE * FROM tstct WHERE sprsl = sy-langu
                               AND   tcode = t370a-tcode.
    PERFORM set_pf_stat_l USING gt_extab.
  ELSE.
*--- keine Berecht. -> Kopfzeile muß urspünglichen Eintrag haben ----*
    SELECT SINGLE * FROM t370a WHERE tcode = h_tcode.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM CREATE_FIELDCAT_L                                        *
*---------------------------------------------------------------------*
*       create g_fieldcat_tab for DDIC structure                      *
*---------------------------------------------------------------------*
*  -->  TABNAME  (DDIC-Structure for Report-Output)                   *
*---------------------------------------------------------------------*
FORM create_fieldcat_l  USING tabname TYPE slis_tabname.


  DATA h_fieldcat_wa TYPE slis_fieldcat_alv.
  DATA h_index       LIKE sy-tabix.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            i_program_name         = g_repid
            i_internal_tabname     = 'OBJECT_TAB'
            i_structure_name       = tabname
            i_client_never_display = ' '
       CHANGING
            ct_fieldcat            = g_fieldcat_tab[]
       EXCEPTIONS
            inconsistent_interface = 1
            program_error          = 2
            OTHERS                 = 3.

  IF sy-subrc IS INITIAL.
    SORT g_fieldcat_tab BY key DESCENDING.
    h_index = 1.
    DO.
*--- change key fields to 'normal' fields
      READ TABLE g_fieldcat_tab INTO h_fieldcat_wa INDEX h_index.
      IF sy-subrc IS INITIAL AND h_fieldcat_wa-key = g_x.
        h_fieldcat_wa-key = space.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa INDEX h_index.
        h_index = h_index + 1.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
* add column 'viewed' to field catalog.
    PERFORM add_viewed_column_f14.

    LOOP AT g_fieldcat_tab INTO h_fieldcat_wa.
*--- change field header texts for better understanding
* material fields have same heading, as do the 'SEL*' fields, 'item'
* fields and one or two others.

      IF h_fieldcat_wa-fieldname EQ 'VIEWED'.
        MOVE text-vd1  TO h_fieldcat_wa-seltext_l.
        MOVE text-vd2  TO h_fieldcat_wa-seltext_s.
        h_fieldcat_wa-ddictxt = 'S'.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'EMATNR'.
        MOVE text-fd1  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'MATNRNEU'.
        MOVE text-fd2  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'SELMATNR'.
        MOVE text-fd3  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'CHARGNEU'.
        MOVE text-fd4  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'SELKUNNR'.
        MOVE text-fd5  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'SELHERST'.
        MOVE text-fd6  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'SELLIFNR'.
        MOVE text-fd7  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'SELREVLV'.
        MOVE text-fd9  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'SELPPLVERW'.
        MOVE text-fd8  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'SELWERK'.
        MOVE text-fd0 TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'ZEILE'.
        MOVE text-fe1  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'EBELP'.
        MOVE text-fe2  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
        h_index = h_index + 1.
      ELSEIF h_fieldcat_wa-fieldname EQ 'LS_POSNR'.
        MOVE text-fe3  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'LS_KDAUF'.
        MOVE text-fe4  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.
      ELSEIF h_fieldcat_wa-fieldname EQ 'LS_KDPOS'.
        MOVE text-fe5  TO h_fieldcat_wa-seltext_l.
        MODIFY g_fieldcat_tab FROM h_fieldcat_wa.

      ENDIF.
    ENDLOOP.
  ENDIF.

* The fieldcat is exported to memory here, because this form is called
* in other reports to avoid duplicate text maintenance.
  IF g_repid NE sy-repid.
    EXPORT g_fieldcat_tab TO MEMORY ID 'FIELDCATALOG'.
  ENDIF.
ENDFORM.                               " CREATE_FIELDCAT_L
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_DOC_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM determine_doc_type.

  DATA l_ebeln TYPE qals-ebeln.
  DATA l_ebelp TYPE qals-ebelp.

  GET PARAMETER ID 'BES' FIELD object_tab-ebeln.
  GET PARAMETER ID 'BSP' FIELD object_tab-ebelp.

  MOVE object_tab-ebeln TO l_ebeln.
  MOVE object_tab-ebelp TO l_ebelp.

CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
  EXPORTING
    I_EBELN                    = l_ebeln
    I_EBELP                    = l_ebelp
    I_ENJOY                    = 'X'
    I_DISPLAY_ONLY             = 'X'
  EXCEPTIONS
    NOT_FOUND                  = 1
    NO_AUTHORITY               = 2
    INVALID_CALL               = 3
    PREVIEW_NOT_POSSIBLE       = 4
    OTHERS                     = 5.

IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.
ENDFORM.                               " DETERMINE_DOC_TYPE
*&---------------------------------------------------------------------*
*&      Form  CALL_MIGO_DIALOG
*&---------------------------------------------------------------------*
*       MIGO has to be called via function module
*----------------------------------------------------------------------*
FORM call_migo_dialog.

  DATA l_mblnr TYPE qals-mblnr.
  DATA l_mjahr TYPE qals-mjahr.
  DATA l_zeile TYPE qals-zeile.

  GET PARAMETER ID 'MBN' FIELD object_tab-mblnr.
  GET PARAMETER ID 'MJA' FIELD object_tab-mjahr.
  GET PARAMETER ID 'POS' FIELD object_tab-zeile.

  MOVE object_tab-mblnr TO l_mblnr.
  MOVE object_tab-mjahr TO l_mjahr.
  MOVE object_tab-zeile TO l_zeile.

  CALL FUNCTION 'MIGO_DIALOG'
     EXPORTING
        I_ACTION                  = 'A04'
        I_REFDOC                  = 'R02'
        I_NOTREE                  = 'X'
*       I_NO_AUTH_CHECK           =
*       I_SKIP_FIRST_SCREEN       = 'X'
        I_DEADEND                 = 'X'
*       I_OKCODE                  = 'OK_GO'
*       I_LEAVE_AFTER_POST        =
*       I_NEW_ROLLAREA            = 'X'
*       I_SYTCODE                 =
*       I_EBELN                   =
*       I_EBELP                   =
        I_MBLNR                   = l_mblnr
        I_MJAHR                   = l_mjahr
        I_ZEILE                   = l_zeile
     EXCEPTIONS
       ILLEGAL_COMBINATION       = 1
       OTHERS                    = 2
          .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                               " CALL_MIGO_DIALOG
*&---------------------------------------------------------------------*
*&      Form  DELIVERY_DISPLAY
*&---------------------------------------------------------------------*
*       Delivery has to be called via function module (VL03N or VL33N)
*----------------------------------------------------------------------*
FORM DELIVERY_DISPLAY.

* Local declarations
  DATA l_vbeln TYPE likp-vbeln.

  GET PARAMETER ID 'VL' FIELD object_tab-ls_vbeln.
  MOVE object_tab-ls_vbeln TO l_vbeln.

* Display delivery
  CALL FUNCTION 'RV_CALL_DISPLAY_TRANSACTION'
    EXPORTING
      VBELN          = l_vbeln.

ENDFORM.                               " DELIVERY_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  TASKLIST_DISPLAY
*&---------------------------------------------------------------------*
*       Task list to be called from QA32, QA33, ...
*----------------------------------------------------------------------*
FORM TASKLIST_DISPLAY.

* Local declarations
  DATA: l_qals TYPE qals.

  GET PARAMETER ID 'QLS' FIELD object_tab-prueflos.

* In order to show exactly the plan assigned to the lot, don't rely
* e.g. on fields MATNR, WERK and also fetch the correct date:
  SELECT SINGLE prueflos plnty plnnr
                plnal selmatnr selwerk gueltigab
         FROM qals INTO CORRESPONDING FIELDS OF l_qals
         WHERE prueflos EQ object_tab-prueflos.
  CHECK sy-subrc IS INITIAL.
* Display task list, dependent on type
  CALL FUNCTION 'QSS1_PLAN_SHOW'
       EXPORTING
            I_MATNR   = l_QALS-SELMATNR
            I_PLANAL  = l_QALS-PLNAL
            I_PLANNR  = l_QALS-PLNNR
            I_PLANTYP = l_QALS-PLNTY
            I_STTAG   = l_QALS-GUELTIGAB
            I_WERK    = l_QALS-SELWERK
       EXCEPTIONS
            OTHERS    = 0.

ENDFORM.                               " TASKLIST_DISPLAY
*--------------------------------------------------------------------*
* And finally, the INCLUDES....                                      *
*--------------------------------------------------------------------*
INCLUDE rqalvf14.        " Central include for ALV functions
INCLUDE rqalvf16.        " Central include for OBJECT_TAB functions
INCLUDE rq00mf10.        " Include for controlling the entry screen
* THAT'S ALL FOLKS !!!!!
*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE_L                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form top_of_page_l.

*--- Display header lines above list display -------------------------
  if not g_listheader_tab[] is initial.
    call function 'REUSE_ALV_COMMENTARY_WRITE'
         EXPORTING
              it_list_commentary = g_listheader_tab.
  endif.

endform.