* P31G.INS5 (P30K119998/3.1G) Parameter in Funktionsbaustein hinzufügen
* P30K047201/3.0D: Überprüfung, ob AbgrPer. > Abschlußper. der Version
*                  (für jede selektierte Version separat)
* P30K047201/3.0D: Msg-Handler auf object-abhängig umgestellt
* P30K049339/3.0D: Parallelverarbeitung bei Sammelverarbeitung
* P30K049339*/3.0D: Fehler durch INVALID_CURSOR beseitigt -> Hinw. 37009
* P30K064525/3.0D: WIP-Liste komfortabler
* P30K071169/3.0D: bei fehlauft auch perform datenzeile -> Flag setzen
* P30K074456/3.0E: Parameter i_default_status nicht mehr im List-FB
* P30E_AV (P30K075924/3.0E): Arbeitsvorrat (ActionLog) einbauen
* P30E_AUFK (P30K075924/3.0E): T_AUFK nicht mehr def., da keine Verw.
* P30E_PAR  (P30K081591/3.0E): Parallelisierung
* P30E_PERF (P30K081591/3.0E): Performance
* 30F_obj (P30K090659/3.0F): object-dependent auch für Msg. aus FBs
* 30F_47657 (P30K090659/3.0F): Aufträge ohne AbgrSchl nicht mitnehmen
* 30F_STOR (P30K090659/3.0F): Stornofunktion
* 30F_LÖVM (P30K090659/3.0F): Aufträge mit LÖVM aussparen
* 30F_LIST (P30K090659/3.0F): Im Batch weitere Felder in Liste
* 30F_BRK  (P30K090659/3.0F): Breakpoints in KKAG
* 30F_BUCH (P30K090659/3.0F): set update task local
* P30F.INST, P30F.MODT: ToDo-Liste 3.0F, DDIC-Referenz
* 30F_37009 (P30K112452/3.0F): Ergänzung im Hinweis 37009 rein (INS*)
* 31H_SEL (P30K134584/3.1H): Sel.parameter Von-Periode mitgeben
***********************************************************************
* 40A_0WIP (ALRK008526): keine 0-WIP-Aufträge in Liste auf Anforderung
* 40A: Schalter Auftragsinformation aufgenommen (40A_info)
* 40A: Umschalten auf Bukrs-Währung (CompanyCodeCurrency) (40A_CCC)
* 40C: Umschalten auf Bukrs-Währung auch in Anz.TA (40C_CCC) Hw. 91516
*     Anm.: In 4.0B noch geringfügig anders realisiert  (40B_CCC)
* 40B: Extra-Rechnen der 2. Währung (Calculate 2nd Curr.) (40B_C2C)
* 40B: Korrekte Mitgabe der ab 4.0 neuen Parameter in Arbeitsvorrat
* 40C: Kuppelproduktion, mehrere Positionen pro Auftrag (40C1)
* 40C: Ampel setzen und Prot. lesen aus auftrag_abgr raus: Auch für Exc
* 40C: Pkosa neu zu 4.0C (40C_PK)
* 40C: Zum Speichern der Einstellungen auf ALV-Reuse-FB umgestellt
***********************************************************************
* 46A_SCMA: Anbindung SchedMan
*

*EPORT SAPKKA07 MESSAGE-ID KJ LINE-SIZE 90.                 "H846158
REPORT SAPKKA07 MESSAGE-ID KJ LINE-SIZE 134.                "H846158

TABLES: AUFK, AFPO, TKKAP, TKKAT, KKALKKAG.                   "P30F.MODT
*        vkkp0_or.  " View mit AUFK, AFPO, AFKO
TABLES: TKA01.                                              "P30K049339

TABLES: KKAPARA_IN.                    "P30E_PAR

* Beginning I_46A_SCMA
INCLUDE RKASSEFW.

DATA: GT_SELPA LIKE COSEL2 OCCURS 0 WITH HEADER LINE.

PARAMETERS: WL_ACTIV TYPE KKA_YES_NO NO-DISPLAY. "worklists used?
PARAMETERS: SCMA TYPE KKA_YES_NO NO-DISPLAY,     "Schedule Manager used?
            KASS TYPE KKA_YES_NO NO-DISPLAY,     "kass used?
            SELART TYPE KASS_SELART NO-DISPLAY,  "kass parameters
            VARIANT LIKE RSVAR-VARIANT NO-DISPLAY,
            ONE TYPE C NO-DISPLAY.
SELECT-OPTIONS: SELPA FOR GT_SELPA-LOW NO-DISPLAY.

PARAMETERS: ORG_REP LIKE SY-REPID NO-DISPLAY,
* Zeile nach unten verschoben                            "46C
            PRI_PARA LIKE PRI_PARAMS NO-DISPLAY,
            ARC_PARA LIKE ARC_PARAMS NO-DISPLAY.

* End I_46A_SCMA

SELECT-OPTIONS: ABGRAUFA FOR AUFK-AUART.                         "I_40A
SELECT-OPTIONS: ABGRWERK FOR AUFK-WERKS.  " (memory id wrk) gel.

PARAMETERS: INCFAUFT AS CHECKBOX,
            INCPKOSA AS CHECKBOX,
            INCPIAUF AS CHECKBOX.



ENHANCEMENT-POINT SAPKKA07_22 SPOTS ES_SAPKKA07 STATIC.
*PARAMETERS ABGRKOKR LIKE AUFK-KOKRS NO-DISPLAY.
                                       "in KASS als KOKRS enthalten

SELECT-OPTIONS ABGRAUFN FOR AUFK-AUFNR MATCHCODE OBJECT ORDE.
                                       " (memory id anr)  gelöscht

PARAMETERS: ABGRMONA LIKE KKA0100-BIS_ABGR_M MEMORY ID ACM OBLIGATORY,
            ABGRJAHR LIKE KKA0100-BIS_ABGR_J MEMORY ID ACJ OBLIGATORY.

PARAMETERS: VON_PER  LIKE KKBC-PERIO1 DEFAULT '001',           "31H_SEL
            VON_JAHR LIKE KKBC-GJAHR1 DEFAULT '1900',          "31H_SEL
            BIS_PER  LIKE KKBC-PERIO2, "31H_SEL
            BIS_JAHR LIKE KKBC-GJAHR2. "31H_SEL

SELECT-OPTIONS: ABGRVERS FOR TKKAP-VERSA. "(mem id acv) gel. "P30E_PERF
*                abgrschl for aufk-abgsl.                    "P30E_PERF

SELECTION-SCREEN SKIP.

PARAMETERS OBJ_LST TYPE ERGEBNIS_LISTE.   "display object list?    "46C
PARAMETERS: FEHLAUFT AS CHECKBOX,
            STOREMSG AS CHECKBOX,
            WITHIMSG AS CHECKBOX.
PARAMETERS: P_CCCURR AS CHECKBOX MEMORY ID KK2.              "I_40A_CCC
*arameters: p_2_curr as checkbox.                            "D_40B_C2C
PARAMETERS: P_2_CURR LIKE KKA0100-2CURR.                     "I_40C_C2C

*parameters: bu_spalt as checkbox. "im Listtool immer einblendbar "P30E

*parameters: p_ampel as checkbox. "gibt Ampeln in Liste aus  "P30K049339
PARAMETERS: P_MAXNTA type KKA_MAXANZ. "ermittelt MNT pro Auftr.
"P30K064525

PARAMETERS: NO_0_WIP AS CHECKBOX.      "I_40A_0WIP
*parameters: p_a_info as checkbox.                           "I_40A_info
PARAMETERS: P_A_VARI LIKE DISVARIANT-VARIANT.               "I_40C_Vari
*     gd_afpo.                                         "I_40A_info"D40C
DATA: GD_LINES TYPE P,  "# Zeilen einer Tabelle ermitteln       "I_40A1
      GD_1VERS TYPE C,                 "I_40A1
      GD_NR_OPVERS LIKE SY-DBCNT, "Anzahl operativer Versionen   "I_40C
      GD_RST   TYPE C,   "Auch Rst. vorhanden                    "I_40C
      GD_1AUFA TYPE C,                 "I_40A1
      GD_1WERK TYPE C.                 "I_40A1

PARAMETERS: P_RFCGRP  LIKE RZLLITAB-CLASSNAME.                "P30E_PAR
PARAMETERS: PARDEBUG  AS CHECKBOX.     "P30E_PAR
PARAMETERS: PARSINGL  AS CHECKBOX.     "P30E_PAR
PARAMETERS: PAR_EINZ LIKE KKALKKAG-EINZEL_VERARB NO-DISPLAY.      "I45A
DATA:       PARALLEL.                  "P30E_PAR

PARAMETERS: P_ALOG AS CHECKBOX.   "Arbeitsvorrat (Actionlog)   "P30E_AV

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK VERARB WITH FRAME TITLE TEXT-FR1.
PARAMETERS: AUSFUEHR RADIOBUTTON GROUP ABGR,
            SIMULATI RADIOBUTTON GROUP ABGR,
            ANZEIGEN RADIOBUTTON GROUP ABGR.
PARAMETERS: PAR_STOR AS CHECKBOX.      "30F_STOR
SELECTION-SCREEN END OF BLOCK VERARB.

PARAMETERS: PAR_BRK AS CHECKBOX. "im Online für Breakpoints    "30F_BRK
PARAMETERS: PAR_NPAR AS CHECKBOX. "kein autom. Rechn par.Bew. "40A_NPAR

*begin of note 679133                                           "H679133
DATA: KKA07_MEMORY_ID_SOURCE_ID(30) VALUE 'SAPKKA07-BG-SAPMKKAC_SC_ID',
      current_source_id(7),
      source_id(7),
      s_id_sapmkkac(7)   value 'KKAC   ',
      s_id_sapkka07(7)   value 'KKA07  ',
      s_id_sapmkk07bg(7) value 'KKA07BG'.
*end of note 679133                                             "H679133

RANGES ABGRAUTY FOR AUFK-AUTYP.

* Global fields used for the authority check for plant and val.type
DATA: g_auth_plant_missing type c,                        "HW550211
      g_auth_valu_missing type c.                         "HW550211


INCLUDE LKKAGF89.                      "Abgrenzungskategorien
INCLUDE LKKAGF88.                      "Auftragstypen

INITIALIZATION.

* Beginning I_46A_SCMA
  DATA:
    GD_NOT_RELEVANT TYPE I,
    GD_SAVE_EXTRACT TYPE KKA_YES_NO,
    GRUNDLISTE_DATA TYPE OBJ_LOG_DATA,
    SEL_PARAMS TYPE TABLE OF KABA00,
    OBJ_LST_EXTR TYPE SCHEDMAN_EXT,
    BASE_LST_EXTR TYPE SCHEDMAN_EXT.
* End I_46A_SCMA

  DATA GD_ABORT_ERROR TYPE KKA_YES_NO.                             "46B
* Error indicating that no order can be processed                  "46B

  DATA  LEDGER_00 LIKE COSB-LEDNR VALUE '00'.
  data  space_refva like tkkap-refva value '   '.               "H355147

  DATA: ABGR_APLID LIKE TCMF6-APLID VALUE 'KKA',
*     abgr_object_id like tcmf5-object_id value 'CX1',"-> ID f.WIP"D40C
       ABGR_OBJECT_ID LIKE TCMF5-OBJECT_ID VALUE 'KKA',            "I40C
     abgr_abort_msgty value ' ',                            "D40C  "M46B
*       ABGR_ABORT_MSGTY VALUE 'A',     "I40C                      "D46B
        ABGR_MSG_STORE_NR LIKE CMFP-NR.

  DATA: MESSAGE_TYPE LIKE CMIMSG-MSGTY," Art der Message für MsgHandler
      MESSAGE_NR LIKE CMIMSG-MSGNR,   " Nummer der Message f. MsgHandler
        MESSAGE_V1 LIKE AUFK-AUFNR.    " AUFK/SAFK-Nr an MsgHandler

  DATA: YES VALUE 'X',
        NO VALUE ' '.

  DATA: MSG_NR TYPE I,
       MAX_MSG TYPE C,                                      "P30K049339
       GD_MSGTYPTEXT(30) TYPE C,       "I_40C
        A_MSG_NR TYPE I,
        E_MSG_NR TYPE I,
        W_MSG_NR TYPE I,
        I_MSG_NR TYPE I.

  DATA  R_MESSAGE VALUE 'I'.   "für F.-Baustein KKA_ABGR_VORBEREITEN

DATA: TRANSAKTIONS_GRUPPE_G VALUE 'G'.    "Sammelverarbeitung  "H1041813

 DATA  WAEHRUNG_MANUELL VALUE 'B'. "für F.-Baustein KKA_ABGR_VORBEREITEN

 DATA: GD_NO_POSWIP, "set this flag for old WIP-logic joint prod."I_40C1
       GD_MLT_POS.   "set to 'X' if any has more than one pos.   "I_40C1
  DATA: GD_PI_TEXT(80), "Text für SAPGUI_PROGRESS_IND...          "I_40C
        GD_PI_TOTAL  TYPE I,           "I_40C
        GD_PI_PROZ TYPE I,             "I_40C
        GD_PI_OLDPROZ TYPE I,          "I_40C
        GD_PI_DIFF TYPE I.             "I_40C
  DATA: GD_PEP_ACTIVITY LIKE PFLOG-ACTIVITY,         "PEP         "I_40C
        GD_PEP_TEST LIKE PFLOG-TEST,   "PEP         "I_40C
        GD_PEP_TCODE LIKE SY-TCODE,    "PEP         "I_40C
        GD_PEP_REPID LIKE SY-REPID,    "PEP         "I_40C
        GD_PEP_GJVAR LIKE TKA01-LMONA, "PEP         "I_40C
        GD_PEP_BUDAT LIKE SY-DATUM,    "PEP         "I_40C
        GS_PEP_ORG       LIKE PFFLD_ORG,             "PEP         "I_40C
        GS_PEP_HIERARCHY LIKE PFFLD_HIERARCHY,       "PEP         "I_40C
        GD_PEP_ID        LIKE PFLOG-TIMESTMP,        "PEP         "I_40C
        GD_PEP_APLSTAT   LIKE PFFLD-APLSTAT,         "PEP         "I_40C
        GS_PEP_MSGP LIKE PFMSG,        "PEP         "I_40C
        GS_PEP_ALOG LIKE PFACT,        "PEP         "I_40C
        GS_PEP_AUFTRAG   LIKE KKAPARA_TA,                         "I_40C
        GS_PEP_VERSION   LIKE KKAPARA_VS,                         "I_40C
        GT_PEP_SEL       LIKE PFSEL OCCURS 0 WITH HEADER LINE,    "I_40C
        GT_PEP_PAR       LIKE PFPAR OCCURS 0 WITH HEADER LINE.    "I_40C

* Int. Tabelle aller zu bearbeitenden Aufträge
  DATA T_AUFTRAG LIKE KKAPARA_TA OCCURS 0 WITH HEADER LINE. "40A
* Beginn P30K049339
* Int. Tabelle zur Sammlung der in Liste ausgeg. Datenzeilen
*  Beginn P30E_PAR -> T_AUFTLST als DDIC-Struktur wg. Übergabe per RFC
  DATA T_AUFTLST LIKE KKAPARA_TA OCCURS 0 WITH HEADER LINE.
*  Ende   P30E_PAR

*data: gd_auft_wipk  like kka2000-wrt,                            "D40C
*      gd_auft_wipp  like kka2000-wrt,                            "D40C
*      gd_auft_wipb  like kka2000-wrt.                            "D40C

  DATA: GD_FEHLERAUFTRAG(1) TYPE C.    "zeigt fehlerhaften Auftrag an

  DATA: GD_CVACT LIKE TKA01-CVACT.  "ob par. Bew. aktiv geschaltet ist
  DATA: GD_REF_VERS_EXIST.          "ob ref. Vers. zur oper. existieren
*ata: gd_ta_waehr like kkah2000-twaer. "Währung, in der WIP angezeigt
  DATA: GD_KRKWAEHR LIKE KKAH2000-TWAER."KRK-Währung          "I_40C_CCC
*ata: gd_ampel like kka0100-ampel. "entscheidet Ampel-Farbe d. akt. Auf.
*ata: gd_maxnt like kka0100-msgmx. "zur Ermittl. d. max. NT d. akt. Auf.
  DATA: CON_BST LIKE KKAPARA_TA-WIPTYP,"Text danach          "I40C
        CON_RST LIKE KKAPARA_TA-WIPTYP."Text danach          "I40C
  CON_BST = TEXT-BST.                  "I40C
  CON_RST = TEXT-RST.                  "I40C
  CONSTANTS: CON_ROT(1) TYPE C VALUE '1'. "rote Ampel
  CONSTANTS: CON_GELB(1) TYPE C VALUE '2'. "gelbe Ampel
  CONSTANTS: CON_GRUEN(1) TYPE C VALUE '3'. "gruene Ampel
  DATA: CON_STR_ROT(8) TYPE C.         "rote Ampel
  CON_STR_ROT = TEXT-ROT.
  DATA: CON_STR_GELB(8) TYPE C.        "gelbe Ampel
  CON_STR_ROT = TEXT-GLB.
  DATA: CON_STR_GRUEN(8) TYPE C.       "gruene Ampel
  CON_STR_ROT = TEXT-GRN.
  DATA: BEGIN OF GS_NEWTOTAL,          " zählt Meldungen
                  A  TYPE I,
                  E  TYPE I,
                  W  TYPE I,
                  I  TYPE I,
        END OF   GS_NEWTOTAL.
  DATA: GS_OLDTOTAL  LIKE GS_NEWTOTAL. " Anzahl aller Meldungen (bisher)
  DATA: GD_NUM_MSGS_OLD TYPE I,        "I_46A_SCMA
        GD_NUM_MSGS_NEW TYPE I.        "I_46A_SCMA

*type-pools: kkblo.  "Type-Pool des Listtools
  TYPE-POOLS: SLIS.    "Type-Pool des Listtools der ReUse-Lib.

*data: gs_layout type kkblo_layout.    "Struktur für List-FB
  DATA: GS_LAYOUT TYPE SLIS_LAYOUT_ALV."Struktur für List-FB
*data: gt_field type kkblo_t_fieldcat. "Interne Tabelle für Feldkatalog
  DATA: GT_FIELD TYPE SLIS_T_FIELDCAT_ALV.  "Int. Tabelle für Feldkat.
*data: gt_sort type kkblo_t_sortinfo.  "Zw.summen und Sort. (i.Tab.)
  DATA: GT_SORT TYPE SLIS_T_SORTINFO_ALV."Zw.summen und Sort. (i.Tab.)
  DATA: GT_EVENTS TYPE SLIS_T_EVENT.   "Event-Tabelle für ALV-Reuse
DATA: GS_VARIANT LIKE DISVARIANT. "Struktur f. AnzVariante des ALV-Reuse
*data: gs_hide type kkblo_sel_hide.    "Verbergen v. Felder aus Sel-Info
DATA: GS_HIDE TYPE SLIS_SEL_HIDE_ALV. "Verbergen von Felder aus Sel-Info
  DATA: GS_EXITCAUSE TYPE SLIS_EXIT_BY_USER. "Exit-Grund aus K_KKB-FB
  DATA: GD_REPID LIKE SY-REPID.        "Name dieses Reports
* Ende   P30K049339
 DATA: GT_SPAR LIKE SPAR OCCURS 10 WITH HEADER LINE,            "P30E_AV
       GD_SUBOBJEKT LIKE BALHDRI-SUBOBJECT VALUE 'KK_WIP',      "P30E_AV
       GD_EXTNUMBER LIKE BALHDRI-EXTNUMBER VALUE 'AUFNR',       "P30E_AV
       GD_LAUFBEZ(12),    "begrenzt Länge des Bezeichners       "P30E_AV
       GD_EXITPROG LIKE BALMI-USEREXITP VALUE 'SAPMKKAC',       "P30E_AV
       GD_EXITFORM LIKE BALMI-USEREXITF VALUE 'APPL_LOG_AUFNR', "P30E_AV
         GD_TCODE LIKE SY-TCODE.       "P30E_AV
* Beginn DELETE P30E_AUFK
*data  begin of t_aufk occurs 100. " globale Tabelle für 100 AUFK-Sätze
*        include structure aufk.
*data  end of   t_aufk.
* Ende   DELETE P30E_AUFK
  DATA  BEGIN OF T_AFPO OCCURS 100. " globale Tabelle für 100 AFPO-Sätze
          INCLUDE STRUCTURE AFPO.
  DATA  END OF   T_AFPO.

  DATA BEGIN OF HELP_FIELDS OCCURS 1.
          INCLUDE STRUCTURE HELP_VALUE.
  DATA END OF HELP_FIELDS.

  DATA: BEGIN OF HELP_VALUES OCCURS 1,
          VALUE LIKE TKKAT-TEXTA,
        END OF HELP_VALUES.

  DATA: ABGR_OBJ_TOTAL TYPE I,
        LD_A_OBJ_TOTAL(11) TYPE C,
        LD_A_OBJ_NOT_DONE(11) TYPE C,
        ABGR_OBJ_NOT_DONE TYPE I.
*     abgr_obj_shown type i. "Anzahl Objekte auf einer Seite"P30K064525

  DATA:  " Zur Fallunterscheidung in der Form-Routine DATENZEILE
        DATEN_FALL VALUE 'D',      " WIP-Daten ausgeben     (CONSTANT)
        FEHLER_FALL   VALUE 'E'.   " Fehler-Zeile ausgeben  (CONSTANT)

  DATA: CON_TCODE_EZ_E LIKE SY-TCODE VALUE 'KKAX',
        CON_TCODE_SA_E LIKE SY-TCODE VALUE 'KKAO',
        CON_TCODE_EZ_A LIKE SY-TCODE VALUE 'KKAY',
        CON_TCODE_SA_A LIKE SY-TCODE VALUE 'KKAQ',
        CON_TCODE_PK_E LIKE SY-TCODE VALUE 'KKAP',
        CON_TCODE_PK_A LIKE SY-TCODE VALUE 'KKAR',
        CON_TCODE_SE_E LIKE SY-TCODE VALUE 'KKAS',
        CON_TCODE_SE_A LIKE SY-TCODE VALUE 'KKAT'.

  DATA BEGIN OF TKKAABGR OCCURS 1.
          INCLUDE STRUCTURE KKAABGR.
  DATA END OF TKKAABGR.

* Struktur-Definitionen hier nach hinten verschoben, da Verw. tkkaabgr
  DATA: BEGIN OF ABGR_PERIOD,
          J(4),
          M(3),
        END OF ABGR_PERIOD.
*  Beginn P30K047201
 DATA: ABS_PERIOD LIKE ABGR_PERIOD,  "Abschlußper. als String zum Vergl.
          BEGIN OF STR_ABGR_PER,       "Abgr.per. als Ausgabe-String
            M(3),
            1(1) VALUE '.',
            J(4),
          END OF   STR_ABGR_PER,
          BEGIN OF STR_ABS_PER,        "Abschlußper. als Ausgabe-String
            M(3),
            1(1) VALUE '.',
            J(4),
          END OF   STR_ABS_PER.
*  Ende   P30K047201

* ABGR_VSN wg. RFC-Übergabe in Parall. als DDIC-Struktur def. "P30E_PAR
 DATA ABGR_VSN LIKE KKAPARA_VS OCCURS 10 WITH HEADER LINE.     "P30E_PAR
 DATA LT_TKKAP LIKE TKKAP OCCURS 0 WITH HEADER LINE. "zw.speichern TKKAP
  RANGES SEL_TKKAP FOR TKKAP-VERSA.    "selekt. AbgrVers für 2. Select

*DATA  SSCRFIELDS-UCOMM(4).   "Okcode-Feld des List-Dynpros
  DATA  MEMORY_OKCODE(4).              " Übergabe über Memory-ID
  DATA  CON_KEY_ID(7) VALUE 'KKA_OKC'. " Memory-ID
  DATA: AKTION.
  DATA: CATTNEU, CATTAKTIV.            "I45B_CATT

* BADI WIP at Actual Costs (ML)
  DATA: badi_act_instance TYPE REF TO if_ex_ckml_wip,
        badi_act_active   TYPE c.
* Product cost collector used in APO processing
  DATA: lf_isapo_pcc      TYPE kka_yes_no.

  INCLUDE KKA07F05.                    "I_46A_SCMA

*include kka07t01. " Datendef. Parall. (ins Incl. f01 verl.)  "P30E_PAR
 INCLUDE KKA07F01.   " Unterprogramme Parallelisierung       "P30K049339

*eject
************************************************************************
*
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR ABGRVERS-LOW.
  REFRESH HELP_FIELDS.
  HELP_FIELDS-TABNAME = 'TKKAP'.
  HELP_FIELDS-FIELDNAME = 'KOKRS'.
  HELP_FIELDS-SELECTFLAG = ' '.
  APPEND HELP_FIELDS.
  HELP_FIELDS-TABNAME = 'TKKAP'.
  HELP_FIELDS-FIELDNAME = 'VERSA'.
  HELP_FIELDS-SELECTFLAG = 'X'.
  APPEND HELP_FIELDS.
  HELP_FIELDS-TABNAME = 'TKKAT'.
  HELP_FIELDS-FIELDNAME = 'TEXTA'.
  HELP_FIELDS-SELECTFLAG = ' '.
  APPEND HELP_FIELDS.

  REFRESH HELP_VALUES.
  SELECT * FROM TKKAP WHERE KOKRS EQ KOKRS.
    HELP_VALUES-VALUE = TKKAP-KOKRS.
    APPEND HELP_VALUES.
    HELP_VALUES-VALUE = TKKAP-VERSA.
    APPEND HELP_VALUES.
    SELECT SINGLE * FROM TKKAT WHERE KOKRS EQ TKKAP-KOKRS
                                 AND VERSA EQ TKKAP-VERSA
                                 AND SPRAS EQ SY-LANGU.
    IF SY-SUBRC EQ 0.
      HELP_VALUES-VALUE = TKKAT-TEXTA.
    ELSE.
      HELP_VALUES-VALUE = SPACE.
    ENDIF.
    APPEND HELP_VALUES.
  ENDSELECT.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
       EXPORTING
            FIELDNAME    = 'VERSA'
            TABNAME      = 'TKKAP'
       IMPORTING
            SELECT_VALUE = ABGRVERS-LOW
       TABLES
            FIELDS       = HELP_FIELDS
            VALUETAB     = HELP_VALUES.

*eject
************************************************************************
*
************************************************************************
INITIALIZATION.
  PERFORM KASS_FW_INIT
    USING
      'KABG'
      KASS_FW_DEFAULT_INIT_OPTIONS.
  PERFORM KASS_FW_EVENT_REGISTER
    USING
      KASS_FW_EVENT-START_OF_SELECTION
      'START_OF_SELECTION'
      KASS_FW_PRIORITY-MAIN
      KASS_FW_DEFAULT_REG_OPTIONS.


*  IF SY-BATCH IS INITIAL.
*    CALL FUNCTION 'K_KOKRS_SET'
*            EXPORTING DISPLAY   = ' '
*                     i_kokrs   = ' '
*                      POPUP     = ' '
*            IMPORTING E_KOKRS   = kokrs.
*            EXCEPTIONS NOT_FOUND = 01.
*  ENDIF.

*eject
************************************************************************
*
************************************************************************
FORM START_OF_SELECTION.

*begin of note 679133                                           "H679133
   import source_id from memory id KKA07_MEMORY_ID_SOURCE_ID.
   if sy-subrc eq 0.
     current_source_id = source_id.
   else.
     current_source_id = s_id_sapkka07.
   endif.
*end of note 679133                                             "H679133

  DATA: lt_extab TYPE slis_t_extab.

  PERFORM BERECHTIGUNG_PRUEFEN USING '03' 'KABG'.
*  perform berechtigung_pruefen using '03' 'KABM'.               "D_40C
  IF AUSFUEHR EQ YES.
    PERFORM BERECHTIGUNG_PRUEFEN USING '02' 'KABG'.
  ELSEIF SIMULATI EQ YES.
    PERFORM BERECHTIGUNG_PRUEFEN USING '48' 'KABG'.
  ENDIF.

* Beginning of I_46A_SCMA
  IF PAR_EINZ = YES.
* Bei Einzelverarbeitung bestimmte Meldungen als Fehler ausgegeben.
    R_MESSAGE = 'E'.
  ENDIF.

* SchedMan angeschlossen, alten PEP entfernt:
  GD_SCMA_WORKLISTS_ACTIVE = WL_ACTIV.
  IF KASS = YES.
    LOOP AT SELPA.
      MOVE-CORRESPONDING SELPA TO GT_SELPA.
      APPEND GT_SELPA.
    ENDLOOP.

    CALL FUNCTION 'K_OBJECT_SELECTION_CRIT_FILL'
      EXPORTING
        SELART                  = SELART
        ONEOBJECT               = ONE
        VARIANT                 = VARIANT
*   IMPORTING
*     SELART_TXT              =
      TABLES
        IT_COSEL2               = GT_SELPA
*   EXCEPTIONS
*     NOT_SUPPORTED           = 1
*     WRONG_SELCTION_CRITERIA = 2
*     OTHERS                  = 3
            .
  ENDIF.
  IF SCMA = YES.
    PERFORM INIT_RECORD_FOR_SCMA.
* Seiteneffekt: globale Variablen werden gesetzt.
    STOREMSG = GD_SAVE_EXTRACT.
  ENDIF.

* 4.0B: Im Anzeige-Modus immer auf Fehler in DB aufmerksam machen(Ampel)
  IF ANZEIGEN EQ YES.
    FEHLAUFT = 'X'.
  ENDIF.

*  Beginn 30F_BRK
  IF NOT PAR_BRK IS INITIAL AND SY-BATCH IS INITIAL.
    CALL FUNCTION 'KKA_ABGR_PAUSEPOINTS_SETZEN'.
  ENDIF.
*  Ende   30F_BRK

*  Beginn P30E_PAR
  IF P_RFCGRP IS INITIAL.
*  Nur bei eingetragener Server-Gruppe wird parallel verarbeitet
    CLEAR PARALLEL.
  ELSE.
    PARALLEL = 'X'.
  ENDIF.
*  Ende   P30E_PAR

*  Beginn 31H_SEL
  IF BIS_PER IS INITIAL.
    BIS_PER = ABGRMONA.
  ENDIF.
  IF BIS_JAHR IS INITIAL.
    BIS_JAHR = ABGRJAHR.
  ENDIF.
*  Ende   31H_SEL
* D40C: Immer Afpo lesen!
** AFPO enthält SAFNR, SAFNR für Pkosas nötig außer bei Anz. "I_40A_info
** oder AFPO nötig für Auftragsinfos wenn Schalter dazu an   "I_40A_info
*  if ( not incpkosa is initial and "bei Pkosas SAFNR nötig  "I_40A_info
*      anzeigen ne yes )            "für Anzeige nur AUFK    "I_40A_info
*   or not p_a_info is initial.    "Schalter Auftragsinfo an "I_40A_info
*     gd_afpo = 'X'.                                         "I_40A_info
*  else.                                                     "I_40A_info
*     clear gd_afpo.                                         "I_40A_info
*  endif.                                                    "I_40A_info

  IF NOT ANZEIGEN IS INITIAL AND NOT PAR_STOR IS INITIAL.
    MESSAGE I802(KJ).
*     Anzeige-Funktion ermittelt gebuchte Daten. Keine Stornierung
    CLEAR PAR_STOR.
  ENDIF.

* BADI WIP at Actual Costs (ML)
  CALL FUNCTION 'CKMLWIP_BADI_GET_INSTANCE'
    IMPORTING
      e_badi_instance = badi_act_instance.
  CALL METHOD badi_act_instance->check_active
    IMPORTING
      e_active = badi_act_active.

* Status setzen
  IF SY-BATCH IS INITIAL.
    WRITE TEXT-PI3    TO GD_PI_TEXT.   "I_40C
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'                    "I_40C
         EXPORTING                     "I_40C
              TEXT       = GD_PI_TEXT. "I_40C
    IF badi_act_active IS INITIAL.
      APPEND 'ZMLWIPDOC' TO lt_extab.
    ENDIF.
    IF ANZEIGEN IS INITIAL.
      SET TITLEBAR 'ERM'.
      SET PF-STATUS 'OBJEKTLISTE' EXCLUDING lt_extab.
      IF NOT PAR_STOR IS INITIAL.
        SET TITLEBAR 'STO'.
      ENDIF.
    ELSE.
      SET TITLEBAR 'ANZ'.
      SET PF-STATUS 'WIP_ANZ' EXCLUDING lt_extab.
    ENDIF.
  ENDIF.

  PERFORM MESSAGE_INITIALIZE.
* Setze Meldungszähler für Ampelfarbenbestimmung zurück
  CLEAR: GS_OLDTOTAL, GS_NEWTOTAL.
*  Füge nun für jeden gültigen Auftragstyp Eintrag in abgrauty ein
*   zunächst: Fehler, wenn kein Auftragstyp gewählt
*             nur, wenn Aufruf direkt als Report (sonst schon auf Dynp)

* Bei Selektion über KASS werden die folgenden Selektionsparameter
* nicht übergeben:
  IF KASS = NO.                        "I_46A_SCMA
    IF INCFAUFT IS INITIAL AND
       INCPIAUF IS INITIAL AND
       INCPKOSA IS INITIAL.
      MESSAGE E080(KV).
*      Bitte mindestens einen Auftragstyp auswählen
    ENDIF.
  ENDIF.                               "I_46A_SCMA

* BEGIN OF TESTING!!!!!!!!!        "4.0D aktivieren
* data: ktrhiera like ckph-kstrg, ld_sytcode like sy-tcode,
*       procnr   like aufk-procnr.   "keine Param-ID für ProcNr
* ld_sytcode = sy-tcode.
* get parameter id 'KTR' field ktrhiera.
* END   OF TESTING!!!!!!!!!
  REFRESH ABGRAUTY.
  CLEAR ABGRAUTY.
  ABGRAUTY-SIGN = 'I'.
  ABGRAUTY-OPTION = 'EQ'.
  ABGRAUTY-HIGH = SPACE.
  IF NOT INCFAUFT IS INITIAL.
    ABGRAUTY-LOW = AUFTRAGSTYP-EINZ.   "CO-(Einzel-)FertAuft zusätzlich
    APPEND ABGRAUTY.
    ABGRAUTY-LOW = AUFTRAGSTYP-FERT.   "PPS-FertAuft zusätzlich
    APPEND ABGRAUTY.
  ENDIF.
  IF NOT INCPIAUF IS INITIAL.
    ABGRAUTY-LOW = AUFTRAGSTYP-BATC.   "Prozeßaufträge zusätzlich
    APPEND ABGRAUTY.
  ENDIF.
  IF NOT INCPKOSA IS INITIAL.
    ABGRAUTY-LOW = AUFTRAGSTYP-PROD.   "Produkt.KoSammler zusätzlich
    APPEND ABGRAUTY.
  ENDIF.
  REFRESH: T_AFPO, ABGR_VSN.           "P30E_AUFK

  ABGR_PERIOD-J = ABGRJAHR.                                 "P30K047201
  ABGR_PERIOD-M = ABGRMONA.                                 "P30K047201
  IF PAR_NPAR IS INITIAL OR AUSFUEHR EQ YES.
*   automatisches Rechnen paralleler Bewertungen im Anschluß an oper.
*   (im Echtlauf immer, sonst verhinderbar mittels OKCODE NPAR)
    SELECT * FROM TKKAP INTO TABLE LT_TKKAP bypassing buffer    "H355147
                   WHERE KOKRS EQ KOKRS
                     AND VERSA IN ABGRVERS
                     and ( refva eq space_refva or              "H355147
                           refva is null ).                     "H355147
    IF SY-DBCNT = 0 AND ANZEIGEN EQ NO.
*     keine Versionen, wegen Ausblenden von ref. Vers.
*     (Im Anzeigenmodus kein Prot.)
      CALL FUNCTION 'CM_F_MESSAGE'
           EXPORTING
                ARBGB            = 'KJ'
                MSGNR            = '295'
                MSGTY            = 'A'                   "M_46B
                MSGV1            = SPACE
                MSGV2            = SPACE
                MSGV3            = SPACE
                MSGV4            = SPACE
                MSG_ON_SCREEN    = NO
                OBJECT_DEPENDENT = NO
                APPEND_SAME_MSG  = NO.
    ENDIF.
    GD_NR_OPVERS = SY-DBCNT.  "Anzahl operativer Versionen ermittelt
*   Ranges-Tab vorbereiten zum Lesen der abh. par. Bewertungen
    CLEAR SEL_TKKAP.
    SEL_TKKAP-OPTION = 'EQ'.
    SEL_TKKAP-SIGN   = 'I'.
  ELSE.
*   alle angegebenen Versionen ohne Beachtung der Reihenfolge
    SELECT * FROM TKKAP INTO TABLE LT_TKKAP bypassing buffer    "H355147
                   WHERE KOKRS EQ KOKRS
                     AND VERSA IN ABGRVERS.
  ENDIF.
  LOOP AT LT_TKKAP.
*   Vergleich auf Abschlußperiode kleiner gewählter AbgrPeriode
*    Anm.: Nur für oper. AbgrVersionen, nicht für RefVersionen
    ABS_PERIOD-J = LT_TKKAP-ABSPE+3(4).
    ABS_PERIOD-M = LT_TKKAP-ABSPE(3).
*   nur für ermitteln und simulieren; für anzeigen alle AbgrVersionen
    DATA: ABGR_PERIOD_NUM TYPE I,      "I_46A_SCMA
          ABS_PERIOD_NUM TYPE I.       "I_46A_SCMA
    ABGR_PERIOD_NUM = ABGR_PERIOD.     "I_46A_SCMA
    ABS_PERIOD_NUM = ABS_PERIOD.       "I_46A_SCMA
*   IF ( ABGR_PERIOD <= ABS_PERIOD ) AND ( ANZEIGEN EQ NO ). "D_46A_SCMA
    IF ( ABGR_PERIOD_NUM <= ABS_PERIOD_NUM )                 "I_46A_SCMA
                                     AND ( ANZEIGEN EQ NO ). "I_46A_SCMA
*     Fehler --> Ausgabestrings bauen
      MOVE-CORRESPONDING ABGR_PERIOD TO STR_ABGR_PER.
      MOVE-CORRESPONDING ABS_PERIOD TO STR_ABS_PER.
*     Im Anzeigenmodus kein Prot., da für Anzeigen hier nicht rein
      CLEAR GS_PEP_AUFTRAG.
      MOVE-CORRESPONDING LT_TKKAP TO GS_PEP_VERSION.
      PERFORM CM_F_SET_OBJECT USING GS_PEP_AUFTRAG               "I_40C
                                    GS_PEP_VERSION.              "I_40C
      CALL FUNCTION 'CM_F_MESSAGE'
           EXPORTING
                ARBGB            = 'KJ'
                MSGNR            = '277'
                MSGTY            = 'A'                           "M_46B
                MSGV1            = STR_ABGR_PER
                MSGV2            = STR_ABS_PER
                MSGV3            = LT_TKKAP-VERSA
                MSGV4            = SPACE
                MSG_ON_SCREEN    = NO
                OBJECT_DEPENDENT = YES "M_40C
                APPEND_SAME_MSG  = NO.
    ELSE.
*     nur bei erlaubter Sperrperiode Abgrenzungsversion mitnehmen
*     Beginning insertion note 190816
      DATA:
        ld_msgty LIKE sy-msgty.
      IF anzeigen IS INITIAL.
        IF simulati = 'X'.
          ld_msgty = 'W'.
        ELSE. "ausfuehr = 'X'
          ld_msgty = 'E'.
        ENDIF.
        CALL FUNCTION 'KKA_CHECK_PERIOD_LOCK_INIT'.
        CALL FUNCTION 'KKA_CHECK_PERIOD_LOCK'
          EXPORTING
            i_fiscal_year                = abgrjahr
            i_co_area                    = kokrs
            i_period                     = abgrmona
            i_version                    = lt_tkkap-versa
            i_business_transaction       = 'KABG'
            i_check_dependent_versions   = yes
          EXCEPTIONS
            PERIOD_LOCKED                = 1
            MAX_CHECKS_REACHED           = 0
            OTHERS                       = 3.
        IF sy-subrc <> 0.
          IF ld_msgty = 'E'.
            gd_abort_error = yes.
          ENDIF.
          IF par_einz = no.
*           In case of single processing, results analysis will write
*           the message(s) into the log.
            CLEAR GS_PEP_AUFTRAG.
            MOVE-CORRESPONDING LT_TKKAP TO: GS_PEP_VERSION.
*           Display version in error log:
            PERFORM CM_F_SET_OBJECT
              USING GS_PEP_AUFTRAG GS_PEP_VERSION.
            MESSAGE_NR = SY-MSGNO.
            CALL FUNCTION 'CM_F_MESSAGE'
                 EXPORTING
                      ARBGB            = sy-msgid
                      MSGNR            = message_nr
                      MSGTY            = ld_msgty
                      MSGV1            = SY-MSGV1
                      MSGV2            = SY-MSGV2
                      MSGV3            = SY-MSGV3
                      MSGV4            = SY-MSGV4
                      MSG_ON_SCREEN    = NO
                      OBJECT_DEPENDENT = YES
                      APPEND_SAME_MSG  = NO.
          ENDIF.
          IF ld_msgty = 'E' AND scma IS INITIAL.
*           Only abort if SCMA is not active
            MESSAGE ID SY-MSGID TYPE ld_msgty NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
        ENDIF.
      ENDIF.
      CHECK gd_abort_error = no.
*     End note 190816
      MOVE LT_TKKAP-VERSA   TO ABGR_VSN-VERSA.
      MOVE LT_TKKAP-VALUTYP TO ABGR_VSN-VALUTYP.
      APPEND ABGR_VSN.
      MOVE LT_TKKAP-VERSA TO SEL_TKKAP-LOW.
      APPEND SEL_TKKAP.
    ENDIF.
  ENDLOOP.
* Beginning 4.6B
    select single cvact lmona into (gd_cvact, gd_pep_gjvar)
           from tka01
           where kokrs = kokrs.
    if anzeigen = no and par_einz = no.
* Prüfen, daß alle Warenbewegungen im aktuellen Kostenrechnungskreis
* bewertet sind.

* Letzten Tag der WIP-Ermittlungs-Periode holen:
    call function 'G_POSTING_DATE_OF_PERIOD_GET'
      exporting
        period              = abgrmona
        variant             = gd_pep_gjvar
        year                = abgrjahr
      importing
*       FROM_DATE           =
*       LAST_NORMAL_PERIOD  =
        to_date             = gd_pep_budat
*       FROM_DATE_ORIG      =
      exceptions
        others              = 1.
    if sy-subrc <> 0.
      MESSAGE_NR = SY-MSGNO.
      CALL FUNCTION 'CM_F_MESSAGE'
        EXPORTING
            ARBGB            = SY-MSGID
            MSGNR            = MESSAGE_NR
            MSGTY            = 'A'
            MSGV1            = SY-MSGV1
            MSGV2            = SY-MSGV2
            MSGV3            = SY-MSGV3
            MSGV4            = SY-MSGV4
            MSG_ON_SCREEN    = NO
            OBJECT_DEPENDENT = NO
            APPEND_SAME_MSG  = YES.
      gd_abort_error = yes.
    else.
      CALL FUNCTION 'MB_ALL_MOVEMENTS_VALUATED'
         EXPORTING
              I_BUDAT                   = gd_pep_budat
*              I_BUKRS                   =
              I_KOKRS                   = kokrs
*              I_WERKS                   =
*              I_OBJNR                   =
*              I_BYPASSING_BUFFER        =
*        IMPORTING
*             E_STATUS                  =
         EXCEPTIONS
              EXCEPTION_INTERNAL_ERROR  = 1
              NON_VALUATED_RECORD_FOUND = 2
              OTHERS                    = 3.
      if sy-subrc <> 0.
        MESSAGE_NR = SY-MSGNO.
        CALL FUNCTION 'CM_F_MESSAGE'
          EXPORTING
            ARBGB            = SY-MSGID
            MSGNR            = MESSAGE_NR
            MSGTY            = SY-MSGTY                        "M207675
            MSGV1            = SY-MSGV1
            MSGV2            = SY-MSGV2
            MSGV3            = SY-MSGV3
            MSGV4            = SY-MSGV4
            MSG_ON_SCREEN    = NO
            OBJECT_DEPENDENT = NO
            APPEND_SAME_MSG  = YES.
        gd_abort_error = yes.
      endif.
    endif.
  endif.
  if abgr_vsn[] is initial.
* Keine Versionen gefunden
    gd_abort_error = yes.
  endif.
* End 4.6B

  IF PAR_NPAR IS INITIAL OR AUSFUEHR EQ YES.
*   jetzt die zugehörigen parallelen Bewertungen dazunehmen
*    Anm.: Keine Überprüfung der Sperrperiode, da Kopier-Logik
*          und immer Rechnen der RefVersionen, wenn zugeh. gerechnet!

* Here some lines deleted in 4.6B

    IF GD_CVACT EQ 'X'.
*     parallele Bewertungen sind aktiv
      SELECT * FROM TKKAP bypassing buffer                      "H355147
             APPENDING CORRESPONDING FIELDS OF TABLE ABGR_VSN
             WHERE REFVA IN SEL_TKKAP
               AND KOKRS EQ KOKRS.
      IF SY-DBCNT > 0 AND ANZEIGEN EQ NO AND WITHIMSG EQ YES.
*       Meldung, daß zusätzliche abh. Versionen gerechnet
*       (Im Anzeigenmodus kein Prot.)
        GD_REF_VERS_EXIST = 'X'.
        CALL FUNCTION 'CM_F_MESSAGE'
             EXPORTING
                  ARBGB            = 'KJ'
                  MSGNR            = '296'
                  MSGTY            = 'I'
                  MSGV1            = SPACE
                  MSGV2            = SPACE
                  MSGV3            = SPACE
                  MSGV4            = SPACE
                  MSG_ON_SCREEN    = NO
                  OBJECT_DEPENDENT = NO
                  APPEND_SAME_MSG  = NO.
      ENDIF.
      FIELD-SYMBOLS: <FS_VSNLINE> LIKE LINE OF ABGR_VSN.
      LOOP AT ABGR_VSN ASSIGNING <FS_VSNLINE>.
        PERFORM GET_VALUTEXT USING <FS_VSNLINE>-VALUTYP
                                   <FS_VSNLINE>-VALUTEXT.
      ENDLOOP.
    ENDIF.                             "gd_cvact eq 'X'
  ENDIF.
  ABGR_OBJ_TOTAL = 0.
  ABGR_OBJ_NOT_DONE = 0.
* jetzt Währung für Anzeige-TA für mögl. Vergl. mit Bukrs-W. "*_40C_CCC
  CLEAR GD_KRKWAEHR.                   "M_40C_CCC

ENHANCEMENT-POINT SAPKKA07_23 SPOTS ES_SAPKKA07.
  IF ANZEIGEN EQ YES.
    SELECT SINGLE  WAERS  INTO GD_KRKWAEHR                   "M_40C_CCC
     FROM  TKA01
           WHERE  KOKRS  =  KOKRS.
  ENDIF.

* Beginning insertion note 433163:
  DATA:
    ld_select_for_all_entr,
    num_of_orders TYPE i.
  DESCRIBE TABLE abgraufn[] LINES num_of_orders.
  IF num_of_orders > 10.
*   Check whether ABGRAUFN only contains list of order numbers,
*   i.e. whether SAPKKA07 is called by KKAV or KKAW. In background
*   processing SY-TCODE can not be used.
    LOOP AT abgraufn WHERE
      sign <> 'I' OR
      option <> 'EQ'.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0. "only list of orders, no complex select options
      ld_select_for_all_entr = yes.
    ENDIF.
  ENDIF.
* End insertion note 433163

* Beginning I_46A_SCMA:
* Für KASS neue Selektion
  IF KASS = YES.
* Arbeitsvorrat verwendet immer KASS
    IF GD_SCMA_WORKLISTS_ACTIVE = YES.
      "Nachrichtenzähler setzen (wird für Rückmeldung gebraucht):
      CALL FUNCTION 'CM_F_INFO'
           EXPORTING
                ALL             = 'X'
                APLID           = ABGR_APLID
                OBJECT          = ABGR_OBJECT_ID
           IMPORTING
                MSG_COUNTER_PRO = GD_NUM_MSGS_NEW
           EXCEPTIONS
                WRONG_OBJECT_ID = 0
                OTHERS          = 0.

      GD_NUM_MSGS_OLD = GD_NUM_MSGS_NEW.
    ENDIF.
    GD_NOT_RELEVANT = 0.
    PERFORM SELECT_OBJECTS_KASS.
*  ELSE.                                                          "46B
* End I_46A_SCMA
  elseif gd_abort_error = no.                                     "46B
* AFPO immer lesen! (nötig für Kuppelprod.Pos.)
* if not gd_afpo is initial.                                      "D40C
*    Bei Verarb. mit AFPO neue Logik: über Outer Join       "I_40A_info
* Beginning insertion note 433163:
    IF ld_select_for_all_entr = yes.
ENHANCEMENT-SECTION     SAPKKA07_25 SPOTS ES_SAPKKA07.
      SELECT AUFK~MANDT AUFK~AUFNR AUFK~OBJNR AUFK~AUTYP
             AUFK~WERKS AUFK~AUART AUFK~KTEXT
             AUFK~FLG_MLTPS AUFK~BUKRS AUFK~ZSCHL AUFK~PROCNR
             AUFK~PRCTR
             AUFK~ABGSL                                         "H722130
             MAKT~MAKTX
             AFPO~POSNR AFPO~OBJNP AFPO~MATNR AFPO~PWERK
             AFPO~WEMNG AFPO~PSMNG AFPO~AMEIN
        INTO CORRESPONDING FIELDS OF TABLE T_AUFTRAG
        FROM ( AUFK INNER JOIN AFPO ON AUFK~AUFNR = AFPO~AUFNR )
             LEFT OUTER JOIN MAKT ON AFPO~MATNR = MAKT~MATNR AND
                                     MAKT~SPRAS = SY-LANGU
        FOR ALL ENTRIES IN ABGRAUFN WHERE
             AUFK~AUFNR = ABGRAUFN-LOW
             AND AUFK~AUTYP IN ABGRAUTY
             AND AUFK~WERKS IN ABGRWERK
             AND AUFK~AUART IN ABGRAUFA
             AND AUFK~KOKRS EQ KOKRS
             AND AUFK~LOEKZ EQ SPACE
             AND AUFK~PKOSA EQ SPACE
             AND AUFK~ABGSL NE SPACE.
END-ENHANCEMENT-SECTION.
    ELSE.
* End insertion note 433163
ENHANCEMENT-SECTION     SAPKKA07_24 SPOTS ES_SAPKKA07.
    SELECT AUFK~MANDT AUFK~AUFNR AUFK~OBJNR AUFK~AUTYP
           AUFK~WERKS AUFK~AUART AUFK~KTEXT
           AUFK~FLG_MLTPS AUFK~BUKRS AUFK~ZSCHL AUFK~PROCNR     "I_40C1
           AUFK~PRCTR
           AUFK~ABGSL                                           "H722130
           MAKT~MAKTX       "I_46A
           AFPO~POSNR AFPO~OBJNP       "I_40C1
           AFPO~MATNR AFPO~PWERK
           AFPO~WEMNG AFPO~PSMNG AFPO~AMEIN
           INTO CORRESPONDING FIELDS OF TABLE T_AUFTRAG
           FROM ( AUFK INNER JOIN AFPO
                  ON AUFK~AUFNR = AFPO~AUFNR
                )                      "I_40C1
*                 and afpo~posnr = '0001' )                     "D_40C1
                LEFT OUTER JOIN MAKT ON"I_46A
                   AFPO~MATNR = MAKT~MATNR AND                  "I_46A
                   MAKT~SPRAS = SY-LANGU                        "I_46A
          WHERE AUFK~AUTYP IN ABGRAUTY
             AND AUFK~WERKS IN ABGRWERK
             AND AUFK~AUART IN ABGRAUFA
             AND AUFK~AUFNR IN ABGRAUFN
             AND AUFK~KOKRS EQ KOKRS
             AND AUFK~LOEKZ EQ SPACE

             AND AUFK~PKOSA EQ SPACE   "I40C_PK
             AND AUFK~ABGSL NE SPACE.
END-ENHANCEMENT-SECTION.
    ENDIF.                                                      "433163
*  else.                                                          "D40C
**   Sonst nur Lesen aus AUFK nötig                               "D40C
*    select mandt aufnr objnr autyp werks auart ktext             "D40C
*       into corresponding fields of table t_auftrag              "D40C
*       from aufk                                                 "D40C
*       where autyp in abgrauty                                   "D40C
*         and werks in abgrwerk                                   "D40C
*         and auart in abgraufa                                   "D40C
*         and aufnr in abgraufn                                   "D40C
*         and kokrs eq kokrs                                   "D40C
*         and loekz eq space                                      "D40C
*         and pkosa eq space                                      "D40C
*         and abgsl ne space.                                     "D40C
*  endif.                                                         "D40C
* BEGIN 40C
    IF SY-DBCNT EQ 0.
*   Falls keine Objekte gefunden, gleiche Selektion ohne ABGSL
*   Es folgt obiges SELECT-Statement dupliziert ohne ABGSL-Einschränkung
      CLEAR GS_PEP_VERSION.            "Selektion unabhängig von Version
* Beginning insertion note 433163:
      IF ld_select_for_all_entr = yes.
        SELECT * INTO CORRESPONDING FIELDS OF GS_PEP_AUFTRAG
          FROM AUFK
          FOR ALL ENTRIES IN ABGRAUFN WHERE
            AUFNR = ABGRAUFN-LOW
            AND AUTYP IN ABGRAUTY
            AND WERKS IN ABGRWERK
            AND AUART IN ABGRAUFA
            AND KOKRS EQ KOKRS
            AND LOEKZ EQ SPACE
            AND PKOSA EQ SPACE.
          PERFORM CM_F_SET_OBJECT
             USING GS_PEP_AUFTRAG
                   GS_PEP_VERSION.
          CALL FUNCTION 'CM_F_MESSAGE'
               EXPORTING
                    ARBGB            = 'KJ'
                    MSGNR            = '462'
                    MSGTY            = 'I'
                    MSGV1            = GS_PEP_AUFTRAG-AUFNR
                    MSGV2            = SPACE
                    MSGV3            = SPACE
                    MSGV4            = SPACE
                    MSG_ON_SCREEN    = NO
                    OBJECT_DEPENDENT = YES
                    APPEND_SAME_MSG  = NO.
        ENDSELECT.
      ELSE.
* End insertion note 433163
      SELECT * INTO CORRESPONDING FIELDS OF GS_PEP_AUFTRAG
         FROM AUFK
         WHERE AUTYP IN ABGRAUTY
           AND WERKS IN ABGRWERK
           AND AUART IN ABGRAUFA
           AND AUFNR IN ABGRAUFN
           AND KOKRS EQ KOKRS
           AND LOEKZ EQ SPACE
           AND PKOSA EQ SPACE.
        PERFORM CM_F_SET_OBJECT
           USING GS_PEP_AUFTRAG
                 GS_PEP_VERSION.
        CALL FUNCTION 'CM_F_MESSAGE'
             EXPORTING
                  ARBGB            = 'KJ'
                  MSGNR            = '462'
                  MSGTY            = 'I'
                  MSGV1            = GS_PEP_AUFTRAG-AUFNR
                  MSGV2            = SPACE
                  MSGV3            = SPACE
                  MSGV4            = SPACE
                  MSG_ON_SCREEN    = NO
                  OBJECT_DEPENDENT = YES
                  APPEND_SAME_MSG  = NO.
      ENDSELECT.
      ENDIF.                                                    "433163
      IF SY-DBCNT GT 0.
        CALL FUNCTION 'CM_F_MESSAGE'
            EXPORTING ARBGB          = 'KJ'
               MSGNR                 = '811'
*             MSGTY                 = 'E'        "46A
               MSGTY                 = 'W'                  "46A
               MSGV1                 = SPACE
               MSGV2                 = SPACE
               MSGV3                 = SPACE
               MSGV4                 = SPACE
               MSG_ON_SCREEN         = NO
               OBJECT_DEPENDENT      = NO
               APPEND_SAME_MSG       = NO.
        CLEAR T_AUFTRAG[].                                      "488468
* Beginning 46A
      ELSE.
      IF GD_SCMA_WORKLISTS_ACTIVE = NO.                         "303770
        CALL FUNCTION 'CM_F_MESSAGE'
             EXPORTING
                  ARBGB            = 'KJ'
                  MSGNR            = '816'
                  MSGTY            = 'W'
                  MSGV1            = SPACE
                  MSGV2            = SPACE
                  MSGV3            = SPACE
                  MSGV4            = SPACE
                  MSG_ON_SCREEN    = NO
                  OBJECT_DEPENDENT = NO
                  APPEND_SAME_MSG  = NO.
      ENDIF.                                                    "303770
* End 46A
      ENDIF.
* END   40C
    ELSEIF SY-BATCH IS INITIAL.        "I_40C
      GD_PI_TOTAL = SY-DBCNT.          "I_40C
      CLEAR GD_PI_TEXT.                "I_40C
     WRITE GD_PI_TOTAL TO GD_PI_TEXT(8).                          "I_40C
      WRITE TEXT-PI1    TO GD_PI_TEXT+8."I_40C
     CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'                    "I_40C
            EXPORTING                  "I_40C
                 TEXT       = GD_PI_TEXT."I_40C
    ENDIF.                             "I_40C

  ENDIF.                               "I_46A_SCMA

  if gd_abort_error = no.                                          "46B
  SORT T_AUFTRAG BY WERKS MATNR AUFNR POSNR.                    "I_40C1
  IF GD_NO_POSWIP EQ 'X'.              "I_40C1
*   zum Test alle Aufträge mit alter Logik bearbeiten:          "I_40C1
*   d.h.: trotz MLTPS-Flag WIP auf Pos. 0 rechnen               "I_40C1
    FIELD-SYMBOLS: <FS_T> LIKE LINE OF T_AUFTRAG.               "I_40C1
    LOOP AT T_AUFTRAG ASSIGNING <FS_T> WHERE FLG_MLTPS EQ 'X'.  "I_40C1
      CLEAR <FS_T>-FLG_MLTPS.          "I_40C1
    ENDLOOP.                           "I_40C1
  ENDIF.                               "I_40C1
* Füllen der Übergabestruktur KKAPARA_IN
  KKAPARA_IN-RFC_GROUP = P_RFCGRP. "P_RFCGRP gefüllt durch K_BATCH_..
  KKAPARA_IN-ABGRMONA  = ABGRMONA.
  KKAPARA_IN-ABGRJAHR  = ABGRJAHR.
  KKAPARA_IN-WAEHR     = GD_KRKWAEHR.
  KKAPARA_IN-FEHLAUFT  = FEHLAUFT.
  KKAPARA_IN-P_CCCURR  = P_CCCURR.     "I_40A_CCC
  KKAPARA_IN-P_C2CURR  = P_2_CURR.     "I_40B_C2C
  KKAPARA_IN-P_MAXNTA  = P_MAXNTA.
  KKAPARA_IN-NO_0_WIP  = NO_0_WIP.     "I_40A_0WIP
* Anmerkung: Flag p_a_info erst nach Ermittlung für Anzeige benötigt.
  KKAPARA_IN-WITHIMSG  = WITHIMSG.
  KKAPARA_IN-P_ALOG    = P_ALOG.
  KKAPARA_IN-AUSFUEHR  = AUSFUEHR.
  KKAPARA_IN-SIMULATI  = SIMULATI.
  KKAPARA_IN-ANZEIGEN  = ANZEIGEN.
  KKAPARA_IN-SCMA_WORKLISTS_ACTIVE = GD_SCMA_WORKLISTS_ACTIVE.
                                       "I_46A_SCMA
  KKAPARA_IN-PAR_EINZ  = PAR_EINZ.     "46B
ENHANCEMENT-POINT SAPKKA07_01 SPOTS ES_SAPKKA07.
  IF NOT PARALLEL IS INITIAL.
* Zu Parallelverarbeitung verzweigen
    PERFORM WIP_ERMITTELN_PARALLEL
                      TABLES T_AUFTRAG
                             ABGR_VSN
                      USING  KKAPARA_IN.
*   Erg. des Par.laufs werden danach in wip_para_results zurückgestellt
  ELSE.
    CLEAR GD_PI_OLDPROZ.               "I_40C
    LOOP AT T_AUFTRAG.
      IF SY-BATCH IS INITIAL.          "I_40C
*       Errechne Abarbeitungs-Prozentsatz                        "I_40C
        GD_PI_PROZ = ( ABGR_OBJ_TOTAL * 100 ) DIV GD_PI_TOTAL.   "I_40C
        GD_PI_DIFF = GD_PI_PROZ - GD_PI_OLDPROZ.                 "I_40C
        IF GD_PI_DIFF >= 10.           "I_40C
*         Nur alle 10 Prozent neu ausgeben                       "I_40C
          WRITE ABGR_OBJ_TOTAL TO GD_PI_TEXT(8).                 "I_40C
          WRITE TEXT-PI2       TO GD_PI_TEXT+8.                  "I_40C
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'              "I_40C
             EXPORTING                 "I_40C
                  PERCENTAGE = GD_PI_PROZ                        "I_40C
                  TEXT       = GD_PI_TEXT.                       "I_40C
          GD_PI_OLDPROZ = GD_PI_PROZ.  "I_40C
        ENDIF.                         "I_40C
      ENDIF.                           "I_40C
*     Verarbeitung für Parallellauf und Serielllauf in einer FORM
      PERFORM AUFTRAG_LOOP
             TABLES ABGR_VSN
                    T_AUFTLST
             USING  T_AUFTRAG
                    KKAPARA_IN
                    GD_NOT_RELEVANT                                "46B
                    ABGR_OBJ_TOTAL
                    ABGR_OBJ_NOT_DONE
                    GD_FEHLERAUFTRAG.
      IF P_ALOG EQ 'X' AND GD_FEHLERAUFTRAG EQ 'X'.
        CALL FUNCTION 'CO_APPL_LOG_APPEND_AUFNR'
             EXPORTING
                  AUFNR = T_AUFTRAG-AUFNR.
      ENDIF.                           "p_alog...
      CLEAR GD_FEHLERAUFTRAG.          "clearen für nächsten Auft.
    ENDLOOP.                           " loopt über Aufträge
  ENDIF.                               "parallel...

  endif.                                                           "46B

*  IF AUSFUEHR EQ YES OR SIMULATI EQ YES.           "P30K049339 "488468
*  Für Anzeigen keine Nachrichten                           "P30K049339
    IF ABGR_OBJ_NOT_DONE NE 0.
      MESSAGE_TYPE = 'W'.
    ELSE.
      MESSAGE_TYPE = 'I'.
    ENDIF.
    LD_A_OBJ_TOTAL = ABGR_OBJ_TOTAL.
    LD_A_OBJ_NOT_DONE = ABGR_OBJ_NOT_DONE.
    CONDENSE: LD_A_OBJ_TOTAL, LD_A_OBJ_NOT_DONE.
    IF ( MESSAGE_TYPE NE 'I' ) OR NOT ( WITHIMSG IS INITIAL ).
*    Als I-Meldung nur dann ins Fehlerprot., wenn Checkbox gesetzt.
* Meldung wegen neuer Grundliste zu 4.6A nicht mehr nötig
*    CALL FUNCTION 'CM_F_MESSAGE'
*       EXPORTING ARBGB                 = 'KJ'
*                 MSGNR                 = '500'
*                 MSGTY                 = MESSAGE_TYPE
*                 MSGV1                 = LD_A_OBJ_TOTAL
*                 MSGV2                 = LD_A_OBJ_NOT_DONE
*                 MSGV3                 = SPACE
*                 MSGV4                 = SPACE
*                 MSG_ON_SCREEN         = NO
*                 OBJECT_DEPENDENT      = NO
*                 APPEND_SAME_MSG       = YES.
    ENDIF.

    MESSAGE S500 WITH LD_A_OBJ_TOTAL LD_A_OBJ_NOT_DONE.

*   Check authorizations for plants and valuation type        "HW550211
*    perform AUTH_CHECK_PLANT_VALUTYP.                        "HW550211

    clear g_auth_plant_missing.                               "HW550211
    clear g_auth_valu_missing.                                "HW550211

    perform AUTH_CHECK_PLANT_VALUTYP using
                                      g_auth_plant_missing    "HW550211
                                      g_auth_valu_missing.    "HW550211


    PERFORM MESSAGE_INFO.
    IF STOREMSG EQ YES.
      PERFORM MESSAGE_STORE.
    ELSEIF SY-BATCH EQ YES.
      IMPORT CATTAKTIV FROM MEMORY ID 'CATT'.                 "I45B_CATT
      IMPORT CATTNEU FROM MEMORY ID 'CATTNEU'.                "I45B_CATT
      IF CATTNEU NE 'X' AND CATTAKTIV NE 'X'.                 "I45B_CATT
        PERFORM MESSAGE_PRINT.
* Beginning I_46A_SCMA
        IF sy-subrc = 0.                                         "453849
        SET TITLEBAR 'PRO'.
        GD_SCMA_SPOOL-SPOOLTXT = SY-TITLE.
        GD_SCMA_SPOOL-SPOOLID = SY-SPONO.
        APPEND GD_SCMA_SPOOL TO GT_SCMA_SPOOL.
        ENDIF.                                                   "453849
* End I_46A_SCMA
      ENDIF.                           "I45B_CATT
    ELSE.
*    (perform message_analysis) -> nur über FUNKTION aus Liste heraus
    ENDIF.
*  ENDIF. "ne anzeigen.                              "P30K049339 "488468
* Ausgabe der Liste über List-FB
  DESCRIBE TABLE ABGR_VSN LINES GD_LINES. "ermittle Anzahl Vers   "40A1
  IF GD_LINES GT 1.                    "40A1
    CLEAR GD_1VERS.                    "40A1
  ELSE.                                "40A1
    GD_1VERS = 'X'.                    "40A1
  ENDIF.                               "40A1
  DESCRIBE TABLE ABGRWERK LINES GD_LINES. "ermittle Anzahl Werke  "40A1
  READ TABLE ABGRWERK INDEX 1. "lese 1. Eintrag, zum check ob 'EQ'"40A1
  IF GD_LINES GT 1 OR ABGRWERK-OPTION NE 'EQ'.                    "40A1
    CLEAR GD_1WERK.                    "40A1
  ELSE.                                "40A1
    GD_1WERK = 'X'.                    "40A1
  ENDIF.                               "40A1
* Die Auftragsart-Einschränkung wäre nur für Direktaufruf relevant!!!
  DESCRIBE TABLE ABGRAUFA LINES GD_LINES. "ermittle Anzahl Auarten"40A1
  READ TABLE ABGRAUFA INDEX 1. "lese 1. Eintrag, zum check ob 'EQ'"40A1
  IF GD_LINES GT 1 OR ABGRAUFA-OPTION NE 'EQ'.                    "40A1
    CLEAR GD_1AUFA.                    "40A1
  ELSE.                                "40A1
    GD_1AUFA = 'X'.                    "40A1
  ENDIF.                               "40A1

* Beginning I_46A_SCMA:
  IF GD_SCMA_WORKLISTS_ACTIVE = YES.
* read object independent messages:
    DATA MSG_TAB LIKE CMFMSG OCCURS 0.

    CALL FUNCTION 'CM_F_MESSAGES_GET'
      EXPORTING
        APLID                  = ABGR_APLID
*         OBJECT                 = ' '
*         WITH_OBJECTINDEPENDENT = 'X'
      TABLES
        E_MSGPROT              = MSG_TAB
      EXCEPTIONS
          NOT_ACTIVE             = 0
          OTHERS                 = 0
        .

    DELETE MSG_TAB WHERE OBJKZ = 'X'.
                                       "objektabh. Meldungen löschen

    CALL FUNCTION 'KPEP_WLA_ADD_MESSAGES'
         TABLES
              CMFE_MESSAGES = MSG_TAB.
    COMMIT WORK.
  ENDIF.

  DATA ABGR_OBJ_DONE TYPE I.
  ABGR_OBJ_DONE = ABGR_OBJ_TOTAL - ABGR_OBJ_NOT_DONE.

  IF KASS = NO.
    PERFORM GET_SEL_TAB
      TABLES
        SEL_PARAMS.
  ENDIF.
  PERFORM GET_PARAM_TAB
    TABLES
      SEL_PARAMS.

  PERFORM CREATE_GRUNDLISTE
    TABLES
      SEL_PARAMS
    USING
      ANZEIGEN                                          "378155
      SIMULATI
      KASS
      ABGR_OBJ_DONE
      ABGR_OBJ_NOT_DONE
      GD_NOT_RELEVANT.

  IF GD_SAVE_EXTRACT = YES.
    PERFORM SAVE_BASE_LIST
      CHANGING
        BASE_LST_EXTR.
  ENDIF.

* End I_46A_SCMA

* Überprüfe, ob auch Rückstell. vorhanden, die dann in separater Summe
  READ TABLE T_AUFTLST WITH KEY WIPTYP = CON_RST.
  IF SY-SUBRC EQ 0 OR SY-SUBRC EQ 2.   "Subrc 2 wohl irrelevant
    GD_RST = 'X'.
  ELSE.
    CLEAR GD_RST.
  ENDIF.
  PERFORM DEFINIERE_LISTE
    TABLES GT_FIELD
           GT_SORT
    USING  GS_LAYOUT
           GS_HIDE
           GD_1WERK
           GD_1AUFA
           GD_1VERS
           GD_RST
           ANZEIGEN
*           p_a_info                                              "D40C
           P_MAXNTA.
  PERFORM DEFINIERE_EVENTS
    TABLES GT_EVENTS.
* ALV aufrufen
  GD_REPID = SY-REPID.
  CLEAR GS_VARIANT.                    "I40C_Vari
  GS_VARIANT-REPORT = GD_REPID.        "I40C_Vari
  GS_VARIANT-VARIANT = P_A_VARI.       "I40C_Vari
*  call function 'K_KKB_LIST_DISPLAY'

* beginning I_46A_SCMA
  IF NOT T_AUFTLST[] IS INITIAL AND    "46B
     GD_SAVE_EXTRACT = YES.
    PERFORM SAVE_OBJECT_LIST
      CHANGING
        OBJ_LST_EXTR.
  ENDIF.

* Hintergrunddruck vor SCMA close wg. Spool-IDs:
  DATA EMPTY_EXTRACT TYPE DISEXTRACT.
  IF SY-BATCH = YES.
    IF sy-binpt IS INITIAL.                                     "396282
      PERFORM DISPLAY_GRUNDLISTE.
      SET TITLEBAR 'GRU'.
      GD_SCMA_SPOOL-SPOOLTXT = SY-TITLE.
      GD_SCMA_SPOOL-SPOOLID = SY-SPONO.
      APPEND GD_SCMA_SPOOL TO GT_SCMA_SPOOL.
    ENDIF.                                                      "396282

*    IF NOT T_AUFTLST[] IS INITIAL AND OBJ_LST = YES.           "396282
    IF ( NOT t_auftlst[] IS INITIAL OR sy-binpt = 'X' ) AND     "396282
       obj_lst = yes.                                           "396282
      PERFORM DISPLAY_OBJ_LIST
        USING
          EMPTY_EXTRACT.
      SET TITLEBAR 'ERM'.
      GD_SCMA_SPOOL-SPOOLTXT = SY-TITLE.
      GD_SCMA_SPOOL-SPOOLID = SY-SPONO.
      APPEND GD_SCMA_SPOOL TO GT_SCMA_SPOOL.
    ENDIF.
  ENDIF.

* Handle SchedMan, corresponding lines for old PEP deleted
  IF SCMA = YES.
    PERFORM CLOSE_RECORD_FOR_SCMA.     "I_46A_SCMA
  ENDIF.

  IF SY-BATCH <> YES.
*  Beginning note 396282
    IF sy-binpt = 'X'.
      IF obj_lst = yes.
        PERFORM DISPLAY_OBJ_LIST
          USING
            EMPTY_EXTRACT.
      ENDIF.
    ELSE.
*  End note 396282
      IF T_AUFTLST[] IS INITIAL OR OBJ_LST = NO.
        PERFORM DISPLAY_GRUNDLISTE.
      ELSE.
        PERFORM DISPLAY_OBJ_LIST
          USING
            EMPTY_EXTRACT.
      ENDIF.
    ENDIF.                                                      "396282
  ENDIF.
* end I_46A_SCMA

* alten ALV-Aufruf ausgelagert.

* Versorgen des Debug-Logs
  IF NOT PARDEBUG IS INITIAL AND NOT PARALLEL IS INITIAL.
    LEAVE TO LIST-PROCESSING.
    CALL FUNCTION 'KKPA_PARA_DEBUG_LOG_WRITE'.
  ENDIF.
* Verlassen des Reports
  IF NOT GS_EXITCAUSE-EXIT IS INITIAL.
    MEMORY_OKCODE = 'ENDE'.
    EXPORT MEMORY_OKCODE TO MEMORY ID CON_KEY_ID.
  ENDIF.
ENDFORM.


*eject
************************************************************************
*
************************************************************************
DEFINE MSG_AND_EXIT_IF_EXCEPTION.
  IF NOT ( SY-SUBRC IS INITIAL ).
*   add 1 to pd_obj_error.             "ausserhalb in auftrag_loop"M40C
    IF PD_AUSFUEHR EQ YES OR PD_SIMULATI EQ YES.            "40A
      PERFORM EXCEPTION_HANDLING
         USING PS_AUFTRAG.
    ENDIF.                                                  "40A
    PERFORM FEHLERZEILE USING PD_FEHLERAUFTRAG
*                              pd_ampel                             "40C
                              PS_AUFTRAG-WRT
                              PS_AUFTRAG-WRTK
                              PS_AUFTRAG-WRT_UPD.
    IF PD_AUSFUEHR EQ YES.
      CALL FUNCTION 'KKA_ABGR_DEQUEUE'.
    ENDIF.
    EXIT.                              "from auftrag_abgrenzen
  ENDIF.
END-OF-DEFINITION.

************************************************************************
*
************************************************************************
AT USER-COMMAND.
  CASE SY-UCOMM.
    WHEN 'PROT'.
      CALL FUNCTION 'CM_F_DISPLAY_LOG' "M_46A
           EXPORTING
                GRID_DISPLAY       = 'X'                          "I_46A
*               aplid              = 'KKA'.                       "P30E
                APLID              =  ABGR_APLID.                 "P30E
*               HEADLINE           = ' '
*               OCS_ACTIV          = ' '
*               OCS_SEND_IMMEDIATE = ' '
*          exceptions
*               not_active         = 01.
    WHEN 'KRKS'.
      CALL FUNCTION 'K_KOKRS_SET'
           EXPORTING
                DISPLAY  = ' '
                I_KOKRS  = KOKRS
                POPUP    = '1'         "Popup immer anzeigen
           IMPORTING
                E_KOKRS  = KOKRS
                E_ACTION = AKTION.
*            EXCEPTIONS NOT_FOUND = 01.
      IF AKTION EQ 'E'.
        LEAVE.
      ENDIF.
    WHEN 'ENDE'.
      IF SY-TCODE EQ CON_TCODE_EZ_E OR SY-TCODE EQ CON_TCODE_SA_E OR
         SY-TCODE EQ CON_TCODE_EZ_A OR SY-TCODE EQ CON_TCODE_SA_A OR
         SY-TCODE EQ CON_TCODE_PK_E OR SY-TCODE EQ CON_TCODE_PK_A OR
         SY-TCODE EQ CON_TCODE_SE_E OR SY-TCODE EQ CON_TCODE_SE_A.
        MEMORY_OKCODE = 'ENDE'.
        EXPORT MEMORY_OKCODE TO MEMORY ID CON_KEY_ID.
        LEAVE.
      ELSE.
        SET SCREEN 0.
        LEAVE SCREEN.
      ENDIF.
    WHEN 'ABBR'.
      IF SY-TCODE EQ CON_TCODE_EZ_E OR SY-TCODE EQ CON_TCODE_SA_E OR
         SY-TCODE EQ CON_TCODE_EZ_A OR SY-TCODE EQ CON_TCODE_SA_A OR
         SY-TCODE EQ CON_TCODE_PK_E OR SY-TCODE EQ CON_TCODE_PK_A OR
         SY-TCODE EQ CON_TCODE_SE_E OR SY-TCODE EQ CON_TCODE_SE_A.
        LEAVE.
      ELSE.
        SET SCREEN 0.
        LEAVE SCREEN.
      ENDIF.
    WHEN 'EBCK'.
      IF SY-TCODE EQ CON_TCODE_EZ_E OR SY-TCODE EQ CON_TCODE_SA_E OR
         SY-TCODE EQ CON_TCODE_EZ_A OR SY-TCODE EQ CON_TCODE_SA_A OR
         SY-TCODE EQ CON_TCODE_PK_E OR SY-TCODE EQ CON_TCODE_PK_A OR
         SY-TCODE EQ CON_TCODE_SE_E OR SY-TCODE EQ CON_TCODE_SE_A.
        LEAVE.
      ELSE.
        SET SCREEN 0.
        LEAVE SCREEN.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

*eject
************************************************************************
* Unterprogramme
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  AUFTRAG_LOOP
*&---------------------------------------------------------------------*
*                                                                      *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  pd_fehlerhaft:     Ob Auftrag in mind. 1 Version fehlerhaft
*                          (oder in einer Position (bei Kuppel) neu 40c)
*                          => dann Auftrag in Alog
*----------------------------------------------------------------------*
FORM AUFTRAG_LOOP
   TABLES
     PT_VERSION          STRUCTURE KKAPARA_VS
     PT_AUFTRAGSLISTE    STRUCTURE KKAPARA_TA
   USING
     PS_AUFTRAG          LIKE KKAPARA_TA
     PS_PARAMS           LIKE KKAPARA_IN
     PD_OBJ_NOT_REL      LIKE SY-TABIX                              "46B
     PD_OBJ_TOTAL        LIKE SY-TABIX
     PD_OBJ_ERROR        LIKE SY-TABIX
     PD_FEHLERHAFT       TYPE C.

  DATA: LD_FEHLERAUFTRAG TYPE C, "Auftrag in akt. bearb. Vers. fehlerh.
        LD_WAEHR LIKE KKAH2000-TWAER,  "Währung, in der WIP angezeigt
        LD_AMPEL LIKE KKA0100-AMPEL, "entscheidet Ampel-Farbe d. Auftr.
        LD_MAXNT LIKE KKA0100-MSGMX. "zur Ermittl. d. max. NT d. Auftr.
  DATA: LD_REPEAT TYPE I,       "Zähler für mehrfachen Aufruf    "I_40C1
        LD_NO_0_WIP LIKE KKAPARA_IN-NO_0_WIP,                    "I_40C1
        LD_ISTAT LIKE TJ02T-ISTAT,     "I40C
        LD_OK_BUT_ALOG    LIKE SY-DEBUG.   "Char(1)              "40C_PK
  DATA: LS_TKKAS LIKE TKKAS,           "für FB KKA_ABGR_HOLE_DATEN
        LS_ABGR  LIKE KKA_HOLE_DATEN.  "für FB KKA_ABGR_HOLE_DATEN
  DATA: CHANGED TYPE KKA_YES_NO.  "WIP auf DB geändert     I_46A_SCMA
  DATA: NOT_RELEVANT TYPE KKA_YES_NO, "Auftrag nicht relevant     "46B
        STATUS TYPE KPEP_WL_OBJSTAT.                              "46B
         "Versionsübergreifender Status für SCMA-Arbeitsvorrat    "46B
  DATA: VERSION_CHANGED LIKE CHANGED.                          "207675
         "WIP der Version auf DB geändert                      "207675
ENHANCEMENT-POINT SAPKKA07_04 SPOTS ES_SAPKKA07 STATIC.
* Statuspuffer jetzt außerhalb der Versionen löschen              "46C
* (gepufferte Status löschen, da sonst Gefahr des Überlaufs).     "46C
  CALL FUNCTION 'STATUS_BUFFER_REFRESH'.                          "46C

*  ADD 1 TO PD_OBJ_TOTAL.               "ausserhalb Version"M40C  "46B
* obige Zeile nach unten verlagert                                "46B

* This flag must be changed only in the Industry Enhancement
  lf_isapo_pcc = no.
ENHANCEMENT-POINT SAPKKA07_02 SPOTS ES_SAPKKA07.
  CLEAR PD_FEHLERHAFT.
  PERFORM LIES_MENGEN                                          "173985
    USING
      PS_PARAMS
    CHANGING
      PS_AUFTRAG.

  LD_NO_0_WIP = PS_PARAMS-NO_0_WIP.    "I_40C1
  IF PS_AUFTRAG-FLG_MLTPS EQ 'X'.      "I_40C1
* Kuppelproduktion aktiv, WIP auf Pos.ebene                     "I_40C1
*  IF PS_AUFTRAG-POSNR EQ '0001'.                   "I_40C1  "D46A_SCMA
    "Achtung: Es gibt auch Aufträge mit Kuppelprodukten, die mit
    "Position > 0001 beginnen. Da dieser Fall sehr selten und WIP auf
    "Kopfebene noch unwahrscheinlicher, wird dies nicht behandelt.
    GD_MLT_POS = 'X'. "bei erster Pos. setzen reicht            "I_40C1
                                       " Wird jetzt immer gesetzt
   IF PS_AUFTRAG-POSNR EQ '0001' AND KASS = NO.              "I_46A_SCMA
      "Bei KASS werden die Auftragsköpfe bei Kuppelproduktion getrennt
      "übergeben. Sonderbehandlung nicht nötig.
      PS_AUFTRAG-POSNR = '0000'.       "I_40C1
*   Objektnummer des Kopfes okay                                 "I_40C1
     LD_NO_0_WIP = 'X'. "Kopf nur bei Wertkorrektur in Liste rein"I_40C1
      LD_REPEAT = 2.                   "I_40C1
      "Im ersten Durchlauf WIP auf Kopfebene auflösen (für alte Aufträge
     "möglicherweise nötig). Erst im zweiten WIP für Position berechnen.
    ELSE.                              "I_40C1
      IF PS_AUFTRAG-POSNR IS INITIAL.  "I_46A_SCMA
       LD_NO_0_WIP = 'X'. "Kopf nur bei Wertkorrektur in Liste rein "46A
      ENDIF.                           "I_46A_SCMA
*   Setze korrekte Objektnummer                                  "I_40C1
      IF NOT PS_AUFTRAG-OBJNP IS INITIAL."I_40C1
      PS_AUFTRAG-OBJNR = PS_AUFTRAG-OBJNP.                       "I_40C1
      ENDIF.                           "I_40C1
      LD_REPEAT = 1.                   "I_40C1
    ENDIF.                             "I_40C1
  ELSE.                                "I_40C1
* Kuppelproduktion inaktiv, WIP auf Kopfebene                   "I_40C1
    CLEAR PS_AUFTRAG-POSNR.            "I_40C1
    LD_REPEAT = 1.                     "I_40C1
  ENDIF.                               "I_40C1
  WHILE LD_REPEAT GT 0.                "I_40C1
    STATUS = KPEPW_OBJSTAT-OK.                                  "46B
    LOOP AT PT_VERSION.
      IF PS_PARAMS-ANZEIGEN EQ NO.
*     Initialisiere den Message-Handler für aktuellen Auftrag
*     4.0C: Erweitere um weitere Details!!!                      "*_40C
        PERFORM CM_F_SET_OBJECT        "I_40C
           USING PS_AUFTRAG            "I_40C
                PT_VERSION. "Header Line mit bearb. Version       "I_40C
      ENDIF.
      CLEAR LD_FEHLERAUFTRAG.
      IF PS_PARAMS-AUSFUEHR EQ YES OR PS_PARAMS-SIMULATI EQ YES.
        LD_AMPEL = CON_GRUEN.          "Ampel für Auftrag auf gruen
*     Setze Diff. der Zähler auf Null, um jetzt neu zu zählen
        GS_OLDTOTAL = GS_NEWTOTAL.
ENHANCEMENT-POINT SAPKKA07_03 SPOTS ES_SAPKKA07.
        IF lf_isapo_pcc EQ no.  "always in non-industry scenario
          PERFORM AUFTRAG_ABGRENZEN
                  USING
                    PS_AUFTRAG
                    PT_VERSION-VERSA
*                     p_params-waehr                            "D_40A_CCC
                   LD_WAEHR            "I_40A_CCC
                    PS_PARAMS-ABGRMONA
                    PS_PARAMS-ABGRJAHR
                    PS_PARAMS-AUSFUEHR
                    PS_PARAMS-SIMULATI
*                     ps_params-withimsg                         "40C
                      PS_PARAMS-P_CCCURR  "I_40A_CCC
                      PS_PARAMS-P_C2CURR  "I_40B_C2C
*                     alog  "nur ausserhalb benutzt              "D_40B
*                     ps_params-p_maxnta                         "40C
*                     ld_ampel                                   "40C
*                     ld_maxnt                                   "40C
                      LD_FEHLERAUFTRAG
                      LD_OK_BUT_ALOG      "40C_PK
*                     pd_obj_total                               "D40C
                      PD_OBJ_ERROR
                      PS_PARAMS-PAR_EINZ "46B
                      VERSION_CHANGED.           "I_46A_SCMA    "M207675
* WIP-Daten haben sich für Objekt geändert, sobald sich die Daten für
* eine Version geändert haben:
        IF VERSION_CHANGED = YES.                               "207675
          CHANGED = YES.                                        "207675
        ENDIF.                                                  "207675
* Beginning 46B
        IF PS_PARAMS-PAR_EINZ = NO.
* Jetzt kann auch SAPLKKAG über Relevanz entscheiden (nur für
* Sammelverarbeitung wichtig):
          CALL FUNCTION 'KKA_ABGR_CHECK_RELEVANCE'
            IMPORTING
              OBJ_NOT_RELEVANT = NOT_RELEVANT.

          IF NOT_RELEVANT = YES.
            IF STATUS = KPEPW_OBJSTAT-OK.
* Den versionsunabhängigen Auftragsstatus nur dann auf nicht relevant
* setzen, wenn in anderer Version kein Fehler aufgetreten ist
              STATUS = KPEPW_OBJSTAT-NOT_RELEVANT.
            ENDIF.
          ENDIF.
        ENDIF.
* End 46B
        ENDIF.   "IF lf_isapo_pcc EQ no

        IF LD_FEHLERAUFTRAG EQ 'X'.                         "40C
          LD_AMPEL = CON_ROT.                               "40C
          STATUS = KPEPW_OBJSTAT-ERROR.                     "46B
        ENDIF.                                              "40C

* Neu zu 46B: In SAPLKKAG können auch Warnungen ausgegeben werden,
* deshalb müssen die Meldungen unabhängig von "WITHIMSG" geholt
* werden. Beim Holen werden ggf. I-Meldungen aussortiert.
        data msgtypes(3) type C.                            "46B

        IF lf_isapo_pcc EQ no.  "always in non-industry scenario
          IF PS_PARAMS-WITHIMSG EQ YES.
            clear msgtypes. "default = alle                 "46B
          else.                                             "46B
            msgtypes = 'WEA'. "alle bis auf I- und S-Meld.  "46B
        endif.                                              "46B
          CALL FUNCTION 'KKA_ABGR_NACHRICHTEN_FUER_CM_F'
               EXPORTING
                    CM_F_OBJECT_DEPENDENT = 'X'  "30F_obj
                  COLL_MSG_TYPES        = msgtypes          "46B
               EXCEPTIONS
                    NACHRICHT_TYP_E       = 01  "P30E
                    NACHRICHT_TYP_A       = 02. "P30E
        ENDIF.    "IF lf_isapo_pcc EQ no

* Beginning of deletion 187150
* Nicht relevante Aufträge nie in Ergebnisliste aufnehmen:   "46B
*        CHECK STATUS <> KPEPW_OBJSTAT-NOT_RELEVANT.         "46B
* End 187150

        IF NOT PS_PARAMS-P_MAXNTA IS INITIAL OR
           PS_PARAMS-SCMA_WORKLISTS_ACTIVE = YES.          "I_46A_SCMA
          PERFORM SETZE_MAX_NT
             USING LD_AMPEL
                   LD_MAXNT.
        ENDIF.

* Nicht relevante Aufträge nie in Ergebnisliste aufnehmen:  "187150
        CHECK STATUS <> KPEPW_OBJSTAT-NOT_RELEVANT.         "187150

*     Zu 4.0C: FB und Setze_MaxNT ausgelagert aus auft.._abgr...   "40C
        IF lf_isapo_pcc EQ no.  "always in non-industry scenario
          CALL FUNCTION 'KKA_ABGR_HOLE_DATEN'
         IMPORTING
              E_ABGR  = LS_ABGR
              E_TKKAS = LS_TKKAS
             EXCEPTIONS
              OTHERS  = 0.
        PS_AUFTRAG-PAR_AUFLO = LS_ABGR-PAR_AUFLO.
        PS_AUFTRAG-BWVAR     = LS_TKKAS-BWVAR.
        PS_AUFTRAG-ABART     = LS_TKKAS-ABART.
       PS_AUFTRAG-ABGSL     = LS_TKKAS-ABGSL.                     "I_40C
       LD_ISTAT             = LS_TKKAS-ISTAT."Stattdessen St.text!"I_40C
        CALL FUNCTION 'STATUS_NUMBER_CONVERSION'
             EXPORTING
                  LANGUAGE           = SY-LANGU
                  STATUS_NUMBER      = LD_ISTAT
             IMPORTING
                  TXT04              = PS_AUFTRAG-STATTEXT
             EXCEPTIONS
                  INSUFFICIENT_INPUT = 1
                  OBJECT_NOT_FOUND   = 2
                  STATUS_NOT_FOUND   = 3
                  STSMA_NOT_FOUND    = 4
                  OTHERS             = 5.
        IF SY-SUBRC <> 0.
          CLEAR PS_AUFTRAG-STATTEXT.
        ENDIF.
        CASE LS_TKKAS-ABART.
          WHEN 'F'.
*             Bewertung zu Istkosten
              PS_AUFTRAG-BEWER = TEXT-WII.
            WHEN 'S'.
*             Bewertung zu Sollkosten
              PS_AUFTRAG-BEWER = TEXT-WIS.
          ENDCASE.
        ENDIF.  "IF lf_isapo_pcc EQ no.
      ELSE.
        PERFORM ABGR_DATEN_LESEN_UND_LISTEN
          USING
            PS_AUFTRAG
            PT_VERSION-VERSA                                    "H980404
           PS_PARAMS-P_CCCURR          "40C_CCC
           LD_WAEHR              "Ausgabe-Währung               "40C_CCC
           PS_PARAMS-WAEHR       "KRK-Währung                   "40C_CCC
           LD_AMPEL                    "40C_CCC
           LD_FEHLERAUFTRAG            "40C_CCC
            PS_PARAMS-ABGRMONA
            PS_PARAMS-ABGRJAHR.
        perform get_status using PS_AUFTRAG-objnr               "H722130
                                 PS_AUFTRAG-STATTEXT.           "H722130
        perform get_bewart using PS_AUFTRAG-abgsl               "H722130
                                 ABGR_VSN-VERSA                 "H722130
                                 PS_AUFTRAG-bewer.              "H722130
      ENDIF.
*   Ermitteln der Objekt-ID                                       "I45A
      CALL FUNCTION 'K_OBJECT_ID_GET'  "I45A
           EXPORTING                   "I45A
               PAR_OBJNR         = PS_AUFTRAG-OBJNR                "I45A
               PAR_MATNR         = PS_AUFTRAG-MATNR                "I45A
               PAR_WERKS         = PS_AUFTRAG-WERKS                "I45A
               PAR_VERID         = PS_AUFTRAG-VERID                "I45A
               PAR_AUTYP         = PS_AUFTRAG-AUTYP                "I45A
               PAR_PROCNR        = PS_AUFTRAG-PROCNR               "I45A
           IMPORTING                   "I45A
               PAR_OBJID         = PS_AUFTRAG-OBJID                "I45A
               PAR_PROCTX        = PS_AUFTRAG-PROCNR_TXT           "46C
           EXCEPTIONS                  "I45A
                OTHERS            = 1. "I45A
      CLEAR PT_AUFTRAGSLISTE.
      MOVE-CORRESPONDING PS_AUFTRAG TO PT_AUFTRAGSLISTE.
*   ld_no_0_wip um Kopf-WIP bei Kuppelprod. nur bei Wertkorr. zu zeigen
      PERFORM FUELLE_AUFTRAGSLISTE
                  TABLES PT_AUFTRAGSLISTE
                  USING  PT_VERSION
                         LD_WAEHR
                         PS_PARAMS-FEHLAUFT
                        LD_FEHLERAUFTRAG                        "40B_CCC
                        LD_NO_0_WIP    "M_40C1
                         LD_AMPEL
                         LD_MAXNT.
     IF LD_FEHLERAUFTRAG EQ 'X' OR LD_OK_BUT_ALOG EQ 'X'.      "M_40C_PK
        PD_FEHLERHAFT = 'X'.      "sorgt für Schreiben in Arbeitsvorrat
      ENDIF.
    ENDLOOP.                           "at pt_version.
* Beginning I_46A
    IF PT_VERSION[] IS INITIAL.
* Tabelle nicht gefüllt wegen KJ295 oder KJ277 oder wegen Fehler, bei
* dem kein Auftrag bearbeitet werden soll
      LD_FEHLERAUFTRAG = YES.
      PD_FEHLERHAFT = YES.
    ENDIF.
* End I_46A

    IF LD_REPEAT EQ 2.                 "I_40C1
* Beginning I_46A
      IF LD_FEHLERAUFTRAG EQ 'X'.
* Bei fehlerhaftem Auftragskopf mit Kuppelprodukten Anzahl der
* bearbeiteten Objekte um eins erhöhen. Bei der alten Verarbeitung
* ohne KASS werden Auftragsköpfe nicht mitgezählt (dieser Abschnitt
* wird nur dann durchlaufen).
        ADD 1 TO PD_OBJ_TOTAL.
        ADD 1 TO PD_OBJ_ERROR.                    "46B
      ELSEIF STATUS = KPEPW_OBJSTAT-NOT_RELEVANT. "46B
        ADD 1 TO PD_OBJ_NOT_REL.                  "46B
      ENDIF.
* End I_46A

      PS_AUFTRAG-POSNR = '0001'.       "I_40C1
*   Setze korrekte Objektnummer                                  "I_40C1
      IF NOT PS_AUFTRAG-OBJNP IS INITIAL."I_40C1
      PS_AUFTRAG-OBJNR = PS_AUFTRAG-OBJNP.                       "I_40C1
      ENDIF.                           "I_40C1
     LD_NO_0_WIP = PS_PARAMS-NO_0_WIP."Für Pos. abh. von DynpFlag"I_40C1
    ENDIF.                             "I_40C1
    LD_REPEAT = LD_REPEAT - 1.         "I_40C1
  ENDWHILE.                            "I_40C1

* Beginning I_46A_SCMA:
  IF NOT PS_AUFTRAG-FLG_MLTPS IS INITIAL AND
     PS_AUFTRAG-POSNR IS INITIAL AND LD_FEHLERAUFTRAG = NO.
* Bei Kuppelproduktion Auftragskopf als nicht relevant zurückmelden,
* wenn kein Fehler aufgetreten ist. Nur hier ist Position initial.
* Dieser Abschnitt wird nur bei KASS-Selektion durchlaufen (nur hier
* werden die Auftragsköpfe getrennt übergeben).
    STATUS = KPEPW_OBJSTAT-NOT_RELEVANT.
    PERFORM HANDLE_MESSAGE
      USING
        PS_AUFTRAG
        'KJ' 'I' 154 PM PM PM PM.
  ENDIF.

* Beginning 46B
  IF STATUS = KPEPW_OBJSTAT-NOT_RELEVANT.
    ADD 1 TO PD_OBJ_NOT_REL.
  ELSE.
* Nicht relevante Objekte zählen nicht als bearbeitet
    ADD 1 TO PD_OBJ_TOTAL.
  ENDIF.
* End 46B

  IF PS_PARAMS-SCMA_WORKLISTS_ACTIVE = YES.
    IF LD_FEHLERAUFTRAG = 'X'.
      STATUS = KPEPW_OBJSTAT-ERROR.
    ENDIF.
    PERFORM HANDLE_STATUS_WL
      USING
        PS_AUFTRAG
        STATUS
        CHANGED.
  ENDIF.
* End I_46A_SCMA

*  IF PD_FEHLERHAFT EQ 'X'.            "46A
  if ld_fehlerauftrag = yes.           "46A
* pd_fehlerhaft wird auch gesetzt, wenn Auftrag in den alten
* Arbeitsvorrat gestellt werden soll, der Auftrag aber nicht als
* fehlerhaft in der Ergebnisliste ausgewiesen wird
    ADD 1 TO PD_OBJ_ERROR.             "jetzt ausserhalb vers-loop"M40C
* Unterscheidung Auftragskopf/Position fehlt!
  ENDIF.
ENDFORM.
*eject
************************************************************************
FORM AUFTRAG_ABGRENZEN                                      "40A
   USING                                                    "40A
     PS_AUFTRAG          LIKE KKAPARA_TA                    "40A
     PD_ABGRVERS         LIKE KKAPARA_VS-VERSA              "40A
     PD_WAEHR            LIKE KKAPARA_IN-WAEHR              "40A
     PD_ABGRMONA         LIKE KKAPARA_IN-ABGRMONA           "40A
     PD_ABGRJAHR         LIKE KKAPARA_IN-ABGRJAHR           "40A
     PD_AUSFUEHR         LIKE KKAPARA_IN-AUSFUEHR           "40A
     PD_SIMULATI         LIKE KKAPARA_IN-SIMULATI           "40A
*     pd_withimsg         like kkapara_in-withimsg                  "40C
     PD_CCCURR           LIKE KKAPARA_IN-P_CCCURR           "40A
     PD_C2CURR           LIKE KKAPARA_IN-P_C2CURR            "I_40B_C2C
*     pd_maxnta           like kkapara_in-p_maxnta                  "40C
*     pd_ampel            like kka0100-ampel                        "40C
*     pd_maxnt            like kka0100-msgmx                        "40C
     PD_FEHLERAUFTRAG    LIKE SY-DEBUG "Char(1)                   "40A
     PD_OK_BUT_ALOG      LIKE SY-DEBUG "Char(1)                "40C_PK
*     pd_obj_total        like sy-tabix                            "D40C
     PD_OBJ_ERROR        LIKE SY-TABIX
     PD_EINZELVERARB     LIKE PAR_EINZ     "46B
     PD_CHANGED          TYPE C.       "I_46A_SCMA

 DATA: LD_POSNR LIKE AFPO-POSNR.      "PosNr 0 if no joint prod. "I_40C1

*  add 1 to pd_obj_total.                              "ausserhalb"D40C

* Setze auszugebende Währung zurück                               "P30E
*  clear gd_ta_waehr.                                              "40A
  CLEAR PD_WAEHR.                                           "40A

  CLEAR PD_CHANGED.                    "I_46A_SCMA
  SET UPDATE TASK LOCAL.               "30F_BUCH

  IF PD_CCCURR EQ 'X'.                 "I_40A_CCC
    WAEHRUNG_MANUELL = 'K'.            "I_40A_CCC
*   Calculate contr.area.curr. first, so show in c.c.curr.   "I_40A_CCC
  ELSE.                                "I_40A_CCC
    WAEHRUNG_MANUELL = 'B'.            "I_40A_CCC
*   Calculate comp.code.curr. first, so show in co.a.curr.   "I_40A_CCC
  ENDIF.                               "I_40A_CCC

  CALL FUNCTION 'KKA_ABGR_INITIALISIEREN'
       EXPORTING
            R_MESSAGE             = R_MESSAGE
            WAEHRUNG_MANUELL      = WAEHRUNG_MANUELL  "M_40B_C2C
            WAEHRUNG_OBJEKT_FORCE = PD_C2CURR  "I_45B_C2C
            WIP                   = YES"I46A
            TRANSAKTIONSGRUPPE    = TRANSAKTIONS_GRUPPE_G      "H1041813
            EINZELVERARBEITUNG    = PD_EINZELVERARB. "I45A  "M46B

  ABGR_PERIOD-M = PD_ABGRMONA.                              "40A
  ABGR_PERIOD-J = PD_ABGRJAHR.                              "40A
  KKALKKAG-ABGRPERIOD = ABGR_PERIOD.   "P31G.INS5
  IF PS_AUFTRAG-SAFNR IS INITIAL OR
* falls afpo auch für Nicht-05 eingelesen, kann safnr gefüllt s. "I_40A
     PS_AUFTRAG-AUTYP NE '05'.  "05 = PKOSA                      "I_40A
*    auch WIP für neue Pkosa ermittelbar                    "P30K033159
*    über KKA_ABGR_START_AUFTRAG                            "P30K033159
*   Herkömmliche WIP-Ermittlung wie bei Werkstattfertigung
*   Verwende Verarbeitung für AUFK-Auftrag
    CALL FUNCTION 'KKA_ABGR_START_AUFTRAG'
         EXPORTING
              AUFTRAGSNR      = PS_AUFTRAG-AUFNR
              AUFTRAGSPOSNR   = PS_AUFTRAG-POSNR  "I_40C1
              ABGR_PERIODE    = KKALKKAG-ABGRPERIOD  "P31G.INS5
              ABGR_VERSION    = PD_ABGRVERS
              KABG_PRUEFEN    = 'X'    "I_31H_VRGNG
              KABM_PRUEFEN    = ' '    "I_31H_VRGNG
         EXCEPTIONS
              NACHRICHT_TYP_E = 01     "P30E
              NACHRICHT_TYP_A = 02.    "P30E
    MSG_AND_EXIT_IF_EXCEPTION.
*   endif.                                                  "P30K033159
  ELSE. " Zweig zu 4.6A nicht mehr durchlaufen
*    Verwende Verarbeitung für AUFK-Auftrag
    CALL FUNCTION 'KKA_ABGR_START_SERIENAUFTRAG'
         EXPORTING
              AUFTRAGSNR      = PS_AUFTRAG-SAFNR
              ABGR_VERSION    = PD_ABGRVERS
         EXCEPTIONS
              NACHRICHT_TYP_E = 01
              NACHRICHT_TYP_A = 02.
    MSG_AND_EXIT_IF_EXCEPTION.
  ENDIF.

  CALL FUNCTION 'KKA_ABGR_VORBEREITEN'
                EXPORTING ABGR_PERIODE = KKALKKAG-ABGRPERIOD  "P30F.MODT
                          ABGR_VERSION = PD_ABGRVERS
                          LEDGER = LEDGER_00
                          NUR_MANUELL = NO
                          NUR_MASCHINELL = YES                "P31G.INS7
*             hier Schalter STORNIERUNG par_stor einbauen     "30F_STOR
                      EXCEPTIONS NACHRICHT_TYP_E = 01
                                 NACHRICHT_TYP_A = 02.
  MSG_AND_EXIT_IF_EXCEPTION.

  IF PD_AUSFUEHR EQ YES.                                    "40A
    CALL FUNCTION 'KKA_ABGR_ENQUEUE'
         EXCEPTIONS
              NACHRICHT_TYP_E = 01     "P30E
              NACHRICHT_TYP_A = 02.    "P30E
    MSG_AND_EXIT_IF_EXCEPTION.
  ENDIF.

  CALL FUNCTION 'KKA_ABGR_KOSA_LESEN'
       IMPORTING
            SOLL_WIP_NOTOK  = PD_OK_BUT_ALOG  "40C_PK
* Parameter gibt an, daß bei einzelnen, einem PKOSA zugeordneten
* Aufträgen kein WIP ermittelt werden konnte. WIP wird trotzdem
* ausgewiesen, da diese Aufträge möglicherweise nicht ins Gewicht
* fallen
       EXCEPTIONS
            NACHRICHT_TYP_E = 01       "P30E
            NACHRICHT_TYP_A = 02.      "P30E
  MSG_AND_EXIT_IF_EXCEPTION.

  CALL FUNCTION 'KKA_ABGR_DURCHFUEHREN'
       EXCEPTIONS
            NACHRICHT_TYP_E = 01       "P30E
            NACHRICHT_TYP_A = 02.      "P30E
  MSG_AND_EXIT_IF_EXCEPTION.

*  if ausfuehr eq yes.                                             "40A
  IF PD_AUSFUEHR EQ YES.                                    "40A
    CALL FUNCTION 'KKA_ABGR_FORTSCHREIBEN'
         EXPORTING
              ABGR_SICHERN    = YES
              COMMIT_WORK     = YES
         IMPORTING
              ABGR_CHANGED    = PD_CHANGED  "I_46A_SCMA
         EXCEPTIONS
              NACHRICHT_TYP_E = 01     "P30E
              NACHRICHT_TYP_A = 02.    "P30E
    MSG_AND_EXIT_IF_EXCEPTION.
*  elseif simulati eq yes.
  ELSEIF PD_SIMULATI EQ YES.
    CALL FUNCTION 'KKA_ABGR_FORTSCHREIBEN'
         EXPORTING
              ABGR_SICHERN    = NO
              COMMIT_WORK     = NO
         EXCEPTIONS
              NACHRICHT_TYP_E = 01     "P30E
              NACHRICHT_TYP_A = 02.    "P30E
    MSG_AND_EXIT_IF_EXCEPTION.
  ENDIF.

  PERFORM ABGR_DATEN_HOLEN_UND_LISTEN
     USING PS_AUFTRAG
           PD_ABGRMONA
           PD_ABGRJAHR
           PD_WAEHR.
*           pd_ampel. "Ampel immer durch FB gesetzt: Flex.Fehlerst."40C

*4.0C: MOVED outside: so error-orders also handled!
* if pd_withimsg eq yes.
*   call function 'KKA_ABGR_NACHRICHTEN_FUER_CM_F'
*                     exporting  cm_f_object_dependent = 'X'   "30F_obj
*                     exceptions nachricht_typ_e = 01             "P30E
*                                nachricht_typ_a = 02.            "P30E
*
**  if pd_ausfuehr eq yes or pd_simulati eq yes.                 "D_40C
**    perform msg_object_done  using ps_auftrag.                 "D_40C
**  endif.                                                       "D_40C
* endif." pd_withimsg.
ENDFORM.

*eject
************************************************************************
*
************************************************************************
FORM EXCEPTION_HANDLING
    USING PS_AUFTRAG LIKE KKAPARA_TA.                       "40A

  DATA MSGNR LIKE CMIMSG-MSGNR.

  MSGNR = SY-MSGNO.
  CALL FUNCTION 'CM_F_MESSAGE'
       EXPORTING
            ARBGB            = SY-MSGID
            MSGNR            = MSGNR
            MSGTY            = SY-MSGTY
            MSGV1            = SY-MSGV1
            MSGV2            = SY-MSGV2
            MSGV3            = SY-MSGV3
            MSGV4            = SY-MSGV4
            MSG_ON_SCREEN    = NO
            OBJECT_DEPENDENT = YES
            APPEND_SAME_MSG  = YES.
ENDFORM.

*eject
************************************************************************
*
************************************************************************
*form msg_object_done                                     "D_40C
*   using ps_auftrag like kkapara_ta.                     "D_40C
*eject
************************************************************************
*
************************************************************************
FORM MESSAGE_INFO.
*  CHECK AUSFUEHR EQ YES OR SIMULATI EQ YES.                    "488468

  CALL FUNCTION 'CM_F_INFO'
       EXPORTING ALL               = YES
                 APLID             = ABGR_APLID
                 OBJECT_ID         = ABGR_OBJECT_ID
*                OBJECT            = ' '
       IMPORTING A_MSG_COUNTER_PRO = A_MSG_NR
                 E_MSG_COUNTER_PRO = E_MSG_NR
                 I_MSG_COUNTER_PRO = I_MSG_NR
                 MSG_COUNTER_PRO   = MSG_NR
                 MSGTY_PRO         = MAX_MSG                "P30K049339
                 W_MSG_COUNTER_PRO = W_MSG_NR.
*                APLIDENT          =
*                A_MSG_COUNTER_SCR =
*                E_MSG_COUNTER_SCR =
*                I_MSG_COUNTER_SCR =
*                MAX_SEVERITY_PRO  =
*                MAX_SEVERITY_SCR  =
*                MSGTY_PRO         =
*                MSGTY_SCR         =
*                MSG_COUNTER_SCR   =
*                NOT_ACTIVE        =
*                OBJECT_IDENT      =
*                W_MSG_COUNTER_SCR =
*      EXCEPTIONS WRONG_OBJECT_ID   = 01.
ENDFORM.

*eject
************************************************************************
*
************************************************************************
FORM MESSAGE_PRINT.
*  CHECK AUSFUEHR EQ YES OR SIMULATI EQ YES.                    "488468

  CALL FUNCTION 'CM_F_PROTOCOL_PRINT'
       EXPORTING APLID         = ABGR_APLID
                 HEADLINE      = ' '
*                 OBJECT_ID     = ABGR_OBJECT_ID "D_46A_SCMA
*                ONLY_INFO     = ' '
*                ONLY_MSGTYP   = ' '
*                SORT_CRITERIA = ' '
                 WITH_INFO     = ' '
       EXCEPTIONS NO_PROTOCOL   = 02.
*                 NOT_ACTIVE    = 01
ENDFORM.

*eject
************************************************************************
*
************************************************************************
FORM MESSAGE_INITIALIZE.
*  CHECK AUSFUEHR EQ YES OR SIMULATI EQ YES.                    "488468

  CALL FUNCTION 'CM_F_INITIALIZE'
       EXPORTING
            ABORT_MSGTY     = ABGR_ABORT_MSGTY
            APLID           = ABGR_APLID
            MSG_ON_SCREEN   = NO
            OBJECT_ID       = ABGR_OBJECT_ID
            OCS_ACTIV       = NO
            REFRESH_OLD_LOG = YES
            NO_OTHER_INITIALIZE = YES                           "H400509
            SMSG_INITIALIZE = NO.
*      EXCEPTIONS MESSAGE_TYPE_NOT_VALID = 01
*                 UNKNOWN_APLID          = 02
*                 UNKNOWN_OBJECT_ID      = 03.

* Beginn P30E_AV
  IF NOT P_ALOG IS INITIAL.            "Arbeitsvorrat-Par. angeschaltet
*  Arbeitsvorrat wird bei Testlauf und Echtlauf geschrieben
    REFRESH GT_SPAR.
    GT_SPAR-PARAM = 'kokrs'.           "für Set_Kokrs nötig,
    GT_SPAR-VALUE = KOKRS.       "obwohl Aufnr ohne Kokrs eindeutig
    APPEND GT_SPAR.
    GT_SPAR-PARAM = 'ABGRMONA'.
    GT_SPAR-VALUE = ABGRMONA.
    APPEND GT_SPAR.
    GT_SPAR-PARAM = 'ABGRJAHR'.
    GT_SPAR-VALUE = ABGRJAHR.
    APPEND GT_SPAR.
    GT_SPAR-PARAM = 'ABGRVERS'.        "bei allen Versionen: leer
    GT_SPAR-VALUE = ABGRVERS-LOW.      "-> dann pro relevanten Auftrag
    APPEND GT_SPAR.                    "für alle Versionen neuaufgesetzt
    GT_SPAR-PARAM = 'SY_BATCH'.
    GT_SPAR-VALUE = SY-BATCH.          "Online oder Hintergrundverarb.
    APPEND GT_SPAR.
    GT_SPAR-PARAM = 'SIMULATI'.
    GT_SPAR-VALUE = SIMULATI.        "Untersch. für Echt- oder Testlauf
    APPEND GT_SPAR.
    GT_SPAR-PARAM = 'FEHLAUFT'.
    GT_SPAR-VALUE = FEHLAUFT.
    APPEND GT_SPAR.
    GT_SPAR-PARAM = 'NO_0_WIP'.        "I_40B_0WIP
    GT_SPAR-VALUE = NO_0_WIP.          "I_40B_0WIP
    APPEND GT_SPAR.                    "I_40B_0WIP
    GT_SPAR-PARAM = 'P_CCCURR'.        "I_40B_CCC
    GT_SPAR-VALUE = P_CCCURR.          "I_40B_CCC
    APPEND GT_SPAR.                    "I_40B_CCC
*    gt_spar-param = 'P_A_INFO'.                             "I_40B_info
*    gt_spar-value = p_a_info.                               "I_40B_info
*    append gt_spar.                                         "I_40B_info
    GT_SPAR-PARAM = 'P_A_VARI'.        "I_40C_Vari
    GT_SPAR-VALUE = P_A_VARI.          "I_40C_Vari
    APPEND GT_SPAR.                    "I_40C_Vari
    GT_SPAR-PARAM = 'P_2_CURR'.        "I_40B_C2C
    GT_SPAR-VALUE = P_2_CURR.          "I_40B_C2C
    APPEND GT_SPAR.                    "I_40B_C2C
    GT_SPAR-PARAM = 'WITHIMSG'.
    GT_SPAR-VALUE = WITHIMSG.
    APPEND GT_SPAR.
    GT_SPAR-PARAM = 'P_MAXNTA'.
    GT_SPAR-VALUE = P_MAXNTA.
    APPEND GT_SPAR.
    GD_TCODE = SY-TCODE.
    GD_REPID = SY-REPID.
*    Setze Ext. Nummer des Arbeitsvorrats
    IF SIMULATI IS INITIAL.
      GD_LAUFBEZ = TEXT-E_L.
    ELSE.
      GD_LAUFBEZ = TEXT-T_L.
    ENDIF.
    CONCATENATE GD_LAUFBEZ ABGRMONA '/' ABGRJAHR INTO GD_EXTNUMBER.
*   TRANSLATE GD_EXTNUMBER TO UPPER CASE.  "wg. ALog nötig! "D_46A_SCMA
    " oben ausgesternt wg. TODO-Fehler, ALog nicht mehr unterstützt
    CALL FUNCTION 'CO_APPL_LOG_INIT'
         EXPORTING
              SUBOBJECT = GD_SUBOBJEKT
              EXTNUMBER = GD_EXTNUMBER
              EXITPROG  = GD_EXITPROG
              EXITFORM  = GD_EXITFORM
              ANW_TCODE = GD_TCODE
              ANW_REPID = GD_REPID
         TABLES
              PARAMETER = GT_SPAR.
*      exceptions exception_from_call_function = 1
*                 others                       = 2.
  ENDIF.                               "not p_alog
* Ende P30E_AV
ENDFORM.

*eject
************************************************************************
*
************************************************************************
FORM MESSAGE_STORE.
*  CHECK AUSFUEHR EQ YES OR SIMULATI EQ YES.                    "488468

  IF MSG_NR EQ 0 AND SCMA = NO.        "M_46A_SCMA
    MESSAGE S501.
*   Keine Nachrichten für Protokoll vorhanden
*    exit.                                                     "P30E_AV
*  endif.                                                      "P30E_AV
  ELSE.                                "P30E_AV
    CALL FUNCTION 'CM_F_STORE'
       EXPORTING APLID                    = ABGR_APLID
                 IN_UPDATE_TASK           = NO
*                I_CMF_NR                 = 0
       IMPORTING E_CMF_NR                 = ABGR_MSG_STORE_NR.
*      EXCEPTIONS NOT_ACTIVE               = 01
*                 STORE_AND_LOAD_NOT_ACTIV = 02.
*    IF SY-SUBRC EQ 0.         "D_46A_SCMA wg. TODO
    IF SCMA = NO.                      "I_46A_SCMA
      "SCMA won't take care of message display and deletion.
      MESSAGE S502 WITH ABGR_MSG_STORE_NR.
    ENDIF.
  ENDIF.                               "P30E_AV
*  Beginn P30E_AV
  IF NOT P_ALOG IS INITIAL.            "Arbeitsvorrat-Par. angeschaltet
*  Arbeitsvorrat wird bei Testlauf und Echtlauf geschrieben
    REFRESH GT_SPAR.
    GT_SPAR-PARAM = 'MSGSTORENR'.      "Hier wird Anzahl der Nachrichten
    GT_SPAR-VALUE = ABGR_MSG_STORE_NR. "für den Arbeitsvorrat gemerkt
    APPEND GT_SPAR.

    CALL FUNCTION 'CO_APPL_LOG_PUT'
         TABLES
              PARAMETER = GT_SPAR.
*      exceptions exception_from_call_function = 1
*                 others                       = 2.
  ENDIF.                               "not p_alog
*  Ende   P30E_AV
ENDFORM.

*eject
************************************************************************
* FORM um WIP-Daten von der Datenbank zu lesen
************************************************************************
FORM ABGR_DATEN_LESEN_UND_LISTEN
   USING PS_AUFTRAG          LIKE KKAPARA_TA                "40A
         PD_ABGRVERS         LIKE KKAPARA_VS-VERSA             "H980404
         PD_CCCURR           LIKE KKAPARA_IN-P_CCCURR          "40B_CCC
         PD_WAEHR            LIKE T001-WAERS                   "40C_CCC
         PD_KRKWAEHR         LIKE KKAPARA_IN-WAEHR             "40C_CCC
         PD_AMPEL            LIKE KKA0100-AMPEL                "40C_CCC
         PD_FEHLERAUFTRAG    LIKE SY-DEBUG  "Char(1)           "40C_CCC
         PD_ABGRMONA         LIKE KKAPARA_IN-ABGRMONA       "40A
         PD_ABGRJAHR         LIKE KKAPARA_IN-ABGRJAHR.      "40A

  DATA: WIP_WRT LIKE TKKAABGR-WRT,
        WIP_WRTK LIKE TKKAABGR-WRT.

 DATA: LD_OBJ_CURR_READ,   "In Obj.waehrung steht Bukrs-Waehr.  "40B_CCC
       LD_BUKRS LIKE AUFK-BUKRS,   "Bukrs des Auftrags          "40B_CCC
       LD_FEHLER,          "Bukrs-Währung nicht abgespeichert   "40B_CCC
       LC_KABO LIKE JEST-STAT VALUE 'I0295'. "AbgrDaten in ObjW "40B_CCC

  CONSTANTS LC_ABGR LIKE JEST-STAT VALUE 'I0082'.                "363527

  CLEAR LD_FEHLER.                     "40B_CCC
  IF PD_CCCURR IS INITIAL.             "40B_CCC
    PD_WAEHR = PD_KRKWAEHR.            "40B_CCC
  ELSE.                                "40B_CCC
*   Nicht mehr nötig, da immer gleich gelesen                    "*_40C
*   Zunächst Lesen der Buchungskreiswährung           "40B_CCC   "D_40C
    SELECT SINGLE BUKRS INTO (LD_BUKRS)"40B_CCC   "D_40C
      FROM AUFK                        "40B_CCC   "D_40C
      WHERE AUFNR = PS_AUFTRAG-AUFNR.  "40B_CCC   "D_40C
    CLEAR PD_WAEHR.                    "40B_CCC
    SELECT SINGLE WAERS INTO (PD_WAEHR)"40B_CCC
      FROM T001                        "40B_CCC
      WHERE BUKRS = PS_AUFTRAG-BUKRS.  "I_40C
*     where bukrs = ld_bukrs.                         "40B_CCC   "D_40C
    IF SY-SUBRC NE 0.                  "40B_CCC
*     Keine Währung ermittelbar                                "40B_CCC
      LD_FEHLER = 'X'.                 "40B_CCC
    ELSE.                              "40B_CCC
      DATA abgr_nicht_aktiv.                                    "442400
      CLEAR abgr_nicht_aktiv.                                   "442400
* Beginning insertion note 363527:
*     Abgrenzungsdaten vorhanden?
      CALL FUNCTION 'STATUS_CHECK'
         EXPORTING
              OBJNR             = PS_AUFTRAG-OBJNR
              STATUS            = LC_ABGR
         EXCEPTIONS
              OTHERS            = 1.
      IF SY-SUBRC <> 0.
         abgr_nicht_aktiv = 'X'.                                "442400
* Lines deleted note 442400.
      ENDIF.
* End note 363527
      IF PD_WAEHR EQ PD_KRKWAEHR.      "40B_CCC
*       Lesen des KoReKrs-Waehrungs-Felds ausreichend          "40B_CCC
        CLEAR LD_OBJ_CURR_READ.        "40B_CCC
      ELSE.                            "40B_CCC
*       KoReKrs-Waehrungs-Feld enthält andere Währung          "40B_CCC
        CALL FUNCTION 'STATUS_CHECK'   "40B_CCC
           EXPORTING                   "40B_CCC
                OBJNR             = PS_AUFTRAG-OBJNR           "40B_CCC
                STATUS            = LC_KABO                    "40B_CCC
           EXCEPTIONS                  "40B_CCC
                OTHERS            = 1. "40B_CCC
        IF SY-SUBRC EQ 0 OR abgr_nicht_aktiv = 'X'.            "M442400
*         Objektwährung enthält Bukrs-Waehrung                 "40B_CCC
          LD_OBJ_CURR_READ = 'X'.      "40B_CCC
        ELSE.                          "40B_CCC
*         Objektwähr.-Feld nicht gefüllt => Fehlende BukrsWähr "40B_CCC
          LD_FEHLER = 'X'.             "40B_CCC
        ENDIF.                         "40B_CCC
      ENDIF.                           "40B_CCC
    ENDIF.                             "40B_CCC
  ENDIF.                               "40B_CCC
  IF LD_FEHLER IS INITIAL.             "40B_CCC
    ABGR_PERIOD-M = PD_ABGRMONA.
    ABGR_PERIOD-J = PD_ABGRJAHR.
    CALL FUNCTION 'KKA_ABGR_LESEN_SUMMENSAETZE'
         EXPORTING
              KOKRS    = KOKRS
              OBJNR    = PS_AUFTRAG-OBJNR
*             VERSN    = ABGR_VSN-VERSA                        "H980404
              VERSN    = PD_ABGRVERS                           "H980404
              GJAHR    = PD_ABGRJAHR
              PERIODE  = PD_ABGRMONA
         TABLES
              TKKAABGR = TKKAABGR.

    WIP_WRTK = WIP_WRT = 0.
    LOOP AT TKKAABGR.
      IF TKKAABGR-ABKAT EQ ABKAT_BST_KOS_AP OR
         TKKAABGR-ABKAT EQ ABKAT_BST_KOS_AW OR
         TKKAABGR-ABKAT EQ ABKAT_BST_KOS_NF OR
         TKKAABGR-ABKAT EQ ABKAT_RUE_KOS_AP OR
         TKKAABGR-ABKAT EQ ABKAT_RUE_KOS_AW OR
         TKKAABGR-ABKAT EQ ABKAT_RUE_KOS_NF.
        IF LD_OBJ_CURR_READ IS INITIAL."40B_CCC
          SUBTRACT: TKKAABGR-WRTK FROM WIP_WRTK,
                    TKKAABGR-WRT FROM WIP_WRT.
        ELSE.                          "40B_CCC
          SUBTRACT: TKKAABGR-OWRTK FROM WIP_WRTK,              "40B_CCC
                    TKKAABGR-OWRT FROM WIP_WRT.                "40B_CCC
        ENDIF.                         "40B_CCC
      ENDIF.
    ENDLOOP.
    PD_AMPEL = CON_GRUEN.              "40B_CCC
    PS_AUFTRAG-WRTK    = WIP_WRTK.
    PS_AUFTRAG-WRT     = WIP_WRT.
    CLEAR PS_AUFTRAG-WRT_UPD.
  ELSE.                                "40B_CCC
*   Falls Fehler (bei fehlendem Bukrs-Wert mögl.) Ampel rot    "40B_CCC
    PERFORM FEHLERZEILE USING PD_FEHLERAUFTRAG
*                             pd_ampel                           "D_40C
                              PS_AUFTRAG-WRT
                              PS_AUFTRAG-WRTK
                              PS_AUFTRAG-WRT_UPD.
    IF PD_FEHLERAUFTRAG EQ 'X'.  "auch Ampeln bei Anzeigen         "40C
      PD_AMPEL = CON_ROT.                                   "40C
    ENDIF.                                                  "40C
    MESSAGE S808(KJ) WITH PS_AUFTRAG-AUFNR PD_WAEHR.           "40B_CCC
  ENDIF.                               "40B_CCC
ENDFORM.                               "abgr_daten_lesen_und_listen.

*eject
************************************************************************
* FORM um WIP-Daten neu zu errechnen
************************************************************************
FORM ABGR_DATEN_HOLEN_UND_LISTEN
   USING PS_AUFTRAG  LIKE KKAPARA_TA                        "40A
         PD_ABGRMONA LIKE KKAPARA_IN-ABGRMONA               "40A
         PD_ABGRJAHR LIKE KKAPARA_IN-ABGRJAHR               "40A
         PD_WAEHR    LIKE KKAPARA_IN-WAEHR.                 "40A
*         pd_ampel    like kka0100-ampel.    "ab 4.0B nicht genutzt "40C

  TABLES: KKAH2000, KKA2000.
  DATA  BEGIN OF TKKA2000 OCCURS 1.
          INCLUDE STRUCTURE KKA2000.
  DATA  END OF TKKA2000.
  DATA  BEGIN OF TACOBK OCCURS 1.
          INCLUDE STRUCTURE COBK.
  DATA  END OF TACOBK.
  DATA  BEGIN OF TACOEPB OCCURS 1.
          INCLUDE STRUCTURE COEPB.
  DATA  END OF TACOEPB.

  DATA: WIP_WRT LIKE TKKA2000-WRT,
        WIP_WRTK LIKE TKKA2000-WRT,
        WIP_WRT_UPD LIKE TKKA2000-WRT.

  REFRESH TKKA2000.
  KKAH2000-C_PERIOD_M = PD_ABGRMONA.
  KKAH2000-C_PERIOD_J = PD_ABGRJAHR.
  CALL FUNCTION 'KKA_ABGR_GET_DY2000'
       EXPORTING
            IKKAH2000 = KKAH2000
            i_no_change = 'X'                                  "417248
       IMPORTING
            OKKAH2000 = KKAH2000
       TABLES
            TKKA2000  = TKKA2000.

  PD_WAEHR = KKAH2000-TWAER.   "zugehörige Währung (zuletzt gerechnete)

  CALL FUNCTION 'KKA_ABGR_HOLE_EINZELPOSTEN'
       TABLES
            ACOBK  = TACOBK
            ACOEPB = TACOEPB.

  WIP_WRTK = WIP_WRT = WIP_WRT_UPD = 0.
  LOOP AT TKKA2000.
    IF TKKA2000-ABKAT EQ ABKAT_BST_KOS_AP OR
       TKKA2000-ABKAT EQ ABKAT_BST_KOS_AW OR
       TKKA2000-ABKAT EQ ABKAT_BST_KOS_NF OR
       TKKA2000-ABKAT EQ ABKAT_RUE_KOS_AP OR
       TKKA2000-ABKAT EQ ABKAT_RUE_KOS_AW OR
       TKKA2000-ABKAT EQ ABKAT_RUE_KOS_NF.
      SUBTRACT: TKKA2000-WRTK FROM WIP_WRTK,
                TKKA2000-WRT FROM WIP_WRT.
    ENDIF.
  ENDLOOP.
  LOOP AT TACOEPB WHERE PERIO EQ PD_ABGRMONA
                    AND GJAHR EQ PD_ABGRJAHR.
    IF TACOEPB-ABKAT EQ ABKAT_BST_KOS_AP OR
       TACOEPB-ABKAT EQ ABKAT_BST_KOS_AW OR
       TACOEPB-ABKAT EQ ABKAT_BST_KOS_NF OR
       TACOEPB-ABKAT EQ ABKAT_RUE_KOS_AP OR
       TACOEPB-ABKAT EQ ABKAT_RUE_KOS_AW OR
       TACOEPB-ABKAT EQ ABKAT_RUE_KOS_NF.
      SUBTRACT TACOEPB-WKGBTR FROM WIP_WRT_UPD.
    ENDIF.
  ENDLOOP.

* Zusätzliche Warning, wenn WIP-Veränderung 0 und vormals WIP > 0
* Dann ist nämlich Abrechnung an FiBu nötig zur Auflösung des WIP
  IF WIP_WRT EQ 0 AND WIP_WRT_UPD NE 0.
    CALL FUNCTION 'CM_F_MESSAGE'
       EXPORTING ARBGB                 = 'KJ'
                 MSGNR                 = '505'
                 MSGTY                 = 'W'
                 MSGV1                 = PS_AUFTRAG-AUFNR
                 MSGV2                 = PD_ABGRMONA
                 MSGV3                 = PD_ABGRJAHR
                 MSGV4                 = SPACE
                 MSG_ON_SCREEN         = NO
*                object_dependent      = no  "-> später YES "P30K047201
                 OBJECT_DEPENDENT      = YES                "P30K047201
                 APPEND_SAME_MSG       = YES.
  ENDIF.

* Statt perform datenzeile (ab 4.0B)
  PS_AUFTRAG-WRTK    = WIP_WRTK.
  PS_AUFTRAG-WRT     = WIP_WRT.
  PS_AUFTRAG-WRT_UPD = WIP_WRT_UPD.

ENDFORM.

***********************************************************************
* Form-Routine zur mögl. Ausgabe einer Zeile mit fehlerhaftem Auftrag
***********************************************************************
FORM FEHLERZEILE USING PD_FEHLERAUFTRAG TYPE C
*                      pd_ampel         like kka0100-ampel       "D_40C
                       PD_AUFT_WIPK     LIKE KKA2000-WRT
                       PD_AUFT_WIPP     LIKE KKA2000-WRT
                       PD_AUFT_WIPB     LIKE KKA2000-WRT.

*    pd_ampel         = con_rot. "außerhalb gesetzt              "D_40C
  PD_FEHLERAUFTRAG = 'X'.
  CLEAR: PD_AUFT_WIPK, PD_AUFT_WIPP, PD_AUFT_WIPB.
ENDFORM.                               "fehlerzeile
************************************************************************
*
************************************************************************
FORM BERECHTIGUNG_PRUEFEN USING ACT VRG.
  CALL FUNCTION 'K_VRGNG_AUTHORITY_CHECK'
       EXPORTING
            ACTVT = ACT
            KOKRS = KOKRS
            VRGNG = VRG.
*                VRGNG_TEXT = ' '
*      EXCEPTIONS USER_NOT_AUTHORIZED = 01
*                 SYSTEM_ERROR = 02.
ENDFORM.

*
* Die folgenden Formroutinen werden nicht mehr benötigt ab 4.6A
*

FORM OLD_PEP_OPEN.
* 4.0C BEGIN: PEP angeschlossen
  IF ANZEIGEN EQ YES.
    GD_PEP_ACTIVITY = '03'.
  ELSE.
    GD_PEP_ACTIVITY = '16'.
  ENDIF.
  IF SIMULATI EQ YES.
    GD_PEP_TEST = 'X'.
  ELSE.
    CLEAR GD_PEP_TEST.
  ENDIF.
  GD_PEP_TCODE = SY-TCODE.
  GD_PEP_REPID = SY-REPID.
  SELECT SINGLE CVACT LMONA INTO (GD_CVACT, GD_PEP_GJVAR)    "I_40C_PEP
       FROM  TKA01                     "I_40C_PEP
          WHERE  KOKRS  =  KOKRS.      "I_40C_PEP
* call function 'G_POSTING_DATE_OF_PERIOD_GET'
*      exporting
*           period              = abgrmona
*           variant             = gd_pep_gjvar
*           year                = abgrjahr
*      importing
*           FROM_DATE           =
*           LAST_NORMAL_PERIOD  =
*           to_date             = gd_pep_budat
*           FROM_DATE_ORIG      =
*      exceptions
*           others              = 1.
  CLEAR: GS_PEP_ORG, GS_PEP_HIERARCHY.
  GS_PEP_ORG-KOKRS = KOKRS.
  GS_PEP_ORG-WERKS = ABGRWERK-LOW.
  GS_PEP_ORG-LMONA = GD_PEP_GJVAR.
  GS_PEP_HIERARCHY-GJAHR = GS_PEP_HIERARCHY-GJAHR_BIS = ABGRJAHR.
  GS_PEP_HIERARCHY-FROM_P = GS_PEP_HIERARCHY-TO_P = ABGRMONA. "???
*  Eigentlich bei 'T' alle gerechneten Perioden angeben!
  GS_PEP_HIERARCHY-VERSN = ABGRVERS-LOW.
* gs_pep_hierarchy-budat = gd_pep_budat. "durch K_MONITOR germittelt
* Füllen der Selektionskriterien-Tabelle
  CLEAR GT_PEP_SEL.
*
  GT_PEP_SEL-STRUCTURE = 'KKA0100'.
  GT_PEP_SEL-FIELD     = 'KOKRS'.
  GT_PEP_SEL-LOW       = KOKRS.
  GT_PEP_SEL-OPTIO     = 'EQ'.
  GT_PEP_SEL-SIGN      = 'I'.
  APPEND GT_PEP_SEL.
*
  GT_PEP_SEL-STRUCTURE = 'KKAPARA_TA'.
  GT_PEP_SEL-FIELD     = 'WERKS'.
  GT_PEP_SEL-LOW       = ABGRWERK-LOW.
  GT_PEP_SEL-OPTIO     = ABGRWERK-OPTION.
  GT_PEP_SEL-SIGN      = ABGRWERK-SIGN.
  GT_PEP_SEL-HIGH      = ABGRWERK-HIGH.
  APPEND GT_PEP_SEL.
*
  GT_PEP_SEL-STRUCTURE = 'KKA0100'.
  GT_PEP_SEL-FIELD     = 'AUFNR'.
  GT_PEP_SEL-LOW       = ABGRAUFN-LOW.
  GT_PEP_SEL-OPTIO     = ABGRAUFN-OPTION.
  GT_PEP_SEL-SIGN      = ABGRAUFN-SIGN.
  GT_PEP_SEL-HIGH      = ABGRAUFN-HIGH.
  APPEND GT_PEP_SEL.
*
  GT_PEP_SEL-FIELD     = 'IFAUF'.
  GT_PEP_SEL-LOW       = INCFAUFT.
  CLEAR GT_PEP_SEL-HIGH.
  GT_PEP_SEL-OPTIO     = 'EQ'.
  GT_PEP_SEL-SIGN      = 'I'.
  APPEND GT_PEP_SEL.
*
  GT_PEP_SEL-FIELD     = 'IKOSA'.
  GT_PEP_SEL-LOW       = INCPKOSA.
  CLEAR GT_PEP_SEL-HIGH.
  GT_PEP_SEL-OPTIO     = 'EQ'.
  GT_PEP_SEL-SIGN      = 'I'.
  APPEND GT_PEP_SEL.
*
  GT_PEP_SEL-FIELD     = 'IPAUF'.
  GT_PEP_SEL-LOW       = INCPIAUF.
  CLEAR GT_PEP_SEL-HIGH.
  GT_PEP_SEL-OPTIO     = 'EQ'.
  GT_PEP_SEL-SIGN      = 'I'.
  APPEND GT_PEP_SEL.

  CALL FUNCTION 'K_MONITOR_RECORD_OPEN'
       EXPORTING
            I_SELID           = 'OR3'  "aus Einstiegsbild ermitteln
            I_FUNCTION        = 'KABG'
            I_ACTIVITY        = GD_PEP_ACTIVITY
            I_REPID           = GD_PEP_REPID
*           I_VARIANT         =
            I_TCODE           = GD_PEP_TCODE
            I_TEST            = GD_PEP_TEST
            I_PFFLD_ORG       = GS_PEP_ORG
            I_PFFLD_HIERARCHY = GS_PEP_HIERARCHY
*           i_pfswp           =  KEIN WORKFLOW genutzt
       IMPORTING
            E_PFLID           = GD_PEP_ID
       TABLES
            T_PFSEL           = GT_PEP_SEL
            T_PFPAR           = GT_PEP_PAR.
  COMMIT WORK.
* 4.0C END: PEP angeschlossen
ENDFORM.


*---------------------------------------------------------------------*
*       FORM old_pep_close                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM OLD_PEP_CLOSE.

* 4.0C BEGIN: PEP-Close
* Hier Logik noch verbessern: 2, falls maximal W-Meldungen ->CM_F_READ!
  IF ABGR_OBJ_NOT_DONE EQ 0.
    GD_PEP_APLSTAT = '0'.
  ELSE.
    GD_PEP_APLSTAT = '4'.
  ENDIF.
  IF NOT ABGR_MSG_STORE_NR IS INITIAL.
    GS_PEP_MSGP-NR        = ABGR_MSG_STORE_NR.
    GS_PEP_MSGP-OBJECT_ID = ABGR_OBJECT_ID.
    GS_PEP_MSGP-APLID     = ABGR_APLID.
  ENDIF.
  IF     NOT GD_SUBOBJEKT IS INITIAL
     AND NOT GD_EXTNUMBER IS INITIAL.
    GS_PEP_ALOG-OBJECT    = 'COAC'.
    GS_PEP_ALOG-SUBOBJECT = GD_SUBOBJEKT.
    GS_PEP_ALOG-EXTNUMBER = GD_EXTNUMBER.
*   Achtung: Wegen fehlender Eindeutigkeit der ExtNumber wuerden mehr
*   angezeigt->timestamp mit rein!
  ENDIF.
  CALL FUNCTION 'K_MONITOR_RECORD_CLOSE'
       EXPORTING
            I_PFLID   = GD_PEP_ID
            I_APLSTAT = GD_PEP_APLSTAT
            I_OBJECTS = ABGR_OBJ_TOTAL
            I_PFMSG   = GS_PEP_MSGP.
*           i_pfact     = gs_pep_alog."nicht unterstützt wg. Dynp-Probl.
*           I_PFALV     =
*       exceptions
*            wrong_pflid = 1
*            others      = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
* 4.0C END: PEP-Close

ENDFORM.
* beginning note 173985:
FORM LIES_MENGEN
  USING
    PS_PARAMS TYPE KKAPARA_IN
  CHANGING
    PS_AUFTRAG TYPE KKAPARA_TA.

  DATA:
    SELTAB TYPE COSEL OCCURS 10 WITH HEADER LINE,
    T_COSLA TYPE COSLA OCCURS 2 WITH HEADER LINE,
    LETZTE_PERIODE LIKE ABGRMONA,
    MENGE LIKE T_COSLA-LST001.

* Selektionstabelle für COSLA aufbauen:
  SELTAB-SIGN = 'I'.
  SELTAB-OPTION = 'EQ'.

  SELTAB-FIELD = 'LEDNR'.
  SELTAB-LOW = '00'.
  APPEND SELTAB.

  SELTAB-FIELD = 'OBJNR'.
  IF NOT PS_AUFTRAG-OBJNP IS INITIAL.
    SELTAB-LOW = PS_AUFTRAG-OBJNP.
  ELSE.
    SELTAB-LOW = PS_AUFTRAG-OBJNR.
  ENDIF.
  APPEND SELTAB.

  SELTAB-FIELD = 'WRTTP'.
  SELTAB-LOW = '01'.
  APPEND SELTAB.
  SELTAB-LOW = '04'.
  APPEND SELTAB.

  SELTAB-FIELD = 'VERSN'.
  SELTAB-LOW = '000'.
  APPEND SELTAB.

  SELTAB-FIELD = 'GJAHR'.
  SELTAB-OPTION = 'LE'.
  SELTAB-LOW = PS_PARAMS-ABGRJAHR.
  APPEND SELTAB.

* COSLA lesen
  CALL FUNCTION 'K_COSLA_READ_MULTI'
       EXPORTING
            MODUS       = 1
       TABLES
            T_COSEL     = SELTAB
            T_COSLA     = T_COSLA.

* COSLA auswerten
  CLEAR: PS_AUFTRAG-PSMNG, PS_AUFTRAG-WEMNG, PS_AUFTRAG-AMEIN.

  CATCH SYSTEM-EXCEPTIONS ARITHMETIC_ERRORS = 1.
  LOOP AT T_COSLA.
    IF T_COSLA-GJAHR = PS_PARAMS-ABGRJAHR.
      LETZTE_PERIODE = PS_PARAMS-ABGRMONA.
    ELSE.
      LETZTE_PERIODE = 16.
    ENDIF.
    ADD T_COSLA-LST001 FROM 1 TO LETZTE_PERIODE GIVING MENGE.
    IF T_COSLA-WRTTP = '01'.
      "geplante Liefermenge
      ADD MENGE TO PS_AUFTRAG-PSMNG.
    ELSE.
      "Liefermenge
      ADD MENGE TO PS_AUFTRAG-WEMNG.
    ENDIF.
    IF PS_AUFTRAG-AMEIN IS INITIAL.
      PS_AUFTRAG-AMEIN = T_COSLA-MEINH.
    ELSEIF PS_AUFTRAG-AMEIN <> T_COSLA-MEINH.
      "Mengeneinheit unterschiedlich für Plan/Ist bzw. Geschäftsjahr
      IF PS_PARAMS-WITHIMSG = YES.
        PERFORM HANDLE_MESSAGE
          USING
            PS_AUFTRAG
            'KJ' 'I' 818 SPACE SPACE SPACE SPACE.
      ENDIF.
    ENDIF.
  ENDLOOP.
  ENDCATCH.
  IF SY-SUBRC = 1.
* Überlauf aufgetreten
    IF PS_PARAMS-WITHIMSG = YES.
      PERFORM HANDLE_MESSAGE
        USING
          PS_AUFTRAG
          'KJ' 'I' 819 SPACE SPACE SPACE SPACE.
    ENDIF.
    CLEAR: PS_AUFTRAG-PSMNG, PS_AUFTRAG-WEMNG, PS_AUFTRAG-AMEIN.
  ENDIF.
ENDFORM.
* end note 173985

* begin if note 722130                                          "H722130
form get_status using objnr like aufk-objnr                     "H722130
                      status_text like KKAPARA_TA-STATTEXT.     "H722130
  CLEAR status_text.
  DATA:
      DAT LIKE SY-DATUM,
      XDAT LIKE SY-DATUM,
      J LIKE T009B-BDATJ,
      M LIKE T009B-POPER.
  M = abgrmona.
  J = abgrjahr.
  CALL FUNCTION 'G_POSTING_DATE_OF_PERIOD_GET'
                     EXPORTING PERIOD = M
                               VARIANT = GD_PEP_GJVAR
                               YEAR = J
                     IMPORTING FROM_DATE = XDAT
                               TO_DATE = DAT
                     EXCEPTIONS OTHERS = 01.
  check sy-subrc = 0.

  data:
    GLFT_OR_TABG,
    GLFT,
    tabg,
    LD_ISTAT LIKE TJ02T-ISTAT.
  CALL FUNCTION 'KKA_CO_STATUS_OF_ORDER'
             EXPORTING OBJNR = OBJNR
                       DATE = DAT
             IMPORTING TECH_COMPL_OR_DELIV = GLFT_OR_TABG
                       DELIV = GLFT
                       TECH_COMPL = TABG
             EXCEPTIONS ERROR_OCCURED = 1
                        OTHERS = 2.
  check sy-subrc = 0.
  if tabg eq yes.
    LD_ISTAT = 'I0045'.   "TABG
  elseif glft eq yes.
    LD_ISTAT = 'I0012'.   "GLFT
  else.
    LD_ISTAT = 'I0002'.   "FREI
  endif.
  CALL FUNCTION 'STATUS_NUMBER_CONVERSION'
             EXPORTING
                  LANGUAGE           = SY-LANGU
                  STATUS_NUMBER      = LD_ISTAT
             IMPORTING
                  TXT04              = status_text
             EXCEPTIONS
                  INSUFFICIENT_INPUT = 1
                  OBJECT_NOT_FOUND   = 2
                  STATUS_NOT_FOUND   = 3
                  STSMA_NOT_FOUND    = 4
                  OTHERS             = 5.
  if sy-subrc ne 0.
    CLEAR status_text.
  ENDIF.
endform.

form get_bewart using abgsl like KKAPARA_TA-abgsl               "H722130
                      versn like KKAPARA_TA-versn               "H722130
                      bewer like KKAPARA_TA-bewer.              "H722130
  tables tkkas.
  clear bewer.
  select single abart into (tkkas-abart)
         from tkkas where kokrs = kokrs
                      and versa = versn
                      and abgsl = abgsl
                      and STSMA = space
                      and istat = 'I0002'.   "FREI
  check sy-subrc = 0.
  CASE TKKAS-ABART.
    WHEN 'F'.
*     Bewertung zu Istkosten
      BEWER = TEXT-WII.
    WHEN 'S'.
*     Bewertung zu Sollkosten
      BEWER = TEXT-WIS.
  ENDCASE.
endform.
* end of note 722130                                            "H722130

INCLUDE KKA07F02.

INCLUDE KKA07F04.

INCLUDE KKA07F03.