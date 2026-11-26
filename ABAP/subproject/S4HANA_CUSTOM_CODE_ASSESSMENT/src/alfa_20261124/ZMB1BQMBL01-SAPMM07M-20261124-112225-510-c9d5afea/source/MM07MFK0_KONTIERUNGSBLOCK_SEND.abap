*eject
*---------------------------------------------------------------------*
*       FORM KONTIERUNGSBLOCK_SEND_PBO                                *
*---------------------------------------------------------------------*
*       Aus der Feldliste der Kontierungselemente (INT_COBLF) wird    *
*       im Kontierungsblock ein geeignetes Dynpro gesucht und         *
*       Dynpronummer und Modulpoolname für den anschließenden         *
*       CALL SUBSCREEN zurückgegeben.                                 *
*---------------------------------------------------------------------*
FORM kontierungsblock_send_pbo.

  CLEAR: cobl, vm07m-vbtyp, msegk-vbtyp.
*-- Bei Entnahmen für Kundenauftrag mit MB1x muß der eingegebene    --*
*-- Kundenauftrag mit MD81 erzeugt worden sein (VBTYP = W).         --*
  IF NOT dm07m-fausw+12(1) = minus AND mseg-kzbew IS INITIAL.
    msegk-vbtyp = vm07m-vbtyp = cobl-vbtyp = w.
  ENDIF.
  IF fcausw-xlist IS INITIAL OR NOT mseg-kzbew IS INITIAL.
    MOVE-CORRESPONDING mseg  TO cobl.
    IF NOT mseg-matbf IS INITIAL.                           "note305972
      cobl-matnr = mseg-matbf.                              "note305972
    ENDIF.                                                  "note305972
    MOVE-CORRESPONDING dm07m TO cobl.
    MOVE-CORRESPONDING vm07m TO cobl.
*   Note 365071 makes an attempt to improve the situation.
*   Cannot be implemented in this support package. See internal memo.
    cobl-gsber = mseg-pargb.
    cobl-pargb = mseg-gsber.
    cobl-prctr = mseg-pprctr.
    cobl-pprctr = mseg-prctr.
    IF NOT mseg-umwrk IS INITIAL.
*<<<< Beign Note 644682 >>>>
      If ( mseg-kostl is initial and mseg-aufnr is initial
         and mseg-ps_psp_pnr is initial and mseg-kdauf is initial ).
*          check if field status of Business Area is suppressed
           if dm07m-fausw+32(1) = minus.
             cobl-gsber  = mseg-gsber.
             cobl-pargb  = mseg-pargb.
            endif.
*           check if field status of Profit Center is suppressed
           if dm07m-fausw+41(1) = minus.
             cobl-prctr  = mseg-prctr.
             cobl-pprctr = mseg-pprctr.
           endif.
      endif.
      if not mseg-xauto is initial.
         cobl-gsber  = mseg-gsber.
         cobl-pargb  = mseg-pargb.
        cobl-prctr  = mseg-prctr.
        cobl-pprctr = mseg-pprctr.
      ENDIF.
* <<<< End Note 644682 >>>>
    ENDIF.
    cobl-bukrs = mseg-parbu.
    IF cobl-bukrs IS INITIAL AND t158-trtyp NE h.
      cobl-bukrs = mseg-bukrs.
    ENDIF.
  ELSE.
    MOVE-CORRESPONDING msegk TO cobl.
    cobl-gsber = msegk-pargb.
    cobl-prctr = msegk-pprctr.
    CLEAR cobl-pargb.
    CLEAR cobl-pprctr.
    cobl-bukrs = msegk-parbu.
    cobl-shkzg = mseg-shkzg.
  ENDIF.
  IF cobl-bukrs IS INITIAL.
    cobl-bukrs = t001k-bukrs.
  ENDIF.
  CLEAR cobl-kokrs.
  cobl-vorgn   = rw_vorgang.
  cobl-awtyp   = rw_awtyp.                                "note 1125184
  cobl-blart   = mkpf-blart.
  cobl-bldat   = mkpf-bldat.
  cobl-budat   = mkpf-budat.
  cobl-process = 'BELEGPOS'.
  cobl-event   = 'PRUEFEN'.
* CO checks fiscal year once again if MSEG-GJAHR is initial
  cobl-gjahr   = mseg-gjahr.                               "note 564018
  IF NOT xower IS INITIAL.
    REFRESH int_coblf.
  ENDIF.
ENHANCEMENT-POINT EHP603_KONT-BLOCK_SEND_PBO_01 SPOTS ES_MM07MFK0_KONT-BLOCK_SEND.
*--Display Funded Program in MM Screens
  DATA : ls_coblf TYPE coblf.
  IF NOT CL_FM_FUNDED_PROG_UTIL_APPL=>IS_MEASURE_ACTIVE( ) IS INITIAL.
    ls_coblf-fdnam    = 'MEASURE'.
    ls_coblf-input     = '0'.
    ls_coblf-required  = '0'.
    ls_coblf-output    = '1'.
    ls_coblf-intens    = '0'.
    ls_coblf-invisible = '0'.
    ls_coblf-active    = '1'.
    APPEND ls_coblf TO int_coblf.

    " Read the value for Funded Program
    " Measure exists in COBL only in EA-PS. Cannot do direct assignments.
    TYPES: BEGIN OF s_fm_measure,
             measure type  fm_measure,
           END OF s_fm_measure.
    DATA ls_measure type s_fm_measure.
    MOVE-CORRESPONDING cobl TO ls_measure.

    IF ls_measure-measure IS INITIAL.
      ls_measure-measure = cl_fm_funded_prog_util_appl=>get_measure_from_matdoc(
                                                                           iv_mblnr = mseg-mblnr
                                                                           iv_mjahr = mseg-mjahr
                                                                         ).
      MOVE-CORRESPONDING ls_measure TO cobl.
    ENDIF.
  ENDIF.

  " Read the value for Budget Period from the FI document as it is not
  " stored in MSEG
  IF cl_ops_switch_check=>ops_sfws_bud_per( ) IS NOT INITIAL
    AND cobl-budget_pd IS INITIAL.
    DATA: lt_documents TYPE STANDARD TABLE OF acc_doc,
          ls_boole TYPE boole,
          ls_bseg TYPE bseg,
          lv_aworg TYPE acchd-aworg.

    FIELD-SYMBOLS: <line> TYPE acc_doc.
    CLEAR ls_boole.
    lv_aworg = mseg-mjahr.

    " Get the FI documents.
    CALL FUNCTION 'AC_DOCUMENT_RECORD'
      EXPORTING
        i_awtyp            = 'MKPF'
        i_awref            = mseg-mblnr
        i_aworg            = lv_aworg
*     I_AWSYS            = ' '
        i_awtyp_incl       = 'BKPF'
*     I_AWTYP_EXCL       = ' '
*     I_BUKRS            = ' '
*     I_VALUTYP          = '0'
      x_dialog           = ls_boole
   TABLES
     t_documents        = lt_documents
   EXCEPTIONS
     no_reference       = 1
     no_document        = 2
     OTHERS             = 3.
    IF sy-subrc EQ 0.
      " We have some documents, find the one with the correct entry.
      LOOP AT lt_documents ASSIGNING <line>.
        " Now read from BSEG to get line. The BUZID should be 'S'
        SELECT SINGLE * FROM bseg
          INTO ls_bseg
          WHERE bukrs EQ <line>-bukrs
            AND belnr EQ <line>-docnr
            AND gjahr EQ <line>-ac_gjahr
            AND buzid EQ 'S'.
        IF sy-subrc EQ 0.
          cobl-budget_pd = ls_bseg-budget_pd.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

* OLC EhP5e Ensure that for the Order type the activity values (APLZL) are cleared when necessary.
* For Production Orders the values of AUFPL and APLZL can contain values for header costed orders.
* OLC sees this as an error scenario. The values need to be cleared prior to the accounting check.
* The operation value is also not shown in the Coding Block
  IF cl_erp_co_olc_tools=>is_not_olc_relevant( mseg-aufnr ) EQ abap_true.
    CLEAR cobl-aplzl.
  ENDIF.

* Beschaffen des Subscreens für den Kontierungsblock
  CALL FUNCTION 'COBL_SEND_PBO'
    EXPORTING
      dclass      = 'STD1'
      icobl       = cobl
      full_always = xfull
    IMPORTING
      dynnr       = dynnr
      progn       = progn
    TABLES
      icoblf      = int_coblf.

ENDFORM.                    "kontierungsblock_send_pbo