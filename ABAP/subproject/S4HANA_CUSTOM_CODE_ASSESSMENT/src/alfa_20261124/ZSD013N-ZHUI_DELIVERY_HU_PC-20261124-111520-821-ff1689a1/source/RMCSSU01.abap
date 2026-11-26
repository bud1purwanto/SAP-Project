***INCLUDE RMCSSU01 .
* allgemeine Felddefinitionen für die Statistikfortschreibung

* Konstanten
CONSTANTS:
      con_supkz_neu     LIKE mcvbakb-supkz    VALUE '2',
      con_supkz_alt     LIKE mcvbakb-supkz    VALUE '1',
      con_supkz_add     LIKE mcvbakb-supkz    VALUE '2',
      con_supkz_del     LIKE mcvbakb-supkz    VALUE '1',
      con_supkz_unv     LIKE mcvbakb-supkz    VALUE ' ',
      con_supkz_alt_pos LIKE mcvbakb-supkz    VALUE '0',
      con_supkz_neu_pos LIKE mcvbakb-supkz    VALUE '2',
      con_supkz_alt_neg LIKE mcvbakb-supkz    VALUE '1',
      con_supkz_neu_neg LIKE mcvbakb-supkz    VALUE '3',
      con_supkz_neg(2)                        VALUE '13',
      con_supkz_pos(2)                        VALUE '20',
      con_supkz_alte(2)                       VALUE '01',
      con_supkz_neue(2)                       VALUE '23',
*----------------------------------------------------------------------
      con_modus_norm    LIKE mccontrol-modus  VALUE ' ',
      con_modus_new     LIKE mccontrol-modus  VALUE 'A',
      con_modus_sim     LIKE mccontrol-modus  VALUE 'B',
      con_modus_log     LIKE mccontrol-modus  VALUE 'C',
      CON_MODUS_EVAL    LIKE MCCONTROL-MODUS  VALUE 'V',
*     Neuaufbau PPIS Freigabeversionen
      con_modus_set     LIKE mccontrol-modus  VALUE 'D',
*     Neuaufbau für BW
      con_modus_newbw   LIKE mccontrol-modus  VALUE 'E',
*     Simulation für BW
      con_modus_simbw   LIKE mccontrol-modus  VALUE 'G',
      con_modus_bw(3)                         VALUE ' EG',

*     SAP Credit Management
      con_modus_cm(1)                         VALUE ' ',
      con_modus_cm_d(3)                       VALUE 'ABF',
*     Rebuit CM
      con_modus_newcm   LIKE mccontrol-modus  VALUE 'H',
*     Simulation CM
      con_modus_simcm   LIKE mccontrol-modus  VALUE 'I',

* Generic Broadcasting
      con_modus_gb(4)                         VALUE ' JKL',
      con_modus_gb_only(3)                    VALUE 'JKL',
*     Redo Broadcasting
      con_modus_newgb   LIKE mccontrol-modus  VALUE 'J',
*     Simulate Redo Broadcasting
      con_modus_newsgb  LIKE mccontrol-modus  VALUE 'K',
*     Simulate Broadcasting
      con_modus_simgb   LIKE mccontrol-modus  VALUE 'L',

*     Simulation für Neuaufbau (Liste, ohne Prüflogik)
      con_modus_sim_new LIKE mccontrol-modus  VALUE 'F',
      con_modus_pca     LIKE mccontrol-modus  VALUE '0',  "CO/PCA
      con_modus_pct     LIKE mccontrol-modus  VALUE '1',"CO/PCA-Test
      con_reason_prep   LIKE mclogging-reason VALUE '1',
      con_reason_ok     LIKE mclogging-reason VALUE '2',
      con_reason_not_ok LIKE mclogging-reason VALUE '4',
      con_speri_mon     LIKE tmc4-speri       VALUE 'M',
      con_speri_woc     LIKE tmc4-speri       VALUE 'W',
      con_speri_tag     LIKE tmc4-speri       VALUE 'T',
      con_speri_bup     LIKE tmc4-speri       VALUE 'P',
      xcon_bukrs_initial LIKE t001-bukrs      VALUE IS INITIAL,
      true                                    VALUE 'X',
      false                                   VALUE ' ',
      con_del_rejected(2)                     VALUE 'DL',
                                       "physisch oder logisch gelöscht
      con_rejected                            VALUE 'L', "log. gelöscht
      con_deleted                             VALUE 'D',
      con_inserted                            VALUE 'I',
      con_changed                             VALUE 'U',
      con_unchanged_delivery                  VALUE 'V',
      con_v1                                  VALUE '1', "Verbuchung V1
      con_v2                                  VALUE '2', "Verbuchung V2
      con_v3                                  VALUE '3', "Verbuchung V3
      con_d                                   VALUE 'D', "Dialog
      CON_BW_EX_11_INTERFACE_VERSION TYPE I
                                     VALUE 2, "ab PI-2002.1
      CON_BW_EX_12_INTERFACE_VERSION TYPE I
                                     VALUE 2, "ab PI-2002.1
      CON_BW_EX_13_INTERFACE_VERSION TYPE I
                                     VALUE 2, "ab PI-2002.1
      mcinf_update_form(15)                   VALUE 'UPDATE_FROM_INT',
      simulation(10)                          VALUE 'SIMULATION',
      con_voleh        LIKE t006-msehi        VALUE 'CDM',
      con_gewei        LIKE t006-msehi        VALUE 'KG',
      con_vrsio_ist    LIKE mcs0-vrsio        VALUE '000'.
* Variablen
DATA:
      BEGIN OF default_srout,
        fil(4)                 VALUE 'OUT_', "default für SIMULATION
        mcinf  LIKE tmc4-mcinf,
      END   OF default_srout,

      sav_subrc LIKE sy-subrc,
      sav_tabix LIKE sy-tabix,
      flg_suhie,
      flg_logging,
*     Flag für Logging
*        = TRUE : Logging angeschaltet
*        = FALSE: Logging ausgeschaltet
      flg_verbuchung,
* Flags für Verbuchungstyp
      flg_v1,
*     Flag für V1-Verbuchung
*        = TRUE : V1-Verbuchung erforderlich
*        = FALSE: V1-Verbuchung nicht erforderlich
      flg_v2,
*     Flag für V2-Verbuchung
*        = TRUE : V2-Verbuchung erforderlich
*        = FALSE: V2-Verbuchung nicht erforderlich
      flg_d,
*     Flag für Dialog
*        = TRUE : Dialog erforderlich
*        = FALSE: Dialog nicht erforderlich
      flg_b,
*     Flag für V3-Verbuchung
*        = true : V3-Verbuchung erforderlich
*        = false: V3-Verbuchung nicht erforderlich
      flg_bw,
*     Flag für BW-Verbuchung
*        = true : BW-Verbuchung erforderlich
*        = false: BW-Verbuchung nicht erforderlich
      flg_cm,
*     Flag für CM-update
*        = 'X' (true) : CM-Comitment update necessary
*        = 'Y' (true) : CM-Comitment update necessary (since ERP2005)
*        = ' ' (false): CM-Comitment update not necessary
      flg_gb.
*     Flag for Generic Broadcasting
*     Multicasting of Statistics Data (without use of info
*     structure); not including
*      - BW/BI update                       (flg_bw)
*      - SAP Credit Management update       (flg_cm)
*        = 'X' (true) : Broadcasting necessary
*        = ' ' (false): Broadcasting not necessary

* BADI_SD_TO_FM
DATA: INST_BADI_SD_TO_FM
        TYPE REF TO IF_EX_BADI_SD_TO_FM, "#EC NEEDED
       ACTIVE_BADI_SD_TO_FM TYPE XFELD.  "#EC NEEDED

* interne Tabellen
DATA: BEGIN OF prog_tab OCCURS 0,
        fprog LIKE tmc2f-fprog,
        mcinf LIKE tmc4-mcinf,     "  NOTE 376750
      END   OF prog_tab.