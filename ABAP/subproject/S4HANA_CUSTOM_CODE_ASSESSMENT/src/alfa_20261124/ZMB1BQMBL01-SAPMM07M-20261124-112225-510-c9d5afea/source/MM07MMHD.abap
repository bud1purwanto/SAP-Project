*----------------------------------------------------------------------*
*       FORM CHECK_MHD                                                 *
*----------------------------------------------------------------------*
*       Überprüfung Herstelldatum und MHD                              *
*----------------------------------------------------------------------*
FORM check_mhd USING frs_matnr     LIKE mcha-matnr
                     frs_charg     LIKE mcha-charg
                     frs_werks     LIKE mcha-werks
                     frs_refcharg  LIKE mcha-charg
                     frs_xchpf     LIKE vm07m-xchpf
                     frs_xwmhd     LIKE t159l-xwmhd
                     frs_geshb     LIKE dm07m-mhdhb
                     frs_rstlz     LIKE dm07m-mhdrz
                     frs_iprkz_hbd LIKE mara-iprkz
                     frs_iprkz_rlz LIKE mara-iprkz.

  DATA: new_mhdat LIKE mcha-vfdat,
        x_mhdat LIKE mcha-vfdat,
        x_hsdat LIKE mcha-hsdat,
        x_msgnr LIKE t160m-msgnr,
        days_in_rem_sl LIKE dm07m-mhdlg,
        days_after_sled LIKE dm07m-mhdlg,
        lv_calc        TYPE xfeld,
        lv_check       TYPE xfeld,
        lv_dupl        TYPE xfeld,
        exit_answer(1) TYPE c,         " Antw. auf Sicherheitsabfrage
        char_date01(30) TYPE c,        " konvert. Datum für Anzeige
        char_date02(30) TYPE c,
        char_date03(30) TYPE c,
        char_date04(30) TYPE c.
  DATA: xmchx LIKE smcha,              " interne Kopie des Sperrsatzes
        omchx LIKE mcha.               " DB-Zustand der Charge

  STATICS:
    s_badi_sled_management TYPE REF TO if_ex_vb_sled_management,
    s_badi_active_imp      TYPE sxrt_boolean,
    s_check_active_done    TYPE xfeld.

************************************************************************

  CHECK NOT frs_xwmhd IS INITIAL AND   " MHD-Abw. auf Werksebene aktiv
      ( dm07m-kzmhd EQ 1 OR            " Bewegungsart: Daten prüfen
        dm07m-kzmhd EQ 2 OR            "     -"-     : Daten nur eingeb.
        dm07m-kzmhd EQ 4 ).            " CFB: Check, but don't calculate

*- set parameters for CHECK and CALC according to KZMHD
  IF dm07m-kzmhd EQ 1.
    lv_calc  = x.
    lv_check = x.
  ELSEIF dm07m-kzmhd EQ 2.
    lv_calc  = x.
  ELSEIF dm07m-kzmhd EQ 4. " CFB
    lv_check = x.          " CFB
  ENDIF.

******* Füllen der Felder, wenn Aufruf aus MB_CREATE_GOODS_MOVEMENT ****
  IF NOT xmbwl IS INITIAL.
*** goods receipt OR (transfer posting and MSEG-SHKZG = 'S')
*** -> mseg-charg is receiving batch => adopt mseg-hsdat and mseg-vfdat
    IF mseg-shkzg EQ 'S'.
      IF dm07m-mhdat IS INITIAL.
        IF NOT vm07m-xchpf IS INITIAL.                      "851682
          IF dm07m-hsdat_input IS INITIAL.
            dm07m-hsdat_input = mseg-hsdat.
          ENDIF.
          IF dm07m-vfdat_input IS INITIAL.
            dm07m-vfdat_input = mseg-vfdat.
          ENDIF.
        ENDIF.                                              "851682
      ELSE.
        IF frs_geshb IS INITIAL.
          dm07m-vfdat_input = dm07m-mhdat.
        ELSE.
          dm07m-hsdat_input = dm07m-mhdat.
        ENDIF.
      ENDIF.
*** transfer posting and MSEG-SHKZG = 'H'
*** -> mseg-umcha is receiving batch
*** => adopt dm07m-umhsdat and dm07m-umvfdat
    ELSEIF NOT dm07m-kzuml IS INITIAL
       AND mseg-shkzg EQ 'H'.
      IF dm07m-hsdat_input IS INITIAL.
        dm07m-hsdat_input = dm07m-umhsdat.
      ENDIF.
      IF dm07m-vfdat_input IS INITIAL.
        dm07m-vfdat_input = dm07m-umvfdat.
      ENDIF.
    ENDIF.
  ENDIF.

*- if production and expiration date are given and
*- MHDAT is initial and shelf life is > 0
*- check whether recalculation is suppressed - note 549491
  IF  dm07m-mhdat       IS INITIAL AND
  NOT dm07m-vfdat_input IS INITIAL AND
  NOT dm07m-hsdat_input IS INITIAL AND
  NOT frs_geshb         IS INITIAL.
    CALL FUNCTION 'VBMD_CHECK_CALCULATION_POSS'
      EXCEPTIONS
        calculate      = 0
        dont_calculate = 2
        undetermined   = 0
        OTHERS         = 0.
    CASE sy-subrc.
*- do nothing => recalculation will be carried out
      WHEN 0.
*- suppress recalculation
      WHEN 2.
        CLEAR lv_calc.
    ENDCASE.
  ENDIF.

  IF aktyp EQ 'K'.
*- transfer posting receiving side
    IF NOT dm07m-kzuml IS INITIAL AND
      mseg-shkzg EQ h.
*- data unchanged => checked before => nothing to do
      IF dm07m-umhsdat EQ dm07m-hsdat_input AND
         dm07m-umvfdat EQ dm07m-vfdat_input.
        EXIT.
      ENDIF.
*- 'normal' goods receipt or transfer posting issueing side
    ELSE.
*- data unchanged => checked before => nothing to do
      IF ymseg-hsdat EQ dm07m-hsdat_input AND
         ymseg-vfdat EQ dm07m-vfdat_input.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

  IF frs_charg IS INITIAL.
    CLEAR: xmchx, omchx.
  ELSE.
*** Lesen der Sperrtabelle zur aktuellen Charge ************************
    IF kzdch EQ '0'.
      READ TABLE xmcha INTO xmchx
                       WITH KEY matnr = frs_matnr
                                werks = frs_werks
                                charg = frs_charg BINARY SEARCH.
      IF NOT sy-subrc IS INITIAL.
*-- Abbruch wegen Dateninkonsistenz (&) -------------------------------*
        MESSAGE a111(12) WITH '01'.
      ENDIF.
      PERFORM charge_original_mcha
              USING frs_matnr frs_werks frs_charg.
      IF NOT omcha IS INITIAL.
        MOVE-CORRESPONDING omcha TO omchx.
      ENDIF.
    ELSE.
      CLEAR xmchx.
      READ TABLE xmch1 WITH KEY matnr = frs_matnr
                                charg = frs_charg BINARY SEARCH.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE a111(12) WITH '01'.
      ELSE.
        MOVE-CORRESPONDING xmch1 TO xmchx.
        xmchx-rmcha = xmch1-rmch1.
        PERFORM charge_original_mch1
                USING frs_matnr frs_charg.
        IF NOT omch1 IS INITIAL.
          MOVE-CORRESPONDING omch1 TO omchx.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF NOT xmbwl IS INITIAL AND
     NOT dm07m-mhdat IS INITIAL.
*- Problem: Warenbewegung wird im Hintergrund durchgeführt und es werden
*- nicht die Felder VFDAT und HSDAT benutzt, sondern MHDAT (Bsp. MF40)
*- => HSDAT bzw. VFDAT würden unbeabsichtigt überschrieben werden
*- Vorsicht: gerettetes VFDAT wird evtl. durch Message 12006 doch
*- geändert (je nach Customizing-Einstellung der Systemmeldung)
    IF frs_geshb IS INITIAL.
      IF dm07m-vfdat_input EQ xmchx-vfdat.
        dm07m-hsdat_input = xmchx-hsdat.
      ENDIF.
    ELSE.
      IF dm07m-hsdat_input EQ xmchx-hsdat.
        dm07m-vfdat_input = xmchx-vfdat.
      ENDIF.
    ENDIF.
  ENDIF.

  IF NOT xmchx-charg IS INITIAL AND
         dm07m-vfdat_input IS INITIAL AND
         dm07m-hsdat_input IS INITIAL.
*** Übernahme HSDAT/MHD als Vorschlagswerte aus Charge in Position nur *
*** wenn beide Felder in der Position leer sind ************************
    IF NOT xmchx-hsdat IS INITIAL AND
       NOT xmchx-vfdat IS INITIAL.
*** beide Felder in der Charge gefüllt => in Position übernehmen *******
      dm07m-vfdat_input = xmchx-vfdat.
      dm07m-hsdat_input = xmchx-hsdat.
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_arbgb = '12'
          i_msgnr = '017'
          i_nolog = 'X'
        IMPORTING
          rc      = rc.
      CASE rc.
        WHEN 0.
        WHEN OTHERS.
          SET CURSOR FIELD 'DM07M-HSDAT_INPUT'.
          IF frs_refcharg IS INITIAL.
*-- MHD + Herst.dat. als Vorschlagswert aus Charge übern. - bitte überpr
            MESSAGE w017(12) WITH xmchx-charg.
            PERFORM naco_log(sapfm07m) USING 'W' '12' '017'
                                   xmchx-charg space space space.
          ELSE.
            MESSAGE w017(12) WITH frs_refcharg.
            PERFORM naco_log(sapfm07m) USING 'W' '12' '017'
                                       frs_refcharg space space space.
          ENDIF.
      ENDCASE.
    ELSEIF NOT xmchx-hsdat IS INITIAL AND
               xmchx-vfdat IS INITIAL.
      dm07m-hsdat_input = xmchx-hsdat.
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_arbgb = '12'
          i_msgnr = '016'
          i_nolog = 'X'
        IMPORTING
          rc      = rc.
      CASE rc.
        WHEN 0.
        WHEN OTHERS.
          SET CURSOR FIELD 'DM07M-HSDAT_INPUT'.
          IF frs_refcharg IS INITIAL.
*-- Herst.datum der Charge als Vorschlagswert übernommen - bitte überpr.
            MESSAGE w016(12) WITH xmchx-charg.
            PERFORM naco_log(sapfm07m) USING 'W' '12' '016'
                                   xmchx-charg space space space.
          ELSE.
            MESSAGE w016(12) WITH frs_refcharg.
            PERFORM naco_log(sapfm07m) USING 'W' '12' '016'
                                       frs_refcharg space space space.
          ENDIF.
      ENDCASE.
    ELSEIF xmchx-hsdat IS INITIAL AND
       NOT xmchx-vfdat IS INITIAL.
      dm07m-vfdat_input = xmchx-vfdat.
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_arbgb = '12'
          i_msgnr = '015'
          i_nolog = 'X'
        IMPORTING
          rc      = rc.
      CASE rc.
        WHEN 0.
        WHEN OTHERS.
          SET CURSOR FIELD 'DM07M-VFDAT_INPUT'.
          IF frs_refcharg IS INITIAL.
*-- MHD der Charge als Vorschlagswert übernommen - bitte überprüfen ---*
            MESSAGE w015(12) WITH xmchx-charg.
            PERFORM naco_log(sapfm07m) USING 'W' '12' '015'
                                   xmchx-charg space space space.
          ELSE.
            MESSAGE w015(12) WITH frs_refcharg.
            PERFORM naco_log(sapfm07m) USING 'W' '12' '015'
                                       frs_refcharg space space space.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDIF.

  MOVE-CORRESPONDING mkpf  TO xbncom.
  MOVE-CORRESPONDING mseg  TO xbncom.
  MOVE-CORRESPONDING dm07m TO xbncom.
  MOVE-CORRESPONDING vm07m TO xbncom.
  IF NOT mbefu IS INITIAL.             " Daten für BAdI / CFC
    MOVE-CORRESPONDING mbefu TO xbncom.
  ENDIF.
  IF NOT kbefu IS INITIAL.             " Einkaufsbelegkopf
    MOVE-CORRESPONDING kbefu TO xbncom.
  ENDIF.

***************Start of BAdI VB_SLED_MANAGEMENT*************************
* get instance and check for active implementation
  IF s_check_active_done IS INITIAL.
    s_check_active_done = 'X'.
    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name                     = 'VB_SLED_MANAGEMENT'
        null_instance_accepted        = 'X'
      IMPORTING
        act_imp_existing              = s_badi_active_imp
      CHANGING
        instance                      = s_badi_sled_management
      EXCEPTIONS
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        OTHERS                        = 99.

    IF NOT sy-subrc IS INITIAL.
      MESSAGE a300(12) WITH 'NO BADI AVAILABLE'.            "#EC NOTEXT
    ENDIF.
  ENDIF.

* if an active implementation exists -> maintain SLED parameters
  IF NOT s_badi_active_imp      IS INITIAL AND
     NOT s_badi_sled_management IS INITIAL.
    CALL METHOD s_badi_sled_management->maintain_sled_parameters
      EXPORTING
        i_mkpf      = mkpf
        i_mseg      = mseg
        i_dm07m     = dm07m
        i_vm07m     = vm07m
        i_bncom     = xbncom
      CHANGING
        c_mhdhb     = frs_geshb
        c_mhdrz     = frs_rstlz
        c_iprkz_hbd = frs_iprkz_hbd
        c_iprkz_rlz = frs_iprkz_rlz
        c_rdmhd     = dm07m-rdmhd
        c_hsdat     = dm07m-hsdat_input
        c_vfdat     = dm07m-vfdat_input
        c_check     = lv_check
        c_calc      = lv_calc.
  ENDIF.
***************End of BAdI VB_SLED_MANAGEMENT***************************

  IF akt_expd IS INITIAL.
*** AKT_EXPD ist initial, wenn entweder zuvor noch keine Position ******
*** bearbeitet wurde oder die vorherige Position fehlerfrei ************
*** abgearbeitet wurde *************************************************
    akt_expd-matnr = frs_matnr.
    akt_expd-werks = frs_werks.
    akt_expd-charg = frs_charg.
    akt_expd-zeile = mseg-zeile.
    akt_expd-hsdat = dm07m-hsdat_input.
    akt_expd-vfdat_input = dm07m-vfdat_input.
  ENDIF.

  IF dm07m-kzmhd EQ 1 AND NOT frs_rstlz IS INITIAL.
*** Wenn die Restlaufzeit im Materialstamm eingegeben ist und eine *****
*** Prüfung der Restlaufzeit verlangt ist, muß das MHD eingegeben ******
*** oder berechnet werden **********************************************
    IF dm07m-hsdat_input IS INITIAL AND
       NOT frs_geshb IS INITIAL.
*** Gesamthaltbarkeitsdauer im Materialstamm ist gepflegt -> Herstell- *
*** datum MUSS eingegeben werden zur Berechnung des MHD ****************
      SET CURSOR FIELD 'DM07M-HSDAT_INPUT'.
*-- Bitte geben Sie das Herstelldatum ein -----------------------------*
      MESSAGE e018(12).
    ENDIF.
    IF dm07m-vfdat_input IS INITIAL AND
       frs_geshb IS INITIAL.
*** Gesamthaltbarkeitsdauer im Materialstamm NICHT gepflegt -> MHD *****
*** MUSS eingegeben werden *********************************************
      SET CURSOR FIELD 'DM07M-VFDAT_INPUT'.
*-- Bitte geben Sie das Mindesthaltbarkeitsdatum ein ------------------*
      MESSAGE e019(12).
    ENDIF.
  ENDIF.

  SET CURSOR FIELD 'DM07M-HSDAT_INPUT'.

*- no calculation possible
  IF dm07m-hsdat_input IS INITIAL OR
     frs_geshb IS INITIAL.
    CLEAR lv_calc.
*- calculation possible
  ELSE.
*- current position not changed and passed successfully before
    IF frs_matnr  EQ prev_expd-matnr AND
       frs_werks  EQ prev_expd-werks AND
       frs_charg  EQ prev_expd-charg AND
       mseg-zeile EQ prev_expd-zeile.
*- nothing changed => nothing to do
      IF NOT dm07m-hsdat_input IS INITIAL         AND
             dm07m-hsdat_input EQ prev_expd-hsdat AND
         NOT dm07m-vfdat_input IS INITIAL         AND
             dm07m-vfdat_input EQ prev_expd-vfdat.
        EXIT.
*- calculated expiration date manually overwritten
*- => do not calulate again
      ELSEIF NOT dm07m-hsdat_input IS INITIAL         AND
                 dm07m-hsdat_input EQ prev_expd-hsdat AND
             NOT dm07m-vfdat_input IS INITIAL         AND
                 dm07m-vfdat_input NE prev_expd-vfdat.
        CLEAR lv_calc.
      ENDIF.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'VB_MAINTAIN_MHD'
    EXPORTING
      i_bezdt                  = mkpf-budat
      i_iprkz_hbd              = frs_iprkz_hbd
      i_iprkz_rlz              = frs_iprkz_rlz
      i_rdmhd                  = dm07m-rdmhd
      i_geshb                  = frs_geshb
      i_rstlz                  = frs_rstlz
      i_mhdat                  = dm07m-vfdat_input
      i_hsdat                  = dm07m-hsdat_input
      i_bncom                  = xbncom
      check                    = lv_check
      calc                     = lv_calc
    IMPORTING
      o_mhdat                  = new_mhdat
      o_hsdat                  = dm07m-hsdat_input
      o_days_in_rem_sl         = days_in_rem_sl
      o_days_after_sled        = days_after_sled
      o_calc                   = lv_calc
      o_check                  = lv_check
    EXCEPTIONS
      sled_le_production_date  = 1
      ref_date_lower_prod_date = 2
      OTHERS                   = 99.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    IF sy-msgty EQ 'W'.
      PERFORM naco_log(sapfm07m)
              USING sy-msgty sy-msgid sy-msgno
                    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

*- distribution of batches - change global fields possible?
  IF NOT frs_xchpf IS INITIAL AND
     NOT frs_charg IS INITIAL.
    DATA:
      lv_change_local_fields_only TYPE xfeld.

    CALL FUNCTION 'VB_CHRG_BATCH_DIST_STATUS_GET'
      EXPORTING
        i_matnr                    = frs_matnr
        i_charg                    = frs_charg
        i_werks                    = frs_werks
      IMPORTING
        e_change_local_fields_only = lv_change_local_fields_only
      EXCEPTIONS
        no_material                = 1
        no_batch                   = 2
        no_plant                   = 3
        inconsistency              = 4
        OTHERS                     = 99.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  IF NOT xmchx-charg IS INITIAL AND
         xmchx-rmcha IS INITIAL.
*** Verprobung eingegebenes HSDAT gegen Chargenstammsatz ***************
    IF NOT omchx-hsdat IS INITIAL AND
           omchx-hsdat NE dm07m-hsdat_input.
      SET CURSOR FIELD 'DM07M-HSDAT_INPUT'.
*- no change allowed due to distribution status
      IF NOT lv_change_local_fields_only IS INITIAL.
*! Distributed batch. Production date only changeable in batch master
        MESSAGE e009(vbw).
      ENDIF.
*-- HSDAT der Charge &1 (&2) entspr. nicht dem eingeg. Herst.datum (&3)
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_arbgb  = '12'
          i_msgnr  = '004'
          i_msgv1  = xmchx-charg
          i_msgv2  = omchx-hsdat
          i_msgv3  = dm07m-hsdat_input
          i_output = 'X'.
    ENDIF.

*** Einstellung für VFDAT wird immer gelesen
*** => Wenn 'E' keine Änderung durch Berechnung (Meldung 12 006)
    CALL FUNCTION 'MB_CHECK_T160M'
      EXPORTING
        i_arbgb = '12'
        i_msgnr = '005'
        i_msgv1 = xmchx-charg
        i_msgv2 = omchx-vfdat
        i_msgv3 = dm07m-vfdat_input
        i_nolog = 'X'
      IMPORTING
        rc      = rc.
* Start of CFB ********************************************
* CFB Check Switch for CFB on? Batch management required?
  IF cl_cfb_switch_check=>log_sfws_pp_cfb( ) IS NOT INITIAL.
    IF gv_flg_bbd_btch IS NOT INITIAL AND
       gv_cfb_no_check IS NOT INITIAL.
      rc = gv_cfb_rc.
    ENDIF.
  ENDIF.
* End of CFB **********************************************

*** Verprobung eingegebenes VFDAT gegen Chargenstammsatz ***************
    IF NOT omchx-vfdat IS INITIAL AND
           omchx-vfdat NE dm07m-vfdat_input AND
       NOT rc IS INITIAL.
      SET CURSOR FIELD 'DM07M-VFDAT_INPUT'.
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_arbgb  = '12'
          i_msgnr  = '005'
          i_msgv1  = xmchx-charg
          i_msgv2  = omchx-vfdat
          i_msgv3  = dm07m-vfdat_input
          i_output = 'X'.
    ENDIF.
  ENDIF.

  IF ( rc EQ 0 OR
       rc EQ 1 OR
       omchx-vfdat IS INITIAL ) AND
       lv_change_local_fields_only IS INITIAL.
*** Änderung des VFDAT erlaubt
    IF NOT new_mhdat IS INITIAL.
      IF NOT dm07m-vfdat_input IS INITIAL AND
             dm07m-vfdat_input NE new_mhdat.
*** durch den CFC wurde das am BS eingebene MHD verändert oder das am **
*** BS eingegebene MHD ist ungleich der Summe aus Herstelldatum und ****
*** Gesamthaltbarkeitsdauer ********************************************
        CALL FUNCTION 'MB_CHECK_T160M'
          EXPORTING
            i_arbgb = '12'
            i_msgnr = '006'
            i_nolog = x
          IMPORTING
            rc      = rc.
        IF ( rc EQ 4 ) AND
           ( NOT sy-batch IS INITIAL OR
             NOT sy-binpt IS INITIAL OR
             NOT xmbwl IS INITIAL ).
*** Im Batch oder Batch-Input kein Entscheidungs-Popup möglich, deshalb
*** Verhalten wie bei Warnung ******************************************
          rc = 1.
        ENDIF.
        CASE rc.
          WHEN 0.
*** das neu berechnete MHD wird kommentarlos übernommen ****************
            dm07m-vfdat_input = new_mhdat.
            akt_expd-vfdat_calc = new_mhdat.
          WHEN 1.                      " Warnung
            x_mhdat = dm07m-vfdat_input.
            dm07m-vfdat_input = new_mhdat.
            akt_expd-vfdat_calc = new_mhdat.
            SET CURSOR FIELD 'DM07M-VFDAT_INPUT'.
*-- Das bisherige MHD (&1) wurde vom Programm auf &2 verändert --------*
            MESSAGE w006(12) WITH x_mhdat new_mhdat.
            PERFORM naco_log(sapfm07m) USING 'W' '12' '006'
                                x_mhdat new_mhdat space space.
          WHEN 2.                      " Fehler
            SET CURSOR FIELD 'DM07M-VFDAT_INPUT'.
*-- Das bisherige MHD (&1) wurde vom Programm auf &2 verändert --------*
            MESSAGE e006(12) WITH dm07m-vfdat_input new_mhdat.
          WHEN OTHERS.                 " Popup
*** Entscheidung zw. eingegebenen und korrigierten MHD per Popup *******
            WRITE new_mhdat TO char_date01.
            WRITE dm07m-vfdat_input TO char_date02.
            CALL FUNCTION 'POPUP_TO_DECIDE_COMPL_QUEST'
              EXPORTING
                txt01          = text-001
                qtext          = text-002
                par01          = char_date01
                par02          = char_date02
                title          = text-003
                answer03       = '*'
                default_answer = 'Y'
                length         = 40
              IMPORTING
                answer         = exit_answer.
            IF exit_answer EQ 'J'.
              dm07m-vfdat_input = new_mhdat.
              akt_expd-vfdat_calc = new_mhdat.
            ENDIF.
        ENDCASE.
      ELSE.
        dm07m-vfdat_input = new_mhdat.
        akt_expd-vfdat_calc = new_mhdat.
      ENDIF.
    ENDIF.
  ENDIF.

  IF NOT lv_check IS INITIAL.
    IF dm07m-vfdat_input NE new_mhdat.
      CALL FUNCTION 'VB_MAINTAIN_MHD'
        EXPORTING
          i_bezdt           = mkpf-budat
          i_iprkz_hbd       = frs_iprkz_hbd
          i_iprkz_rlz       = frs_iprkz_rlz
          i_rdmhd           = dm07m-rdmhd
          i_geshb           = frs_geshb
          i_rstlz           = frs_rstlz
          i_mhdat           = dm07m-vfdat_input
          i_hsdat           = dm07m-hsdat_input
          i_bncom           = xbncom
          check             = lv_check
          calc              = space
          no_cfc_calls      = x
        IMPORTING
          o_days_in_rem_sl  = days_in_rem_sl
          o_days_after_sled = days_after_sled
        EXCEPTIONS
          OTHERS            = 99.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        IF sy-msgty EQ 'W'.
          PERFORM naco_log(sapfm07m)
                  USING sy-msgty sy-msgid sy-msgno
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ENDIF.
    IF days_after_sled GT 0.
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_arbgb = '12'
          i_msgnr = '008'
          i_msgv1 = dm07m-vfdat_input
          i_msgv2 = days_after_sled
          i_msgv3 = text-007
        IMPORTING
          rc      = rc.
      SET CURSOR FIELD 'DM07M-VFDAT_INPUT'.
      CASE rc.
        WHEN 0.
        WHEN 1.
*-- Das MHD in der akt. Position (&1) ist um &2 &3 überschritten ------*
          MESSAGE w008(12) WITH dm07m-vfdat_input
                                days_after_sled text-007.
        WHEN OTHERS.
          MESSAGE e008(12) WITH dm07m-vfdat_input
                                days_after_sled text-007.
      ENDCASE.
    ELSEIF days_in_rem_sl GT 0.
      PERFORM read_text_iprkz USING frs_iprkz_rlz.
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_arbgb = '12'
          i_msgnr = '007'
          i_msgv1 = frs_rstlz
          i_msgv2 = xprdkzt-prtxt
          i_msgv3 = days_in_rem_sl
        IMPORTING
          rc      = rc.
      SET CURSOR FIELD 'DM07M-VFDAT_INPUT'.
      CASE rc.
        WHEN 0.
        WHEN 1.
*-- Restlaufzeit (&1 &2) ist in der akt. Position um &3 Tage unterschrit
          MESSAGE w007(12) WITH frs_rstlz xprdkzt-prtxt
                                days_in_rem_sl.
        WHEN OTHERS.
          MESSAGE e007(12) WITH frs_rstlz xprdkzt-prtxt
                                days_in_rem_sl.
      ENDCASE.
    ENDIF.
  ENDIF.

  IF NOT xmchx-charg IS INITIAL.
    IF mseg-shkzg EQ 'H' AND
       NOT dm07m-kzuml IS INITIAL.
*---> transfer postings...
      LOOP AT ymseg WHERE zeile NE mseg-zeile
                      AND ummat EQ frs_matnr
                      AND umcha EQ xmchx-charg.
* in case batch numbers are unique at plant level, also the receiving
* plants MUST be identical (YMSEG-UMWRK = FRS_WERKS).
        IF kzdch EQ '0'.                                    "674962
          CHECK ymseg-umwrk EQ frs_werks.
        ENDIF.
* at this point we do have a 'duplicate' batch...
        lv_dupl = 'X'.
* in case of transfer postings the production date and
* shelf life expiration date of the receiving batch(es) are
* stored in (Y)DM07M-UMHSDAT and (Y)DM07M-UMVFDAT.
        LOOP AT ydm07m WHERE zeild EQ ymseg-zeile.
          x_mhdat = ydm07m-umvfdat.
          x_hsdat = ydm07m-umhsdat.
          EXIT.
        ENDLOOP.
        EXIT.
      ENDLOOP.
    ELSE.
*---> 'normal' goods receipts...
      LOOP AT ymseg WHERE zeile NE mseg-zeile
                      AND matnr EQ frs_matnr
                      AND charg EQ xmchx-charg.
* in case batch numbers are unique at plant level, also the receiving
* plants MUST be identical (YMSEG-WERKS = FRS_WERKS).
        IF kzdch EQ '0'.                                    "674962
          CHECK ymseg-werks EQ frs_werks.
        ENDIF.
* at this point we do have a 'duplicate' batch...
        lv_dupl = 'X'.
        x_mhdat = ymseg-vfdat.
        x_hsdat = ymseg-hsdat.
        EXIT.
      ENDLOOP.
    ENDIF.

    IF NOT lv_dupl IS INITIAL.
*** Charge ist zusätzlich zur gerade bearbeiteten in mindestens einer **
*** weiteren Position enthalten ****************************************
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_arbgb = '12'
          i_msgnr = '003'
          i_nolog = 'X'
        IMPORTING
          rc      = rc.
*** ACHTUNG: Die Nachrichtensteuerung zu dieser Funktion über T160M ****
*** hängt nur am Eintrag zu Mess. '003' -> Eintr. zu 001/002 wirkungslos
      IF rc EQ 4 AND
       ( NOT sy-batch IS INITIAL OR
         NOT sy-binpt IS INITIAL OR
         NOT xmbwl IS INITIAL ).
*** Im Batch oder Batch-Input kein Entscheidungs-Popup möglich, deshalb
*** Verhalten wie bei Warnung ******************************************
        rc = 1.
      ENDIF.
      CASE rc.
        WHEN 0.
*** Anpassung XMCHA/XMCH1 und YMSEG an neue Werte ohne jeden Hinweis ***
          PERFORM upd_ymseg_ydm07m
                  USING frs_matnr frs_werks xmchx-charg.
        WHEN 1.
*** XMCHA/XMCH1 und YMSEG werden nach Warnung mit neuen Werten aktualis.
          IF dm07m-hsdat_input NE x_hsdat AND
             dm07m-vfdat_input NE x_mhdat.
*-- Herstelldatum/MHD der Charge &1 werden in allen Pos. auf &2/&3 geänd
            MESSAGE w003(12) WITH xmchx-charg
                    dm07m-hsdat_input dm07m-vfdat_input.
            PERFORM naco_log(sapfm07m) USING 'W' '12' '003'
                xmchx-charg dm07m-hsdat_input dm07m-vfdat_input space.
          ELSEIF dm07m-hsdat_input NE x_hsdat.
*-- Das Herst.datum der Charge &1 wird in allen Positionen auf &2 geänd
            MESSAGE w002(12) WITH xmchx-charg dm07m-hsdat_input.
            PERFORM naco_log(sapfm07m) USING 'W' '12' '002'
                    xmchx-charg dm07m-hsdat_input space space.
          ELSEIF dm07m-vfdat_input NE x_mhdat.
*-- Das MHD der Charge &1 wir in allen Positionen auf &2 geändert -----*
            MESSAGE w001(12) WITH xmchx-charg dm07m-vfdat_input.
            PERFORM naco_log(sapfm07m) USING 'W' '12' '001'
                    xmchx-charg dm07m-vfdat_input space space.
          ENDIF.
          PERFORM upd_ymseg_ydm07m
                  USING frs_matnr frs_werks xmchx-charg.
        WHEN 2.                        " Fehlermeldung
          IF dm07m-hsdat_input NE x_hsdat AND
             dm07m-vfdat_input NE x_mhdat.
*-- Herst.datum/MHD unterscheidet sich von anderen Pos. derselben Charge
            MESSAGE e011(12) WITH xmchx-charg
                    dm07m-hsdat_input dm07m-vfdat_input.
          ELSEIF dm07m-hsdat_input NE x_hsdat.
*-- Herst.dat. in akt. Pos. versch. vom Herst.dat. and. Pos. der Charge
            MESSAGE e012(12) WITH xmchx-charg dm07m-hsdat_input.
          ELSEIF dm07m-vfdat_input NE x_mhdat.
*-- MHD in akt. Pos. versch. von MHD anderer Positionen derselben Charge
            MESSAGE e014(12) WITH xmchx-charg dm07m-vfdat_input.
          ENDIF.
        WHEN OTHERS.
*** Popup ob das HSDAT bzw. MHD der akt. Pos. in alle anderen Positionen
*** mit derselben Charge übernommen*************************************
          IF dm07m-hsdat_input NE x_hsdat OR
             dm07m-vfdat_input NE x_mhdat.
            WRITE x_hsdat TO char_date01.
            WRITE '/' TO char_date01+15.
            CONDENSE char_date01.
            WRITE x_mhdat TO char_date01+15.
            CONDENSE char_date01.
            WRITE dm07m-hsdat_input TO char_date03.
            WRITE dm07m-vfdat_input TO char_date04.
            CALL FUNCTION 'POPUP_TO_DECIDE_COMPL_QUEST'
              EXPORTING
                txt01          = text-004
                txt02          = text-006
                qtext          = text-005
                par01          = xmchx-charg
                par02          = char_date01
                par03          = char_date03
                par04          = char_date04
                title          = text-003
                answer03       = '*'
                default_answer = 'Y'
                length         = 45
              IMPORTING
                answer         = exit_answer.
            IF exit_answer EQ 'J'.
              PERFORM upd_ymseg_ydm07m
                      USING frs_matnr frs_werks xmchx-charg.
            ELSE.
              dm07m-hsdat_input = x_hsdat.
              dm07m-vfdat_input = x_mhdat.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDIF.

  prev_expd-matnr = frs_matnr.
  prev_expd-werks = frs_werks.
  prev_expd-charg = frs_charg.
  prev_expd-zeile = mseg-zeile.
  prev_expd-hsdat = dm07m-hsdat_input.
  prev_expd-vfdat = dm07m-vfdat_input.
*** PREV_EXPD enthält die Daten der letzten fehlerfrei abgearb. Pos. ***

  CLEAR akt_expd.

ENDFORM.                    "check_mhd

*----------------------------------------------------------------------*
*       FORM UPD_YMSEG_YDM07M                                          *
*----------------------------------------------------------------------*
*       Änderung des Herstelldatums bzw. MHD in allen Positionen, in   *
*       denen die Charge enthalten ist (außer der aktuellen Position)  *
*----------------------------------------------------------------------*
FORM upd_ymseg_ydm07m USING frs_mat frs_wrk frs_crg.

  DATA: x_line LIKE mseg-zeile.
************************************************************************

  x_line = mseg-zeile.
  ydm07m-hsdat_input = dm07m-hsdat_input.
  ydm07m-vfdat_input = dm07m-vfdat_input.

  IF mseg-shkzg EQ 'H' AND
     NOT dm07m-kzuml IS INITIAL.
*-> transfer postings ...
    LOOP AT ymseg WHERE zeile NE x_line
                    AND ummat EQ frs_mat
                    AND umcha EQ frs_crg.
* in case batch numbers are unique at plant level, also the receiving
* plants MUST be identical (YMSEG-UMWRK = FRS_WRK).
      IF kzdch EQ '0'.                                      "674962
        CHECK ymseg-umwrk EQ frs_wrk.
      ENDIF.
* in case of transfer postings the production date and
* shelf life expiration date of the receiving batch(es) are
* stored in (Y)DM07M-UMHSDAT and (Y)DM07M-UMVFDAT.
      READ TABLE ydm07m WITH KEY zeild = ymseg-zeile        "674962
           TRANSPORTING NO FIELDS.
      IF sy-subrc IS INITIAL.
        ydm07m-umhsdat = dm07m-hsdat_input.
        ydm07m-umvfdat = dm07m-vfdat_input.
        MODIFY ydm07m INDEX sy-tabix
               TRANSPORTING hsdat_input vfdat_input
                            umhsdat     umvfdat.
      ENDIF.
    ENDLOOP.
  ELSE.
*-> 'normal' goods receipts ...
    LOOP AT ymseg WHERE zeile NE x_line
                    AND matnr EQ frs_mat
                    AND charg EQ frs_crg.
* in case batch numbers are unique at plant level, also the receiving
* plants MUST be identical (YMSEG-WERKS = FRS_WRK).
      IF kzdch EQ '0'.                                      "674962
        CHECK ymseg-werks EQ frs_wrk.
      ENDIF.
      ymseg-hsdat = dm07m-hsdat_input.
      ymseg-vfdat = dm07m-vfdat_input.
      MODIFY ymseg TRANSPORTING hsdat vfdat.
      READ TABLE ydm07m WITH KEY zeild = ymseg-zeile
           TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        MODIFY ydm07m INDEX sy-tabix
               TRANSPORTING hsdat_input vfdat_input.
      ENDIF.
    ENDLOOP.
  ENDIF.

  READ TABLE ymseg WITH KEY zeile = x_line.
  READ TABLE ydm07m WITH KEY zeild = x_line.

ENDFORM.                    "upd_ymseg_ydm07m

*----------------------------------------------------------------------*
*       FORM MINDESTHALTBARKEIT_PRUEFEN                                *
*----------------------------------------------------------------------*
*       Coding zu 4.0C komplett neu                                    *
*----------------------------------------------------------------------*
FORM mindesthaltbarkeit_pruefen.

  DATA: x_charg LIKE mcha-charg,
        x_refcharg LIKE mcha-charg.
************************************************************************

  CHECK aktyp NE a.                    " display document - note 351004
  CHECK aktyp NE v.                    " change doc./res. - note 439375

  IF mseg-shkzg EQ s.                  " Zugangsbuchung

* Problem bei während PBO noch nicht zugelesenem Material:
* HSDAT/VFDAT wurde eingegeben, obwohl Material weder MHD-abgewickelt
* noch chargenpflichtig
    IF vm07m-xchpf IS INITIAL AND
       dm07m-mhdrz IS INITIAL AND
      ( NOT dm07m-hsdat_input IS INITIAL OR
        NOT dm07m-vfdat_input IS INITIAL ).
      MESSAGE w020(12) WITH mseg-matnr.
*-- Keine MHD-Abwicklung für Material &. Eingabedaten werden zurückgenom
      CLEAR: dm07m-hsdat_input, dm07m-vfdat_input.
    ENDIF.

*** Prüfung des empfangenden Materials/Charge mit Eingabeaufforderung **
*** bei fehlenden Daten und ggf. Korrektur bestehender Daten
    IF NOT mseg-matnr IS INITIAL AND   " MHD-Abw. nicht bei Dienstleist.
       NOT dm07m-xwmhd IS INITIAL AND  " MHD-Abw. auf Werksebene aktiv
      ( dm07m-kzmhd EQ 1 OR            " Bewegungsart: Daten prüfen
        dm07m-kzmhd EQ 2 ).            "     -"-     : Daten nur eingeb.
      IF vm07m-xchpf IS INITIAL.
        CLEAR x_charg.
      ELSE.
        x_charg = mseg-charg.
      ENDIF.

***** Start of CFB **************************************************
*     CFB Check Switch for CFB on? Batch management required?
      IF cl_cfb_switch_check=>log_sfws_pp_cfb( ) IS NOT INITIAL AND
         x_charg                                 IS NOT INITIAL.
*       REFERENCES
        DATA: lr_cl_cfb_bbd      TYPE REF TO cl_cfb_best_before_date.
*       Local data for CFB
        DATA: lv_aufnr           TYPE aufnr,
              lv_bbdpi           TYPE cfb_bbd_pppi,
              lv_charg_order     TYPE charg_d,
              lv_hsdat_order     TYPE cfb_datofm,
              lv_prodprf         TYPE co_prodprf,
              lv_exit_answer(1)  TYPE c,
              lv_char_date01(30) TYPE c,
              lv_char_date02(30) TYPE c.

*        MOVE vm07m-objnr+2 TO lv_aufnr.
        MOVE mseg-aufnr TO lv_aufnr.

*       get instance
        CALL METHOD cl_cfb_best_before_date=>get_instance
          EXPORTING
            iv_aufnr       = lv_aufnr
          IMPORTING
            er_cfb_bbd_ref = lr_cl_cfb_bbd.

        CALL METHOD lr_cl_cfb_bbd->get_bbd_btch_prdprf_from_order
          EXPORTING
            iv_aufnr       = lv_aufnr
          IMPORTING
            ev_charg_order = lv_charg_order
            ev_datofm      = lv_hsdat_order
            ev_bbdpi       = lv_bbdpi
            ev_prodprf     = lv_prodprf.

*       Get flag, if calculate bbd with new method
        CALL METHOD lr_cl_cfb_bbd->get_flg_bbd_btch_and_calc
          EXPORTING
            iv_aufnr        = lv_aufnr
            iv_werks        = mseg-werks
            iv_prodprf      = lv_prodprf
          IMPORTING
            ev_flg_bbd_btch = gv_flg_bbd_btch.

        IF gv_flg_bbd_btch IS NOT INITIAL.
*          gv_no_calculation = 'X'.
          CALL FUNCTION 'VBMD_NO_FURTHER_CALCULATION'.
          dm07m-kzmhd = '4'. "only check, not calculate

*         IF there were no input of expire date or manufature date ->
*         Set BBD and date of manufacture from process order
          IF dm07m-hsdat_input IS INITIAL.
            MOVE lv_hsdat_order TO dm07m-hsdat_input.
          ELSEIF dm07m-hsdat_input NE lv_hsdat_order.
*            MESSAGE
          ENDIF.

          IF dm07m-vfdat_input IS INITIAL.
            MOVE lv_bbdpi TO dm07m-vfdat_input.
          ELSEIF dm07m-vfdat_input NE lv_bbdpi.
            gv_cfb_no_check = 'X'.
*           Check Type of MESSAGE
            CALL FUNCTION 'MB_CHECK_T160M'
              EXPORTING
                i_arbgb = 'CFB'
                i_msgnr = '404'
                i_nolog = 'X'
              IMPORTING
                rc      = rc.
*          In dependence, if batch is the same as in process order
*          -> set rc
            IF lv_charg_order EQ dm07m-fchar.
              rc = 4.                                         "Popup
            ENDIF.
            IF ( rc EQ 4 ) AND
               ( NOT sy-batch IS INITIAL OR
                 NOT sy-binpt IS INITIAL ).
***           Im Batch oder Batch-Input kein Entscheidungs-Popup möglich,
***           deshalb Verhalten wie bei Warnung *************************
              rc = 1.
              gv_cfb_rc = 1.
            ENDIF.

            CASE rc.
              WHEN 0.

              WHEN 1. "Warning
                PERFORM naco_log(sapfm07m)
                  USING 'W' 'CFB' '404'
                        lv_bbdpi dm07m-vfdat_input space space.

              WHEN 2. "Error
                MESSAGE e404(cfb) WITH lv_bbdpi dm07m-vfdat_input.
                EXIT.

              WHEN OTHERS. "Popup
*               Decide between entered BBD and BBD from process order via Popup
                WRITE dm07m-vfdat_input TO lv_char_date01.
                WRITE lv_bbdpi TO lv_char_date02.

                CALL FUNCTION 'POPUP_TO_DECIDE_COMPL_QUEST'
                  EXPORTING
                    txt01          = text-cf1
                    qtext          = text-cf2
                    par01          = lv_char_date01
                    par02          = lv_char_date02
                    title          = text-003
                    answer03       = '*'
                    default_answer = 'N'
                    length         = 40
                  IMPORTING
                    answer         = lv_exit_answer.
                IF lv_exit_answer EQ 'N'.
                  gv_cfb_rc = 2.
*                 Correct entered BBD with BBD from process order
                  MOVE lv_bbdpi TO dm07m-vfdat_input.
                ELSE.
                  gv_cfb_rc = 0.
                ENDIF.

            ENDCASE. "rc
          ENDIF. "dm07m-vfdat_input IS INITIAL.
        ENDIF. "lv_flg_bbd_btch IS NOT INITIAL.
      ENDIF. "cl_cfb_switch_check=>log_sfws_pp_cfb( ) IS NOT INITIAL.
***** END of CFB ****************************************************

      PERFORM check_mhd USING mseg-matnr
                              x_charg
                              mseg-werks
                              x_refcharg
                              vm07m-xchpf
                              dm07m-xwmhd
                              dm07m-mhdhb
                              dm07m-mhdrz
                              dm07m-iprkz_hbd
                              dm07m-iprkz.
      mseg-hsdat = dm07m-hsdat_input.
      mseg-vfdat = dm07m-vfdat_input.
      CLEAR: gv_cfb_no_check,
             gv_cfb_rc,
             gv_flg_bbd_btch.
    ENDIF.
  ELSEIF mseg-shkzg EQ h.              " Abgangsbuchung
*** Prüf. der abgebenden Charge nur bezügl. HSDAT/MHD aus den Chargen- *
*** stammdaten gegen Bezugsdatum ( in CHARGENDATEN_PRUEFEN - FM07MEMO )
  ENDIF.

ENDFORM.                    "mindesthaltbarkeit_pruefen

*----------------------------------------------------------------------*
*       FORM MHD_PRUEFEN_UMLAGERUNG                                    *
*----------------------------------------------------------------------*
*       Prüfung HSDAT/MHD zum Umlagermaterial bzw. Umlagercharge       *
*----------------------------------------------------------------------*
FORM mhd_pruefen_umlagerung.

  DATA: x_charg LIKE mcha-charg,
        x_refcharg LIKE mcha-charg.
************************************************************************

  CHECK aktyp NE a.                    " display document - note 351004
  CHECK aktyp NE v.                    " change doc./res. - note 439375

  CHECK NOT dm07m-kzuml IS INITIAL.

  IF mseg-shkzg EQ s.                  " Zugangsbuchung
*** Prüf. der abgebenden Charge nur bezügl. HSDAT/MHD aus den Chargen- *
*** stammdaten gegen Bezugsdatum ( in CHARGENDATEN_PRUEFEN - FM07MEMO )
  ELSEIF mseg-shkzg EQ h.              " Abgangsbuchung
*** Prüfung des empfangenden Materials/Charge mit Eingabeaufforderung **
*** bei fehlenden Daten und ggf. Korrektur bestehender Daten

* Problem bei während PBO noch nicht zugelesenem Material:
* HSDAT/VFDAT wurde eingegeben, obwohl Material weder MHD-abgewickelt
* noch chargenpflichtig
    IF dm07m-umxch IS INITIAL AND
       dm07m-ummhdrz IS INITIAL AND
      ( NOT dm07m-hsdat_input IS INITIAL OR
        NOT dm07m-vfdat_input IS INITIAL ).
      MESSAGE w020(12) WITH mseg-ummat.
*-- Keine MHD-Abwicklung für Material &. Eingabedaten werden zurückgenom
      CLEAR: dm07m-hsdat_input, dm07m-vfdat_input.
    ENDIF.

    IF NOT mseg-ummat IS INITIAL AND   " MHD-Abw. nicht bei Dienstleist.
       NOT dm07m-umxwmhd IS INITIAL AND
***        ^^^^^^^^^^^^^ MHD-Abw. auf Werksebene aktiv
       ( dm07m-kzmhd EQ 1 OR           " Bewegungsart: Daten prüfen
         dm07m-kzmhd EQ 2 ).           "     -"-     : Daten nur eingeb.
      IF dm07m-umxch IS INITIAL.
        CLEAR x_charg.
      ELSE.
        x_charg = mseg-umcha.
      ENDIF.
      IF NOT dm07m-xrefc IS INITIAL.
*** Zielcharge bei Umlagerung aus abgebender Charge kopiert ************
        x_refcharg = mseg-charg.
      ENDIF.
      PERFORM check_mhd USING mseg-ummat
                              x_charg
                              mseg-umwrk
                              x_refcharg
                              dm07m-umxch
                              dm07m-umxwmhd
                              dm07m-ummhdhb
                              dm07m-ummhdrz
                              dm07m-umiprkz
                              dm07m-umiprkz.
      dm07m-umhsdat = dm07m-hsdat_input.
      dm07m-umvfdat = dm07m-vfdat_input.
    ENDIF.
  ENDIF.

ENDFORM.                    "mhd_pruefen_umlagerung

*----------------------------------------------------------------------*
*       FORM READ_TEXT_IPRKZ                                           *
*----------------------------------------------------------------------*
*       Text zum Periodenkennzeichen lesen                             *
*----------------------------------------------------------------------*
FORM read_text_iprkz USING frs_iprkz LIKE prdkz-iprkz.

  IF frs_iprkz NE xprdkzt-iprkz OR
     frs_iprkz EQ space OR
     xprdkzt-spras NE sy-langu.
    READ TABLE xprdkzt WITH KEY iprkz = frs_iprkz
                                spras = sy-langu.
    IF NOT sy-subrc IS INITIAL.
      SELECT SINGLE * FROM prdkzt INTO xprdkzt
                                  WHERE iprkz EQ frs_iprkz
                                    AND spras EQ sy-langu.
      IF sy-subrc IS INITIAL.
        APPEND xprdkzt TO xprdkzt.
      ELSE.
        CLEAR xprdkzt.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "read_text_iprkz
*