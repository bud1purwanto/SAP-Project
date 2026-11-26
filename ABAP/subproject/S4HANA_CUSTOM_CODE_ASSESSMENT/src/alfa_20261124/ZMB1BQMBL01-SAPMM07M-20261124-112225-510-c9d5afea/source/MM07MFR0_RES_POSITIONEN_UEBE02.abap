*eject
*---------------------------------------------------------------------*
*       FORM RES_POSITIONEN_UEBERNEHMEN_01                            *
*---------------------------------------------------------------------*
*       Die gefundenen Reservierungspositionen werden übernommen.     *
*---------------------------------------------------------------------*
FORM res_positionen_uebernehmen_01.
  DATA: ls_cobl_old LIKE cobl,                                  "1651459
        ls_cobl_new LIKE cobl.                                  "1651459

  MOVE-CORRESPONDING xrkpf TO mseg.
  CLEAR mseg-prctr.
  mseg-pprctr = xrkpf-prctr.
  CALL FUNCTION 'GRPG_PSPNR_SWITCH_IN_RBEFU'
    CHANGING
      c_rbefu = xrbefu.

  DATA: hsgtxt LIKE mseg-sgtxt.                             "861227
  IF NOT mseg-sgtxt IS INITIAL AND xbapi EQ 'X'.            "861227
    MOVE mseg-sgtxt TO hsgtxt.                              "861227
  ENDIF.                                                    "861227

  MOVE-CORRESPONDING xrbefu TO mseg.

  IF NOT hsgtxt IS INITIAL AND xbapi EQ 'X'.                "861227
    MOVE hsgtxt TO mseg-sgtxt.                              "861227
    CLEAR hsgtxt.                                           "861227
  ENDIF.                                                    "861227

* vor 4.6a gab es fipos, fistl, geber nur im Res.-Kopf, fuer "alte"
* Reservierungen:
  IF mseg-fipos IS INITIAL.
    mseg-fipos = xrkpf-fipos.
  ENDIF.
  IF mseg-fistl IS INITIAL.
    mseg-fistl = xrkpf-fistl.
  ENDIF.
  IF mseg-geber IS INITIAL.
    mseg-geber = xrkpf-geber.
* Budget Period EhP4
    IF cl_ops_switch_check=>ops_sfws_bud_per( ) IS NOT INITIAL.
      dm07m-budget_pd = xrkpf-budget_pd.
    ENDIF.
  ENDIF.
  IF mseg-grant_nbr IS INITIAL.
    mseg-grant_nbr = xrkpf-grant_nbr.
  ENDIF.
  IF mseg-fkber IS INITIAL.
    mseg-fkber = xrkpf-fkber.
  ENDIF.
  IF mseg-wempf IS INITIAL.
    mseg-wempf = rm07m-wempf_vor.
  ENDIF.
  IF mseg-sgtxt IS INITIAL.
    mseg-sgtxt = xrbefu-potx1.
  ENDIF.
  IF NOT bwart_res IS INITIAL.
    mseg-bwart = bwart_res.
    IF xrbefu-bwart NE xrkpf-bwart.
      SELECT SINGLE * FROM t156n WHERE fcode = fcausw-fcode
                                 AND  bwart  = xrbefu-bwart.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH '156N' xrbefu-bwart.
      ENDIF.
      mseg-bwart = t156n-bwart_next.
    ENDIF.
  ENDIF.
ENHANCEMENT-POINT res_positionen_uebernehmen_02 SPOTS es_sapmm07m.
  IF mseg-sobkz = q.
    mseg-mat_pspnr = xrbefu-ps_psp_pnr.
  ELSEIF mseg-sobkz = e.
    mseg-mat_kdauf = xrbefu-kdauf.
    mseg-mat_kdpos = xrbefu-kdpos.
  ENDIF.
  IF mseg-ps_psp_pnr IS INITIAL.
    mseg-ps_psp_pnr = xrkpf-ps_psp_pnr.
  ENDIF.
  IF NOT mseg-ps_psp_pnr IS INITIAL AND mseg-kzbws IS INITIAL.
*Implement the old logic provided in note 0105118.          "HW 513223
    IF mseg-sobkz NE q AND                                  "HW 513223
       mseg-sobkz NE e.                                     "HW 513223
      CLEAR mseg-nplnr.
    ENDIF.                                                  "HW 513223
  ENDIF.
  IF mseg-lgort IS INITIAL.
    mseg-lgort = rm07m-lgort.
  ENDIF.
  IF rm07m-werks IS INITIAL.
    rm07m-werks = mseg-werks.
  ENDIF.
* Netzplanvorgangskontierung behandeln.
  CALL FUNCTION 'CO_SF_MSEG_ACCOUNT_SETTLE'
    EXPORTING
      mseg_imp  = mseg
      rbefu_imp = xrbefu
    IMPORTING
      mseg_exp  = ymseg.
  MOVE-CORRESPONDING ymseg TO cobl.    "Daten filtern
* Check if the Enhancement Pack switch is on
  IF NOT cl_psm_core_switch_check=>psm_fm_core_gen( ) IS INITIAL.
    cobl-kblnr    = mseg-kblnr.
    cobl-kblpos   = mseg-kblpos.
  ENDIF.
  MOVE-CORRESPONDING cobl TO mseg.

* Derive profitability segment (PAOBJNR) for goods movement with"1651459
* reference to reservation                                      "1651459
* MB* : PAOBJNR is derived in subroutine RES_POSITIONEN_UEBERNEHMEN_01
*       (Include MM07MFR0_RES_POSITIONEN_UEBE02)
* MIGO: PAOBJNR is derived in method RESERVATION_GOITEM_FILL
*       (Include LMIGOKR2)
* BAPI: The correct PAOBJNR has to be filled in the import table
*       GOODSMVT_ITEM field PROFIT_SEGM_NO. NO new derivation.
  IF NOT mseg-paobjnr IS INITIAL AND XMBWL IS INITIAL.          "1651459
    SELECT COUNT(*) FROM resb WHERE rsnum = xrkpf-rsnum.        "1651459
*   The profitability segment number (PAOBJNR) is stored in the
*   reservation header table (RBKPF). The PAOBJNR can contain attributes
*   of items (e.g. material number) hence it should be derived on item
*   level to avoid inconsistent PAOBJNR in case the reservation contains
*   more than one item.
    IF sy-dbcnt > 1.                                            "1651459
      MOVE-CORRESPONDING mkpf  TO ls_cobl_old.                  "1651459
      MOVE-CORRESPONDING mseg  TO ls_cobl_old.                  "1651459
      ls_cobl_old-vorgn = rw_vorgang.                           "1651459
      ls_cobl_old-awtyp = rw_awtyp.                             "1651459
*     GJAHR is necessary in order to determine whether the profitability
*     analysis (TKA00-ERGBR) is active in fm K_KOKRS_READ
      CALL FUNCTION 'FI_PERIOD_DETERMINE'                       "1651459
        EXPORTING                                               "1651459
          i_budat              = mkpf-budat                     "1651459
          i_bukrs              = t001k-bukrs                    "1651459
        IMPORTING                                               "1651459
          e_gjahr              = ls_cobl_old-gjahr              "1651459
        EXCEPTIONS                                              "1651459
          OTHERS               = 1.                             "1651459
      IF sy-subrc = 0.                                          "1651459
*       Clear PAOBJNR in order to ensure that none of the old PAOBJNR
*       attributes are reused for the new PAOBJNR
        CLEAR: ls_cobl_old-paobjnr.                             "1651459
        CALL FUNCTION 'COPA_PROFITABILITY_SEGMENT'              "1651459
          EXPORTING                                             "1651459
            dialog                   = ' '                      "1651459
            i_cobl                   = ls_cobl_old              "1651459
          IMPORTING                                             "1651459
            e_cobl                   = ls_cobl_new              "1651459
          EXCEPTIONS                                            "1651459
            ERROR_MESSAGE            = 1                        "1651459
            OTHERS                   = 2.                       "1651459
        IF sy-subrc = 0.                                        "1651459
          mseg-paobjnr = ls_cobl_new-paobjnr.                   "1651459
        ENDIF.                                                  "1651459
      ENDIF.                                                    "1651459
    ENDIF.                                                      "1651459
  ENDIF.                                                        "1651459

  IF mseg-lgort IS INITIAL.
    mseg-lgort = rm07m-lgort.
  ENDIF.
  MOVE-CORRESPONDING xrbefu TO dm07m.
  dm07m-cuobj_refdoc = xrbefu-cuobj.                        "630576
  dm07m-kanba = xrbefu-kbnkz.
  IF NOT xrbefu-offen IS INITIAL AND xrbefu-kzear IS INITIAL.
    mseg-kzear = rm07m-kzear.
  ENDIF.
  vm07m-kzear_old = xrbefu-kzear.
  dm07m-kzear_inp = rm07m-kzear.
  dm07m-rshkz = xrbefu-shkzg.
  IF mseg-sobkz NE q.
    dm07m-konto = xrbefu-saknr.
  ENDIF.
  IF dm07m-ktoma IS INITIAL.
    CLEAR dm07m-konto.
  ENDIF.
  dm07m-rlgor = xrbefu-lgort.
  dm07m-rchar = xrbefu-charg.
  vm07m-bdter = xrbefu-bdter.
* Verbuchungsteuerungsdaten für Auftragsänderungsdienst übernehmen
  vm07m-objnr   = xrbefu-objnr.
  vm07m-objtype = xrbefu-objtype.

* Prüfung, ob Charge aus Reservierung kommen muß - wenn ja und Charge
* ist vorhanden, wird Prüfkennzeichen zurückgenommen - ist KZECH nicht
* gesetzt und WM im Spiel, wird später die Charge über WM bestimmt
  IF dm07m-kzech IS INITIAL.
    IF xrbefu-charg IS INITIAL AND NOT xrbefu-lgnum IS INITIAL
                               AND xrbefu-berkz NE '0'.
      dm07m-kzech = stern.
    ENDIF.
  ELSEIF NOT xrbefu-charg IS INITIAL OR xrbefu-berkz EQ '0'.
    CLEAR dm07m-kzech.
  ENDIF.

ENDFORM.                    "res_positionen_uebernehmen_01