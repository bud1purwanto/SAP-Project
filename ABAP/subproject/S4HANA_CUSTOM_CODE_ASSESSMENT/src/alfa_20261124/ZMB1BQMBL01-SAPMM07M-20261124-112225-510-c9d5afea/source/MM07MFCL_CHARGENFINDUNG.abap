*eject
*---------------------------------------------------------------------*
*       FORM CHARGENFINDUNG                                           *
*---------------------------------------------------------------------*
*       Die allgemeine Chargenfindung wird aufgerufen.                *
*---------------------------------------------------------------------*
FORM chargenfindung USING loc_action.

* l_complement is set when a batch determination is performed for a
* transfer movement with a shkzg = h in the complementary posting
* (batch determination is only possible if charg = umcha).
  data:
    l_complement,
    ls_ekko             type ekko,
    ls_ekpo             type ekpo.
  IF loc_action EQ f.
    REFRESH ylgort.
  ENDIF.
  CLEAR xbdcom.
  CLEAR XKOMKH.
  CLEAR XKOMPH.
  CLEAR ylgort.
  REFRESH i_bdbatch.
  REFRESH e_bdbatch.
* e_atpcsx is not being cleared in MM07MFL0_LAGERORTDATEN in this
* case, so it has to happen here:
  CLEAR e_atpcsx.
  REFRESH e_atpcsx.
  MOVE-CORRESPONDING mseg TO xkomkh.
  MOVE-CORRESPONDING dm07m TO xkomkh.
  MOVE-CORRESPONDING vm07m TO xkomkh.
  MOVE-CORRESPONDING mseg TO xkomph.
  MOVE-CORRESPONDING dm07m TO xkomph.
  MOVE-CORRESPONDING vm07m TO xkomph.
  IF xkomph-prodh IS INITIAL.
    MOVE vm07m-prdha TO xkomph-prodh.
  ENDIF.
  MOVE-CORRESPONDING mseg TO xbdcom.
  MOVE-CORRESPONDING dm07m TO xbdcom.
  MOVE-CORRESPONDING vm07m TO xbdcom.
  IF xkomkh-vbeln IS INITIAL OR mseg-sobkz EQ e.
    MOVE mseg-mat_kdauf TO xkomkh-vbeln.
    MOVE mseg-mat_kdpos TO xkomkh-posnr.
  ENDIF.
  IF xkomkh-pspnr IS INITIAL.
    MOVE mseg-mat_pspnr TO xkomkh-pspnr.
  ENDIF.
* Fill data for batch determination function module       "1388563
  IF xkomkh-pspnr IS INITIAL AND                          "1388563
     mseg-mat_pspnr IS INITIAL.                           "1388563
    MOVE mseg-ps_psp_pnr to xkomkh-pspnr.                 "1388563
  ENDIF.                                                  "1388563
  CLEAR xbdcom-menge.
  IF mseg-charg CS '**'.
    xbdcom-chmdg = x.
  ENDIF.
  xbdcom-kalsm = dm07m-chsmm.
  xbdcom-kappl = 'ME'.
  IF NOT xmbwl IS INITIAL.
    xbdcom-nodia = x.
  ENDIF.
  xbdcom-nodel = space.
  xbdcom-nolck = x.
  xbdcom-prreg = t158-prreg.
  xbdcom-xmore = x.
  xbdcom-lbbsa = t156m-lbbsa.
  xbdcom-cuobj = mseg-cuobj_ch.
  IF NOT dm07m-cuobj IS INITIAL.
    xbdcom-cuobj_conf = dm07m-cuobj.
  ENDIF.
  IF t156-shkzg EQ s.
    SELECT SINGLE * FROM t156m WHERE bustm = s156s-bustm
                                 AND zustd = space
                                 AND cnt02 = 2.
    IF sy-subrc IS INITIAL.
      xbdcom-lbbsa = t156m-lbbsa.
      IF NOT mseg-umwrk IS INITIAL.
        xkomph-werks = mseg-umwrk.
      ENDIF.
      xkomph-umwrk = mseg-werks.
      IF NOT mseg-umlgo IS INITIAL.
        xkomph-lgort = mseg-umlgo.
      ENDIF.
      xkomph-umlgo = mseg-lgort.
      xkomph-sobkz = mseg-umsok.
      xkomph-umsok = mseg-sobkz.
      xbdcom-sobkz = xkomph-sobkz.
      IF mseg-matnr = mseg-ummat
        OR mseg-ummat IS INITIAL.
        l_complement = 'X'.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM t156m WHERE bustm = s156s-bustm
                                   AND zustd = space
                                   AND cnt02 = 1.
      xbdcom-lbbsa = t156m-kbbsa.
    ENDIF.
  ENDIF.
  xbdcom-objid = cl_mseg.
  xbdcom-lfdat = mkpf-budat.
  CONCATENATE cl_prekey mseg-zeile INTO xbdcom-objec.

* Vorbereitung Findung
  IF loc_action EQ f.
    IF NOT mseg-rsnum IS INITIAL.
      CLEAR atpdt.
      atpdt-atptk = 'RE'.
      atpdt-atpap = 'MB'.
      atpdt-delst = c.
      atpdt-delnr = mseg-rsnum.
      atpdt-delps = mseg-rspos.
      atpdt-rsart = mseg-rsart.
      CALL FUNCTION 'DELTA_MANAGEMENT'
        EXPORTING
          p_atpdt = atpdt
        EXCEPTIONS
          OTHERS  = 0.
    ENDIF.
    IF dm07m-kzuml IS INITIAL OR
       ( NOT dm07m-kzuml IS INITIAL AND mseg-shkzg = h ).
      IF mseg-shkzg = h AND NOT dm07m-kzvbp IS INITIAL AND NOT
         vm07m-mtvfp IS INITIAL.
        PERFORM dynamische_verfpruefung(sapfm07m) USING dm07m-kzvbp
                                                        vm07m-mtvfp
                                                         mseg-matnr
                                                         mseg-werks
                                                         mseg-lgort
                                                         space
                                                         dm07m-fabkl
                                                         space
                                                         dm07m-berid.
      ENDIF.
      IF vm07m-mtvfp IS INITIAL.
        CLEAR xbdcom-kzvbp.
      ELSE.
        xbdcom-mtvfp = vm07m-mtvfp.
      ENDIF.
    ELSE.
      IF mseg-shkzg = s AND NOT dm07m-kzvbp IS INITIAL AND NOT
         dm07m-ummtv IS INITIAL.
        PERFORM dynamische_verfpruefung(sapfm07m) USING dm07m-kzvbp
                                                        dm07m-ummtv
                                                         mseg-ummat
                                                         mseg-umwrk
                                                         mseg-umlgo
                                                         space
                                                         dm07m-umfab
                                                         x
                                                         dm07m-umberid.
      ENDIF.
      IF dm07m-ummtv IS INITIAL.
        CLEAR xbdcom-kzvbp.
      ELSE.
        xbdcom-mtvfp = dm07m-ummtv.
      ENDIF.
    ENDIF.
  ENDIF.

* Vorbereitung Prüfung
  IF loc_action EQ p.
    CLEAR i_bdbatch.
    MOVE-CORRESPONDING mseg TO i_bdbatch.
    i_bdbatch-werks = xkomph-werks.
    i_bdbatch-lgort = xkomph-lgort.
    i_bdbatch-kzupd = r.
    APPEND i_bdbatch.
    xbdcom-nodia = x.
    xbdcom-bdchk = x.
  ENDIF.

* Korrektursätze überprüfen
  LOOP AT atpcsx.
    atpcsx-corflg = x.
    atpcsx-enqflg = space.
    atpcsx-chkflg = space.
    IF ATPCSX-CHARG IS INITIAL.
      ATPCSX-IDXATP = 0.
    ELSE.
      ATPCSX-IDXATP = 1.
    ENDIF.
    MODIFY atpcsx.
  ENDLOOP.

  xbdcom-delkz = atpcsx-delkz.
  IF NOT mseg-rsnum IS INITIAL.
    xbdcom-delnr = mseg-rsnum.
    xbdcom-delps = mseg-rspos.
  ENDIF.

* combination movement type and SOBKZ = K or P possible?
  SELECT SINGLE * FROM t156b WHERE bwart = xbdcom-bwart
                             AND   sobkz = k.
  if not sy-subrc is initial or l_complement = x.

*   BF_STOCK_DETERMINATION does not return consignment or pipeline stock
*   if XNCSG = F.
    xbdcom-xncsg = f.
  ENDIF.

* set lock for SC components
  IF fuss-sobkz = o AND xmbwl =  x.
    DATA: BEGIN OF LS_FUSS OCCURS 0.
            INCLUDE STRUCTURE FUSS_MB.
    DATA: END OF LS_FUSS.
    data  begin of lt_used_lines occurs 0.
    data    line_id type mb_line_id.
    data  end of lt_used_lines.
    DATA: lt_bfstock TYPE TABLE OF bfstock,
          ls_bfstock TYPE bfstock,
          l_used_line type mb_line_id,
          ls_gocomp type gocomp.

    data: l_menge like mseg-menge.

    CALL FUNCTION 'BF_RESET_LOC_LSMSLB'.

    LOOP AT fuss INTO ls_fuss
                 WHERE matnr = mseg-matnr
                 AND   werks = mseg-werks
                 AND   sobkz = o.
      MOVE-CORRESPONDING ls_fuss TO ls_bfstock.

      if ls_bfstock-erfme ne ls_bfstock-meins
      and ls_bfstock-menge is initial.
* ls_bfstock-menge isn't initial in case of BAPI call or
* Idoc procesing !!
        CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
          EXPORTING
            input   = ls_bfstock-erfmg
            kzmeinh = 'X'
            matnr   = ls_bfstock-matnr
            meinh   = ls_bfstock-erfme
            meins   = ls_bfstock-meins
          IMPORTING
            output  = l_menge
          EXCEPTIONS
            others  = 4.
        ls_bfstock-menge = l_menge.
        clear l_menge.
      endif.
      COLLECT ls_bfstock INTO lt_bfstock.
    ENDLOOP.
    LOOP AT gt_gocomp INTO ls_gocomp
            WHERE matnr = mseg-matnr
            AND   werks = mseg-werks
            AND   charg <> SPACE.
*     consider only lines that were not already added to fuss,
*     because they were already added to bf_stock in the loop over
*     fuss above.
      read table lt_used_lines transporting no fields
                               with key
                               line_id = ls_gocomp-global_counter.
      check sy-subrc <> 0.
      MOVE-CORRESPONDING ls_gocomp TO ls_bfstock.

      if ls_bfstock-erfme ne ls_bfstock-meins
        and ls_bfstock-menge is initial.
        CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
          EXPORTING
            input   = ls_bfstock-erfmg
            kzmeinh = 'X'
            matnr   = ls_bfstock-matnr
            meinh   = ls_bfstock-erfme
            meins   = ls_bfstock-meins
          IMPORTING
            output  = l_menge
          EXCEPTIONS
            others  = 4.
        ls_bfstock-menge = l_menge.
        clear l_menge.

      else.
        ls_bfstock-menge = ls_bfstock-erfmg.
      endif.

      ls_bfstock-sobkz = o.
      COLLECT ls_bfstock INTO lt_bfstock.
    ENDLOOP.

    IF NOT lt_bfstock IS INITIAL.
      CALL FUNCTION 'BF_SET_LOC_ENQ_TAB'
        EXPORTING
          lifnr     = fuss-lifnr
        TABLES
          l_bfstock = lt_bfstock.
    ENDIF.
    xbdcom-kzvbp = 'L'.
    clear xbdcom-lbbsa.
  ENDIF.

ENHANCEMENT-POINT EHP603_CHARGENFINDUNG_01 SPOTS ES_MM07MFCL_CHARGENFINDUNG_SHL.


* Chargenfindung / Prüfung
ENHANCEMENT-SECTION     CHARGENFINDUNG_01 SPOTS ES_SAPMM07M.
  CALL FUNCTION 'VB_BATCH_DETERMINATION'
    EXPORTING
      i_komkh    = xkomkh
      i_komph    = xkomph
      x_bdcom    = xbdcom
    IMPORTING
      e_problems = vw
      x_bdcom    = xbdcom
    TABLES
      e_bdbatch  = e_bdbatch
      i_bdbatch  = i_bdbatch
      i_mdva     = mdva
      i_atpcsx   = atpcsx
      e_atpcsx   = e_atpcsx
    EXCEPTIONS
      OTHERS     = 4.
END-ENHANCEMENT-SECTION.

  IF NOT sy-subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENHANCEMENT-POINT CHARGENFINDUNG_02 SPOTS ES_SAPMM07M.
  CLEAR vw.

* Ergebnis Findung
  IF loc_action EQ f.
    LOOP AT e_bdbatch.
      ylgort-kzchf    = x.
      ylgort-xselp    = x.
      ylgort-zeile    = mseg-zeile.
*   BF_STOCK_DETERMINATION might return a different SOBKZ than
*   MSEG-SOBKZ. Therefore we have to read T156B to find the correct
*   UMSOK. This ensures that our quantity enqueue tables are build up.
      if l_complement = x.
        e_bdbatch-sobkz = mseg-sobkz.
      endif.
      CLEAR: ylgort-umsok.
      SELECT SINGLE umsok FROM t156b
                          INTO ylgort-umsok
                          WHERE bwart = mseg-bwart
                          AND   sobkz = e_bdbatch-sobkz.
      ylgort-matnr    = e_bdbatch-matnr.
      ylgort-werks    = e_bdbatch-werks.
      ylgort-lgort    = e_bdbatch-lgort.
      ylgort-charg    = e_bdbatch-charg.
      ylgort-menge    = e_bdbatch-menge.
      ylgort-meins    = e_bdbatch-meins.
      ylgort-erfmg    = e_bdbatch-erfmg.
      ylgort-erfme    = e_bdbatch-erfme.
      ylgort-cuobj_ch = xbdcom-cuobj.
      ylgort-lifnr    = e_bdbatch-lifnr.
      IF dm07m-kzuml IS INITIAL.
        IF NOT mseg-sobkz IS INITIAL.
          ylgort-sobkz = mseg-sobkz.
        ELSE.
          ylgort-sobkz = e_bdbatch-sobkz.
        ENDIF.
      ELSE.
        IF NOT mseg-umsok IS INITIAL.
          ylgort-sobkz = mseg-umsok.
        ELSE.
          ylgort-sobkz = e_bdbatch-sobkz.
        ENDIF.
      ENDIF.
      IF NOT l_complement IS INITIAL.
        ylgort-werks = mseg-werks.
        ylgort-lgort = mseg-lgort.
        ylgort-sobkz = mseg-sobkz.
      ENDIF.
      APPEND ylgort.
      xbdcom-erfmg = xbdcom-erfmg - ylgort-erfmg.
    ENDLOOP.

*-- Konnte die angeforderte Menge befiedigt werden?
    IF xbdcom-erfmg > 0.
      DATA: loc_text(20) TYPE c.
      DATA: loc_text2(3) TYPE c.
      WRITE xbdcom-erfmg TO loc_text NO-ZERO LEFT-JUSTIFIED.
      WRITE mseg-erfme TO loc_text2 NO-ZERO LEFT-JUSTIFIED.
      IF MSEG-SHKZG = 'S'.
        CALL FUNCTION 'MB_CHECK_T160M'
          EXPORTING
            I_ARBGB  = 'M7'
            I_msgnr  = '389'
            I_MSGV1  = MSEG-MATNR
            I_MSGV2  = LOC_TEXT
            I_MSGV3  = LOC_TEXT2
            I_OUTPUT = X.
      ELSE.
        CALL FUNCTION 'MB_CHECK_T160M'
          EXPORTING
            I_ARBGB  = 'LB'
            I_msgnr  = '031'
            I_MSGV1  = MSEG-MATNR
            I_MSGV2  = LOC_TEXT
            I_MSGV3  = LOC_TEXT2
            I_OUTPUT = X.
      ENDIF.
    ENDIF.
  ENDIF.

* Ergebnis Prüfung
  DATA: lv_table LIKE tcla-obtab.
  IF loc_action EQ p.
    IF NOT xmigo IS INITIAL AND NOT xsimu IS INITIAL.
      IF NOT xbdcom-cuobj IS INITIAL.
        CALL FUNCTION 'CUOB_GET_OBJECT'
          EXPORTING
            object_number = xbdcom-cuobj
          IMPORTING
            table         = lv_table
          EXCEPTIONS
            not_found     = 1
            OTHERS        = 2.
        IF lv_table EQ cl_mseg.
          CALL FUNCTION 'CLFM_CLEAR_CLASSIFICATION'
            EXPORTING
              object           = xbdcom-objec
              puffer_only      = 'X'
              table            = cl_mseg
            EXCEPTIONS
              foreign_lock     = 1
              system_failure   = 2
              table_not_found  = 3
              date_not_allowed = 4
              not_deleted      = 5
              OTHERS           = 6.
        ENDIF.
      ENDIF.
    ELSE.
      mseg-cuobj_ch = xbdcom-cuobj.
    ENDIF.
    READ TABLE e_bdbatch INDEX 1.
    IF sy-subrc IS INITIAL.
      IF e_bdbatch-subrc = 8.                                   "1165339
        PERFORM nachrichtencode_ermitteln(sapfm07m) USING 'LB' '051'.
      ENDIF.
    ELSE.
      MESSAGE e001(m7) WITH 'E_BDBATCH' '1'.
    ENDIF.
  ENDIF.

ENDFORM.                    "CHARGENFINDUNG