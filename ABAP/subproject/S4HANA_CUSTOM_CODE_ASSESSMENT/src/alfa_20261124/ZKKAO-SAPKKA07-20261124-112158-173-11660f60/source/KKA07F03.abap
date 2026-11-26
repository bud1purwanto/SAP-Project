*-------------------------------------------------------------------
***INCLUDE KKA07F03 .
*-------------------------------------------------------------------
* Include neu zu 4.0 (Listaufbau ausgelagert zwecks mögl. Modifikationen
* Änderungen gegenüber 3.1:
* 40A1: Vers, Werk nur bei mehreren AbgrVersionen, Werken in Liste
* Änderungen ab 4.0:

*-------------------------------------------------------------------
TYPE-POOLS: KKBLO.  "Type-Pool des Listtools
*&---------------------------------------------------------------------*
*&      Form  DEFINIERE_LISTE
*&---------------------------------------------------------------------*
* - Setzen der allgemeinen Layout-Informationen
* - Aufbau des Feldkatalogs mit Feldbeschreibungen für die ALV-Liste
* - Definition der nicht in Selektions-Info anzuzeigenden Felder
* - Definition der Sortierfelder
*----------------------------------------------------------------------*
FORM DEFINIERE_LISTE
*  tables pt_fieldcat type kkblo_t_fieldcat   "Tabelle für Feldkatalog
  TABLES PT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV "Tabelle für Feldkatalog
*         pt_sort     type kkblo_t_sortinfo   "Zwischensummen und Sort.
         PT_SORT     TYPE SLIS_T_SORTINFO_ALV "Zwischensummen und Sort.
*  using  ps_layout   type kkblo_layout       "Struktur für List-FB
  USING  PS_LAYOUT   TYPE SLIS_LAYOUT_ALV     "Struktur für List-FB
*         ps_hide     type kkblo_sel_hide     "Tab. für keine Sel.-Info
         PS_HIDE     TYPE SLIS_SEL_HIDE_ALV   "Tab. für keine Sel.-Info
         PD_1WERK    TYPE C
         PD_1AUFA    TYPE C
         PD_1VERS    TYPE C
         PD_RST      TYPE C                                        "40C
         PD_ANZEIGEN LIKE KKAPARA_IN-ANZEIGEN
*         p_a_info    like kka0100-ainfo                          "D40C
         PD_MAXNTA   LIKE KKAPARA_IN-P_MAXNTA.

*data: ls_field type kkblo_fieldcat. "Kopfzeile zum Feldkatalog
  DATA: LS_FIELD TYPE SLIS_FIELDCAT_ALV. "Kopfzeile zum Feldkatalog
*data: ls_hide_entry type kkblo_selentry_hide."Struk. f. Überg. S-Felder
  DATA: LS_HIDE_ENTRY TYPE SLIS_SELENTRY_HIDE_ALV."Struk. f. Überg. S-F.
*data: lt_hide_entry type kkblo_t_selentry_hide. "Tab für hide-Felder
  DATA: LT_HIDE_ENTRY TYPE SLIS_T_SELENTRY_HIDE_ALV."Tab für hide-Felder
*data: ls_sort type kkblo_sortinfo.   "Zwischensummen und Sort. (Kopfz.)
 DATA: LS_SORT TYPE SLIS_SORTINFO_ALV."Zwischensummen und Sort. (Kopfz.)

* Sonstige Variablen
  DATA: LD_AMPEL_AN    TYPE C,  "Ampel an oder nicht
        LD_POSCOUNT(2) TYPE N.  "zum Position hochzählen
*    ld_notshowafpo    like ls_field-no_out. "AFPO-Zeilen in Liste ausg.

* Initialisierungen
* Ampeln jetzt auch für Anzeige-TA                           "*_40B_CCC
  LD_AMPEL_AN = 'X'.                                        "I_40B_CCC
* if pd_anzeigen is initial.                                 "D_40B_CCC
*   ld_ampel_an = 'X'.                                       "D_40B_CCC
* else.                                                      "D_40B_CCC
*   clear ld_ampel_an.                                       "D_40B_CCC
* endif.                                                     "D_40B_CCC
  CLEAR   PS_LAYOUT.
  REFRESH PT_FIELDCAT.
  REFRESH LT_HIDE_ENTRY.
  CLEAR   LS_HIDE_ENTRY.
  LS_HIDE_ENTRY-MODE    = 'D'.
  REFRESH PT_SORT.

* Layout-Info setzen
  PS_LAYOUT-REPREP           = 'X'.
  IF NOT LD_AMPEL_AN IS INITIAL.
    PS_LAYOUT-LIGHTS_FIELDNAME = 'AMPEL'.
    PS_LAYOUT-LIGHTS_ROLLNAME = 'KKA_AMPEL'.
  ENDIF. "ld_ampel_an
*  ps_layout-s_variant-report = sy-repid.                       "FSJB?
*  ps_layout-save = 'A'.                                        "FSJB?
  PS_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  PS_LAYOUT-LIGHTS_CONDENSE = 'X'.
  PS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  PS_LAYOUT-GROUP_CHANGE_EDIT = 'X'.
  PS_LAYOUT-GET_SELINFOS = 'X'. "Sel.infos unterstützt          "I45A
  ps_layout-f2code = 'PROTO'.                                   "46B

  IF PD_1VERS IS INITIAL.
*   Bei mehreren Versionen dürfen deren Werte nicht summiert werden
    PS_LAYOUT-NO_TOTALLINE = 'X'.
  ENDIF.

* Aufbau des Feldkatalogs mit Feldbeschreibungen für die ALV-Liste
* Werk des Auftrags (falls mehr als ein Werk)
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'WERKS'.
  LS_FIELD-REF_FIELDNAME = 'WERKS'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-NO_SUM        = 'X'.
  if g_auth_plant_missing is initial.                    "HW550211
    LS_FIELD-NO_OUT        = 'X'.
  endif.                                                 "HW550211
  APPEND LS_FIELD TO PT_FIELDCAT.
  IF PD_1WERK IS INITIAL.                 "immer, aber nur in SORT"M40C
*   und Werk nicht in Selektions-Info ausgeben                    "40A1
    LS_HIDE_ENTRY-SELNAME = 'ABGRWERK'.                     "40A1
    APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.                  "40A1
  ENDIF.                                                    "40A1

*<<<<<<Start of note 550211>>>>>>>>>>>
* Ankreuzfeld 'keine Berechtigung/Werk'
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'NO_AUTH_PLANT'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-SELTEXT_L     = text-001.
  LS_FIELD-NO_SUM        = 'X'.
  if g_auth_plant_missing is initial.                    "HW550211
   LS_FIELD-NO_OUT        = 'X'."nur optional anschaltbar durch User
                               "bwz. vom Programm bei fehlender Berecht.
  endif.                                                 "HW550211


  APPEND LS_FIELD TO PT_FIELDCAT.
*<<<<<<End of note 550211>>>>>>>>>>>


* Auftragsart (falls mehr als ein Werk)
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'AUART'.
  LS_FIELD-REF_FIELDNAME = 'AUART'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-NO_OUT        = 'X'.
  APPEND LS_FIELD TO PT_FIELDCAT.
  IF PD_1AUFA IS INITIAL.                 "immer, aber nur in SORT"M40C
*   und Auftragsart nicht in Selektions-Info ausgeben             "40A1
    LS_HIDE_ENTRY-SELNAME = 'ABGRAUFA'.                     "40A1
    APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.                  "40A1
  ENDIF.                                                    "40A1
* Kostenträger: Objektart und Nummer (aus Objektnummer abgeleitet)
  CLEAR LS_FIELD.
  LS_FIELD-KEY           = 'X'.
  LS_FIELD-KEY_SEL       = 'X'.
  LS_FIELD-FIELDNAME     = 'OBJID'.
  LS_FIELD-REF_FIELDNAME = 'OBJID'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-DDICTXT       = 'M'.                             "I_46A
  LS_FIELD-NO_SUM        = 'X'.
  APPEND LS_FIELD TO PT_FIELDCAT.
* AbgrVers
  IF PD_1VERS IS INITIAL.                                   "40A1
* Nur bei mehr als einer AbgrVersion:                             "40A1
*   AbgrVersionen in Liste ausgeben                               "40A1
    CLEAR LS_FIELD.
    LS_FIELD-KEY           = 'X'.                           "40A1
    LS_FIELD-FIELDNAME     = 'VERSN'.
    LS_FIELD-REF_FIELDNAME = 'VERSA'.
    LS_FIELD-REF_TABNAME   = 'TKKAP'.
    LS_FIELD-DDICTXT       = 'S'.
    LS_FIELD-NO_SUM        = 'X'.
    APPEND LS_FIELD TO PT_FIELDCAT.
*   und AbgrVersion nicht in Selektions-Info ausgeben
    LS_HIDE_ENTRY-SELNAME = 'ABGRVERS'.
    APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.
    IF NOT GD_CVACT IS INITIAL.
      CLEAR LS_FIELD.
      LS_FIELD-FIELDNAME     = 'VALUTEXT'.
      LS_FIELD-ROLLNAME      = 'VALUTYP'.
      LS_FIELD-DDICTXT       = 'L'.
      LS_FIELD-OUTPUTLEN     = 8.
      LS_FIELD-REPREP        = 'X'.
      LS_FIELD-NO_SUM        = 'X'.
      APPEND LS_FIELD TO PT_FIELDCAT.
      CLEAR LS_FIELD.
      LS_FIELD-FIELDNAME     = 'VALUTYP'.
      LS_FIELD-REF_FIELDNAME = 'VALUTYP'.
      LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
      LS_FIELD-DDICTXT       = 'S'.
      LS_FIELD-OUTPUTLEN     = 1.
      LS_FIELD-NO_SUM        = 'X'.
      LS_FIELD-NO_OUT        = 'X'.   "nur optional anschaltbar
      APPEND LS_FIELD TO PT_FIELDCAT.
    ENDIF.
  ENDIF.

*<<<<<<Start of note 550211>>>>>>>>>>>
  if g_auth_valu_missing = 'X'.

    CLEAR LS_FIELD.
    LS_FIELD-FIELDNAME     = 'VALUTYP'.
    LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
    LS_FIELD-DDICTXT       = 'S'.
*    LS_FIELD-OUTPUTLEN     = 1.
    LS_FIELD-NO_SUM        = 'X'.
    LS_FIELD-lzero         = 'X'. "otherwise val.type 0 would not appear
    APPEND LS_FIELD TO PT_FIELDCAT.

  endif.
*<<<<<<End of note 550211>>>>>>>>>>>


*<<<<<<Start of note 550211>>>>>>>>>>>
* Ankreuzfeld 'keine Berechtigung/Bewertungssicht'
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'NO_AUTH_VALUTYP'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-SELTEXT_L     = text-002.
  LS_FIELD-NO_SUM        = 'X'.
  if g_auth_valu_missing is initial.                       "HW550211
   LS_FIELD-NO_OUT        = 'X'."nur optional anschaltbar durch User
                               "bwz. vom Programm bei fehlender Berecht.
  endif.                                                   "HW550211


  APPEND LS_FIELD TO PT_FIELDCAT.
*<<<<<<End of note 550211>>>>>>>>>>>

* Maximaler Nachrichtentyp des Auftrags (nur wenn Flag gesetzt)
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'MAXNT'.
  LS_FIELD-REF_FIELDNAME = 'MSGMX'.
  LS_FIELD-REF_TABNAME   = 'KKA0100'.
  LS_FIELD-OUTPUTLEN     = '3'.
  LS_FIELD-NO_SUM        = 'X'.
  IF PD_MAXNTA IS INITIAL.
*  Falls Flag nicht gesetzt ist, Feld in Liste verstecken
    LS_FIELD-TECH        = 'X'.
  ENDIF.
  APPEND LS_FIELD TO PT_FIELDCAT.

* Art der WIP-Bewertung
* IF PD_ANZEIGEN IS INITIAL.                                    "H722130
    CLEAR LS_FIELD.
    LS_FIELD-FIELDNAME     = 'BEWER'.
    LS_FIELD-REF_FIELDNAME = 'BEWER'.
    LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
    LS_FIELD-OUTPUTLEN     = 2.
    LS_FIELD-NO_OUT        = 'X'.   "nur optional anschaltbar
    APPEND LS_FIELD TO PT_FIELDCAT.
* ENDIF.                                                        "H722130

* Währung
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'WAEHR'.
  LS_FIELD-REF_FIELDNAME = 'WAERS'.
  LS_FIELD-REF_TABNAME   = 'TKA01'.
  LS_FIELD-OUTPUTLEN     = 5.
  APPEND LS_FIELD TO PT_FIELDCAT.

* 5. WIP-Bestand
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'WRTK'.
  LS_FIELD-REF_FIELDNAME = 'WRTK'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-CFIELDNAME    = 'WAEHR'.
* ls_field-reptext       = text-wku.                         "FSJB?
  LS_FIELD-REPTEXT_DDIC  = TEXT-WKU.                         "FSJB?
* ls_field-seltext       = text-wku.                         "FSJB?
  LS_FIELD-DO_SUM        = 'X'.
  APPEND LS_FIELD TO PT_FIELDCAT.

* WIP-Bestandsveränderung
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'WRT'.
  LS_FIELD-REF_FIELDNAME = 'WRT'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-CFIELDNAME    = 'WAEHR'.
* ls_field-reptext       = text-wpe.                         "FSJB?
  LS_FIELD-REPTEXT_DDIC  = TEXT-WPE.                         "FSJB?
* ls_field-seltext       = text-wpe.                         "FSJB?
  LS_FIELD-DO_SUM        = 'X'.
  APPEND LS_FIELD TO PT_FIELDCAT.

* WIP/zu buchen
  IF PD_ANZEIGEN IS INITIAL.
*  Im Anzeige-Modus wird noch zu buchender WIP nicht ermittelt
    CLEAR LS_FIELD.
    LS_FIELD-FIELDNAME     = 'WRT_UPD'.
    LS_FIELD-REF_FIELDNAME = 'WRT_UPD'.
    LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
    LS_FIELD-CFIELDNAME    = 'WAEHR'.
*   ls_field-reptext       = text-wwb.                       "FSJB?
    LS_FIELD-REPTEXT_DDIC  = TEXT-WWB.                       "FSJB?
*   ls_field-seltext       = text-wwb.                       "FSJB?
    LS_FIELD-DO_SUM        = 'X'.
    LS_FIELD-NO_OUT        = 'X'. "Kann vom Benutzer angeschaltet werden
    APPEND LS_FIELD TO PT_FIELDCAT.
  ENDIF. "pd_anzeigen
* Auftragsnummer und Position nur noch als Zusatzfelder ausblendbar
* Auftragsnummer
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'AUFNR'.
  LS_FIELD-REF_FIELDNAME = 'AUFNR'.
  LS_FIELD-REF_TABNAME   = 'AUFK'.
  LS_FIELD-DDICTXT       = 'L'.
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-REPREP        = 'X'.
  LS_FIELD-NO_OUT        = 'X'.   "nur optional anschaltbar
  APPEND LS_FIELD TO PT_FIELDCAT.
* Auftragposition (bei Aufträgen mit Kuppelproduktion)
  IF GD_MLT_POS EQ 'X'. "At least one order with joint production
    CLEAR LS_FIELD.
    LS_FIELD-FIELDNAME     = 'POSNR'.
    LS_FIELD-REF_FIELDNAME = 'POSNR'.
    LS_FIELD-REF_TABNAME   = 'AFPO'.
    LS_FIELD-REPREP        = 'X'.
    LS_FIELD-OUTPUTLEN     = '5'.
    LS_FIELD-NO_SUM        = 'X'.
    LS_FIELD-NO_OUT        = 'X'.   "nur optional anschaltbar
    APPEND LS_FIELD TO PT_FIELDCAT.
  ENDIF.
* WIP-Typ (B/R)
  IF NOT PD_RST IS INITIAL.
    CLEAR LS_FIELD.
    LS_FIELD-FIELDNAME     = 'WIPTYP'.
    LS_FIELD-ROLLNAME      = 'KKA_WIPTYP'.
    LS_FIELD-NO_SUM        = 'X'.
    LS_FIELD-OUTPUTLEN     = '25'.
    LS_FIELD-NO_OUT        = 'X'. "Kann vom Benutzer angeschaltet werden
    APPEND LS_FIELD TO PT_FIELDCAT.
  ENDIF.
* Auftragstyp
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'AUTYP'.
  LS_FIELD-REF_FIELDNAME = 'AUTYP'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-NO_OUT        = 'X'. "Kann vom Benutzer angeschaltet werden
  APPEND LS_FIELD TO PT_FIELDCAT.

* Weitere Felder nur bei Flag 'Zusätzliche Auftragsinfos'
* if p_a_info is initial.
*   ld_notshowafpo = 'X'.   "no_out anschalten
* else.
*   clear ld_notshowafpo.
* endif.
* Abgrenzungsschlüssel (zu 4.0C neu)
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'ABGSL'.
  LS_FIELD-REF_FIELDNAME = 'ABGSL'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-NO_OUT        = 'X'.  "Kann vom Benutzer angeschaltet werden
*  ls_field-no_out        = ld_notshowafpo.
  APPEND LS_FIELD TO PT_FIELDCAT.
* Systemstatus (falls Text ermittelbar), kein AnwStatus!  (zu 4.0C neu)
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'STATTEXT'.
  LS_FIELD-REF_FIELDNAME = 'STATTEXT'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-NO_OUT        = 'X'.  "Kann vom Benutzer angeschaltet werden
  APPEND LS_FIELD TO PT_FIELDCAT.
* Zuschlagsschlüssel  (zu 4.0C neu)
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'ZSCHL'.
  LS_FIELD-REF_FIELDNAME = 'ZSCHL'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-NO_OUT        = 'X'.  "Kann vom Benutzer angeschaltet werden
  APPEND LS_FIELD TO PT_FIELDCAT.

** Serienauftragsnummer           Keine RELEVANZ ab 4.0C        "40C_PK
*  clear ls_field.                                              "40C_PK
* ls_field-fieldname     = 'SAFNR'.                             "40C_PK
* ls_field-ref_fieldname = 'SAFNR'.                             "40C_PK
* ls_field-ref_tabname   = 'KKAPARA_TA'.                        "40C_PK
* ls_field-no_sum        = 'X'.                                 "40C_PK
* append ls_field to pt_fieldcat.                               "40C_PK

* Materialnummer zu Auftrag
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'MATNR'.
  LS_FIELD-REF_FIELDNAME = 'MATNR'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-NO_SUM        = 'X'.
*  ls_field-no_out        = ld_notshowafpo.
  APPEND LS_FIELD TO PT_FIELDCAT.

* Beginning I_46A
* Materialkurztext
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'MAKTX'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-DDICTXT       = 'L'.
  ls_field-no_out        = 'X'.
  APPEND LS_FIELD TO PT_FIELDCAT.

* Profit-Center
  LS_FIELD-FIELDNAME     = 'PRCTR'.
  APPEND LS_FIELD TO PT_FIELDCAT.
* End I_46A

* Planungswerk für den Auftrag
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'PWERK'.
  LS_FIELD-REF_FIELDNAME = 'PWERK'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-NO_OUT        = 'X'.   "nur optional anschaltbar
  APPEND LS_FIELD TO PT_FIELDCAT.

** Fertigungsversion   (ab 4.0C irrelevant)
*  clear ls_field.
*  ls_field-fieldname     = 'VERID'.
*  ls_field-ref_fieldname = 'VERID'.
*  ls_field-ref_tabname   = 'KKAPARA_TA'.
*  ls_field-no_sum        = 'X'.
**  ls_field-no_out        = ld_notshowafpo.
*  append ls_field to pt_fieldcat.
* Fertigungsprozeß     (ab 4.0C neu)
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'PROCNR_TXT'.                    "M46C
  LS_FIELD-REF_FIELDNAME = 'PROCNR_TXT'.                    "M46C
  LS_FIELD-OUTPUTLEN     = 20.                                 "46C
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-NO_OUT        = 'X'.   "nur optional anschaltbar
  APPEND LS_FIELD TO PT_FIELDCAT.

* Auftragskurztext
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'KTEXT'.
  LS_FIELD-REF_FIELDNAME = 'KTEXT'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-DDICTXT       = 'L'.                             "I_46A
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-NO_OUT        = 'X'. "Kann vom Benutzer angeschaltet werden
  APPEND LS_FIELD TO PT_FIELDCAT.
* neu: Geplante Auftragsmenge
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'PSMNG'.
  LS_FIELD-OUTPUTLEN     = 7.
  LS_FIELD-REF_FIELDNAME = 'PSMNG'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-QFIELDNAME    = 'AMEIN'.
* ls_field-reptext       = text-pmg.                            "FSJB?
  LS_FIELD-REPTEXT_DDIC  = TEXT-PMG.                            "FSJB?
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-NO_OUT        = 'X'. "Kann vom Benutzer angeschaltet werden
  APPEND LS_FIELD TO PT_FIELDCAT.
* neu: Teilgelieferte Menge
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'WEMNG'.
  LS_FIELD-OUTPUTLEN     = 7.
  LS_FIELD-REF_FIELDNAME = 'WEMNG'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-QFIELDNAME    = 'AMEIN'.
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-NO_OUT        = 'X'. "Kann vom Benutzer angeschaltet werden
  APPEND LS_FIELD TO PT_FIELDCAT.
* neu: Mengeneinheit
  CLEAR LS_FIELD.
  LS_FIELD-FIELDNAME     = 'AMEIN'.
  LS_FIELD-REF_FIELDNAME = 'AMEIN'.
  LS_FIELD-REF_TABNAME   = 'KKAPARA_TA'.
  LS_FIELD-NO_SUM        = 'X'.
  LS_FIELD-NO_OUT        = 'X'. "Kann vom Benutzer angeschaltet werden
  APPEND LS_FIELD TO PT_FIELDCAT.
** für die Berichts-Berichts-Schnittstelle     Nach Vorne in Liste"M40C
*  clear ls_field.                                                "M40C
*  ls_field-fieldname     = 'VALUTYP'.                            "M40C
*  ls_field-ref_fieldname = 'VALUTYP'.                            "M40C
*  ls_field-ref_tabname   = 'TKKAP'.                              "M40C
*  ls_field-no_out        = 'X'.                                  "M40C
*  ls_field-reprep        = 'X'.                                  "M40C
*  append ls_field to pt_fieldcat.                                "M40C

* Definition der nicht in Selektions-Info anzuzeigenden Felder
*  zunächst Felder-Liste füllen
*   Parameter: fehlauft
  LS_HIDE_ENTRY-SELNAME = 'FEHLAUFT'.
  APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.
*   Parameter: storemsg
  LS_HIDE_ENTRY-SELNAME = 'STOREMSG'.
  APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.
*   Parameter: withimsg
  LS_HIDE_ENTRY-SELNAME = 'WITHIMSG'.
  APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.
*   Parameter: p_maxnta
  LS_HIDE_ENTRY-SELNAME = 'P_MAXNTA'.
  APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.
*   Parameter: parallel
  LS_HIDE_ENTRY-SELNAME = 'PARALLEL'.
  APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.
*   Parameter: abgraufn
  LS_HIDE_ENTRY-SELNAME = 'ABGRAUFN'.
  APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.
*   Parameter: von_per
  LS_HIDE_ENTRY-SELNAME = 'VON_PER'.
  APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.
*   Parameter: von_jahr
  LS_HIDE_ENTRY-SELNAME = 'VON_JAHR'.
  APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.
*   Parameter: bis_per
  LS_HIDE_ENTRY-SELNAME = 'BIS_PER'.
  APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.
*   Parameter: bis_jahr
  LS_HIDE_ENTRY-SELNAME = 'BIS_JAHR'.
  APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.
*   Parameter: Einzelbearbeitung                                  "I45A
  LS_HIDE_ENTRY-SELNAME = 'PAR_EINZ'.                       "I45A
  APPEND LS_HIDE_ENTRY TO LT_HIDE_ENTRY.                    "I45A
* weitere Parameter (Perio/Gjahr..) nicht benötigt, da Bericht kumuliert
*  Sel_hide-Parameter zusammenbauen
  CLEAR PS_HIDE.
  PS_HIDE-MODE      = 'C'.
  PS_HIDE-T_ENTRIES = LT_HIDE_ENTRY.

* Aufbau der int. Tabelle mit Sortierkriterien
  LD_POSCOUNT = '1'.
*  Abgrenzungsversion
  IF PD_1VERS IS INITIAL.
*   Bei mehreren Versionen als äußersten Sortierkrit. mit Zw.summe
    CLEAR LS_SORT.
    LS_SORT-SPOS               = LD_POSCOUNT.
    LS_SORT-FIELDNAME          = 'VERSN'.
    LS_SORT-UP                 = 'X'.
    LS_SORT-SUBTOT             = 'X'.
    APPEND LS_SORT TO PT_SORT.
    ADD 1 TO LD_POSCOUNT.
  ENDIF.
*  WIP-Typ (zur Trennung von Bestand und Rückstellungen)
  IF NOT PD_RST IS INITIAL.
    CLEAR LS_SORT.
    LS_SORT-SPOS               = LD_POSCOUNT.
    LS_SORT-FIELDNAME          = 'WIPTYP'.
    LS_SORT-UP                 = 'X'.
    LS_SORT-SUBTOT             = 'X'.
    APPEND LS_SORT TO PT_SORT.
    ADD 1 TO LD_POSCOUNT.
  ENDIF.
*  Werk
  IF PD_1WERK IS INITIAL.
    CLEAR LS_SORT.
    LS_SORT-SPOS               = LD_POSCOUNT.
    LS_SORT-FIELDNAME          = 'WERKS'.
    LS_SORT-UP                 = 'X'.
    LS_SORT-SUBTOT             = 'X'.
    IF NOT SY-BATCH IS INITIAL.
      LS_SORT-GROUP            = '*'.
    ENDIF.
    APPEND LS_SORT TO PT_SORT.
    ADD 1 TO LD_POSCOUNT.
  ENDIF.
*  Auftragsart
  IF PD_1AUFA IS INITIAL.
    CLEAR LS_SORT.
    LS_SORT-SPOS               = LD_POSCOUNT.
    LS_SORT-FIELDNAME          = 'AUART'.
    LS_SORT-UP                 = 'X'.
    LS_SORT-SUBTOT             = 'X'.
    IF NOT SY-BATCH IS INITIAL.
      LS_SORT-GROUP            = '*'.
    ENDIF.
    APPEND LS_SORT TO PT_SORT.
    ADD 1 TO LD_POSCOUNT.
  ENDIF.
*  Kostenträger: Objektart und Nummer (aus Objektnummer abgeleitet)
*  Auftragsnummer
  CLEAR LS_SORT.
  LS_SORT-SPOS               = LD_POSCOUNT.
  LS_SORT-FIELDNAME          = 'AUFNR'.
  LS_SORT-UP                 = 'X'.
  APPEND LS_SORT TO PT_SORT.
  ADD 1 TO LD_POSCOUNT.
* Auftragposition (bei Aufträgen mit Kuppelproduktion)
  IF GD_MLT_POS EQ 'X'. "At least one order with joint production
    CLEAR LS_SORT.
    LS_SORT-SPOS               = LD_POSCOUNT.
    LS_SORT-FIELDNAME          = 'POSNR'.
    LS_SORT-UP                 = 'X'.
    APPEND LS_SORT TO PT_SORT.
    ADD 1 TO LD_POSCOUNT.
  ENDIF.
ENDFORM.                    " SETZE_LISTFELDER
*&---------------------------------------------------------------------*
*&      Form  DEFINIERE_EVENTS
*&---------------------------------------------------------------------*
*     Setzt die Event-Tabelle
*----------------------------------------------------------------------*
*      -->PT_EVENTS
*----------------------------------------------------------------------*
FORM DEFINIERE_EVENTS
   TABLES   PT_EVENTS TYPE SLIS_T_EVENT.
*
*  call function 'REUSE_ALV_EVENTS_GET'
*      exporting
*           i_list_type     = 0
*      importing
*           et_events       = pt_events.
*  loop at pt_events.
*    if pt_events-name = 'USER_COMMAND'.
*      pt_events-form = 'USER_COMMAND_INLIST'.
*      modify pt_events.
*    endif.
*    if pt_events-name = 'TOP_OF_PAGE'.
*      pt_events-form = 'TOP_OF_PAGE_INLIST'.
*      modify pt_events.
*    endif.
*  endloop.
  PT_EVENTS-NAME = 'USER_COMMAND'.
  PT_EVENTS-FORM = 'USER_COMMAND_INLIST'.
  APPEND PT_EVENTS.

  if not sy-batch is initial.                               "543308
    pt_events-name = 'TOP_OF_PAGE'.                         "543308
*    PT_EVENTS-NAME = 'TOP_OF_LIST'.                        "543308
    PT_EVENTS-FORM = 'TOP_OF_PAGE_INLIST'.                  "543308
    APPEND PT_EVENTS.                                       "543308
  endif.                                                    "543308

ENDFORM.                    " DEFINIERE_EVENTS