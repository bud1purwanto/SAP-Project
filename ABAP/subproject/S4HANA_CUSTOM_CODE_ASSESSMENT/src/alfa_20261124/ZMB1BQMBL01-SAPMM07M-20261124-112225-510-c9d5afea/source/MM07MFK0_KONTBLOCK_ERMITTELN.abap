*eject
*---------------------------------------------------------------------*
*       FORM KONTBLOCK_ERMITTELN                                      *
*---------------------------------------------------------------------*
*       Es werden alle Felder der Struktur COBL ermittelt, die        *
*       in der Feldauswahlleiste enthalten sind.                      *
*---------------------------------------------------------------------*
FORM kontblock_ermitteln.

  DATA: l1.
  DESCRIBE TABLE xcobf LINES sy-tfill.
  IF sy-tfill IS INITIAL.
    SELECT * FROM tcobf INTO TABLE xcobf.
  ENDIF.
  REFRESH int_coblf.
  IF dm07m-fausw IS INITIAL AND NOT dm07m-knttp IS INITIAL.
    SELECT SINGLE * FROM t162k WHERE knttp = dm07m-knttp.
    IF sy-subrc IS INITIAL.
      dm07m-fausw = t162k-faus1.
      dm07m-fausw+70(58) = t162k-faus2.
    ENDIF.
  ENDIF.
  IF mseg-kzbew IS INITIAL.
    DATA: eingabe.
    CLEAR eingabe.
    IF ( aktyp = h OR ( aktyp = k AND fcausw-xlist IS INITIAL )
        OR ( sy-dynnr EQ '1406' ) ) AND
       vm07m-xstor IS INITIAL.
      eingabe = x.
    ENDIF.
    IF NOT fcausw-xlist IS INITIAL.
      IF NOT msegk-rsnum IS INITIAL OR ( NOT msegk-ebeln IS INITIAL
         AND NOT mseg-kzzug IS INITIAL ) OR mseg-kzbew = o.
        CLEAR eingabe.
      ENDIF.
    ELSE.
      IF NOT mseg-rsnum IS INITIAL OR ( NOT mseg-ebeln IS INITIAL
         AND NOT mseg-kzzug IS INITIAL ) OR mseg-kzbew = o.
        CLEAR eingabe.
      ENDIF.
    ENDIF.
  ENDIF.
  IF fcausw-xlist IS INITIAL.
    IF aktyp NE a.
      MOVE-CORRESPONDING mseg  TO cobl.
      IF NOT mseg-matbf IS INITIAL.                         "note305972
        cobl-matnr = mseg-matbf.                            "note305972
      ENDIF.                                                "note305972
      IF NOT cl_psm_core_switch_check=>psm_fm_core_gen( ) IS INITIAL.
**-- Material Reservation and FM integration
**--Setting the completion indicator
        IF NOT mseg-rsnum IS INITIAL.
          SELECT SINGLE kblnr kblpos INTO (cobl-kblnr, cobl-kblpos) FROM resb WHERE rsnum = mseg-rsnum
                                                                              AND   rspos = mseg-rspos.
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING dm07m TO cobl.
      MOVE-CORRESPONDING vm07m TO cobl.
      cobl-prctr = mseg-pprctr.
      MOVE-CORRESPONDING mseg  TO cobl_mb.
      MOVE-CORRESPONDING dm07m TO cobl_mb.
      MOVE-CORRESPONDING vm07m TO cobl_mb.
      kdauf = mseg-kdauf.
      kdpos = mseg-kdpos.
      kdein = mseg-kdein.
      pspnr = mseg-ps_psp_pnr.
    ENDIF.
  ELSE.
    IF aktyp = h.
      MOVE-CORRESPONDING msegk TO cobl.
      cobl-prctr = msegk-pprctr.
      MOVE-CORRESPONDING msegk TO cobl_mb.
      kdauf = msegk-kdauf.
      kdpos = msegk-kdpos.
      kdein = msegk-kdein.
      pspnr = msegk-ps_psp_pnr.
    ENDIF.
  ENDIF.
  DATA: group1 LIKE tcobf-group1.
  LOOP AT xcobf.
    CLEAR int_coblf.
    int_coblf-fdnam = xcobf-field.
    group1 = xcobf-group1 - 1.
    CHECK group1 < 128.
    IF group1 GE 0.
      MOVE dm07m-fausw+group1(1) TO l1.
      CASE l1.
        WHEN plus.
          int_coblf-required  = mod_on.
          int_coblf-output    = mod_on.
          int_coblf-cupos     = mod_on.
          IF int_coblf-fdnam = 'ANLN2'.
            int_coblf-required  = mod_off.
          ENDIF.
          IF int_coblf-fdnam = 'VORNR'.
            int_coblf-required  = mod_off.
          ENDIF.

          " For OLC the VORNR_AUF field is displayed for the operation value.
          IF cl_erp_co_olc_sw_check=>erp_co_olc( ) EQ 'X'.
            IF int_coblf-fdnam = 'VORNR_AUF'.
              int_coblf-required  = mod_off.
            ENDIF.
          ENDIF.

          IF int_coblf-fdnam = 'KDPOS'.
            int_coblf-required  = mod_off.
            int_coblf-cupos     = mod_off.
          ENDIF.
          IF int_coblf-fdnam = 'KDEIN'.
            int_coblf-required  = mod_off.
            int_coblf-cupos     = mod_off.
          ENDIF.
        WHEN punkt.
          int_coblf-required  = mod_off.
          int_coblf-output    = mod_on.
      ENDCASE.
      IF l1 NE minus.
        int_coblf-input = mod_on.
        IF eingabe IS INITIAL.
          int_coblf-input = mod_off.
        ENDIF.
*     when button 'Display acct. assgt.' is not pressed
      ELSEIF ccode <> ccod-konb.
        IF ( aktyp NE a AND fcausw-xlist IS INITIAL ) OR
           ( aktyp EQ h AND NOT fcausw-xlist IS INITIAL ).
          DATA: BEGIN OF feld1,
                  name(4)  VALUE 'COBL',
                  strich   VALUE '-',
                  wert(10),
                END OF feld1.
          MOVE xcobf-field TO feld1-wert.
          ASSIGN (feld1) TO <f>.
          IF sy-subrc IS INITIAL.
            CLEAR <f>.
          ENDIF.
        ENDIF.
      ENDIF.
      CHECK int_coblf-input    = mod_on
         OR int_coblf-output   = mod_on
         OR int_coblf-required = mod_on.
      int_coblf-active = mod_on.
      int_coblf-invisible = mod_off.
      IF ( ( ( xcobf-field = 'KDAUF' OR xcobf-field = 'KDPOS'
               OR xcobf-field = 'KDEIN' ) AND
         ( mseg-sobkz = e OR mseg-umsok = e ) ) OR
         ( ( xcobf-field = 'KDAUF' OR xcobf-field = 'KDPOS'   "SIT
               OR xcobf-field = 'KDEIN' ) AND                 "SIT
         ( mseg-sobkz = t OR mseg-umsok = t ) ) OR            "SIT
         ( ( xcobf-field = 'PS_PSP_PNR' )
         AND ( mseg-sobkz = q OR mseg-umsok = q ) ) )
         AND t158-kzbew IS INITIAL.
        int_coblf-input     = mod_off.
        int_coblf-active    = mod_off.
        int_coblf-output    = mod_off.
        int_coblf-required  = mod_off.
        int_coblf-cupos     = mod_off.
      ENDIF.
      IF t156-kzkon = plus.
        int_coblf-cupos = mod_off.
      ENDIF.
      APPEND int_coblf.
    ENDIF.
  ENDLOOP.
  IF fcausw-xlist IS INITIAL.
    IF aktyp NE a AND aktyp NE v.                           "565188
      MOVE-CORRESPONDING cobl    TO mseg.
      MOVE-CORRESPONDING cobl_mb TO mseg.
      MOVE-CORRESPONDING cobl    TO dm07m.
      MOVE-CORRESPONDING cobl_mb TO dm07m.
      MOVE-CORRESPONDING cobl    TO vm07m.
      MOVE-CORRESPONDING cobl_mb TO vm07m.
      IF NOT cobl-objnr_real IS INITIAL.
        vm07m-objnr = cobl-objnr_real.
      ENDIF.
      mseg-pprctr = cobl-prctr.
      IF t158-kzbew IS INITIAL.
        IF ( mseg-sobkz = e OR mseg-umsok = e ).
          mseg-kdauf = kdauf.
          mseg-kdpos = kdpos.
          mseg-kdein = kdein.
        ENDIF.
        IF ( mseg-sobkz = t OR mseg-umsok = t ).              "SIT
          mseg-kdauf = kdauf.                                 "SIT
          mseg-kdpos = kdpos.                                 "SIT
          mseg-kdein = kdein.                                 "SIT
        ENDIF.
        IF ( mseg-sobkz = q OR mseg-umsok = q ).
          mseg-ps_psp_pnr = pspnr.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    IF aktyp = h.
      MOVE-CORRESPONDING cobl    TO msegk.
      MOVE-CORRESPONDING cobl_mb TO msegk.
      msegk-pprctr = cobl-prctr.
      IF t158-kzbew IS INITIAL.
        IF ( mseg-sobkz = e OR mseg-umsok = e ).
          msegk-kdauf = kdauf.
          msegk-kdpos = kdpos.
          msegk-kdein = kdein.
        ENDIF.
        IF ( mseg-sobkz = t OR mseg-umsok = t ).              "SIT
          msegk-kdauf = kdauf.                                "SIT
          msegk-kdpos = kdpos.                                "SIT
          msegk-kdein = kdein.                                "SIT
        ENDIF.
        IF ( mseg-sobkz = q OR mseg-umsok = q ).
          msegk-ps_psp_pnr = pspnr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
* empty perform for Joint-Venture Accounting (JVA)         note 330030
  PERFORM jv_cobl_screen.                                 "note 330030

ENHANCEMENT-POINT kontblock_ermitteln_01 SPOTS es_sapmm07m.
ENDFORM.                    "kontblock_ermitteln