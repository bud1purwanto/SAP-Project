*eject.
*----------------------------------------------------------------------*
*          Serialnummern werden für die Position gepflegt              *
*----------------------------------------------------------------------*
FORM serialnummern_pflegen.
  CHECK t156-kzwes NE s OR
      ( t156-kzwes EQ s AND vm07m-lbbsa EQ '10' ).              "SIT
  DATA: cuobj LIKE dm07m-cuobj,
        stdpd LIKE dm07m-stdpd,
        lv_check_anzsn TYPE xfeld.                              "1639087
  CLEAR: xanzsn,
         imenge,
         cuobj,
         stdpd,
         bstch,
         bstup.
  IF xmigo <> space AND xcanc <> space.                     "ckm
    CHECK xsimu = space.                                    "ckm
  ENDIF.                                                    "ckm
  IF t158-trtyp NE h.
    smblnr = mkpf-mblnr.
  ELSE.
    smblnr = dmblnr.
  ENDIF.
  IF t158-trtyp EQ v.
    strtyp = a.
  ELSE.
    strtyp = t158-trtyp.
  ENDIF.
  xanzsn = mseg-menge / 1000.
  imenge = xanzsn * 1000.
  IF mseg-menge NE imenge.
* BEGIN OF NOTE 1639087                                        "1639087
    CALL FUNCTION 'MB_CHECK_T160M'
       EXPORTING
            i_arbgb  = 'M7'
            i_msgnr  = '172'
            i_output = space
       IMPORTING
            rc       = rc.
    IF rc = 0.
*     new logic, allow decimal for optional serialization
      lv_check_anzsn = 'X'. "check again after serno import!!!
      IF i_t377-serpflicht NE '02'.
        MESSAGE e172.
      ENDIF.
    ELSE.
*     deny
      MESSAGE e172.
    ENDIF.
* END OF NOTE 1639087                                          "1639087
  ENDIF.

*  bstch-b_relev = bstup-b_relev = x.                        "note204581
  PERFORM stkt_befue_fuel USING mseg-bustm.
  IF NOT dm07m-kzuml IS INITIAL AND t156-shkzg = s.
    cuobj    = dm07m-ucuob.
    stdpd    = dm07m-ustdp.
    matnum   = mseg-ummat.
    ummatnum = mseg-matnr.
    charge   = mseg-umcha.
  ELSE.
    cuobj    = dm07m-cuobj.
    stdpd    = dm07m-stdpd.
    matnum   = mseg-matnr.
    ummatnum = mseg-ummat.
    charge   = mseg-charg.
  ENDIF.
* Proposal of serialnumbers only for reversals
* and complete return deliveries.
  IF vm07m-xstor = 2.
*  or ( vm07m-xstor = 1 and mseg-menge = fuss-menge ).
    DATA: smblp               TYPE mseg-smblp,              "MAA2
          lo_mmim_maa_2       TYPE  REF TO cl_mmim_maa_2,   "MAA2
          lt_mseg_refdoc      type  mb_mseg,                "MAA2
          ls_mseg_refdoc      type  mseg.                   "MAA2
    IF mseg-xmacc IS INITIAL.                               "MAA2
      smblp = mseg-smblp.                                   "MAA2
    ELSE.                                                   "MAA2
      lo_mmim_maa_2 = cl_mmim_maa_2=>get_singleton_instance( )."MAA2
      CALL METHOD lo_mmim_maa_2->maa_read_mseg_refdoc       "MAA2
                 IMPORTING                                  "MAA2
                 et_mseg_refdoc       = lt_mseg_refdoc[].   "MAA2
*     get line from original mseg                           "MAA2
      READ TABLE lt_mseg_refdoc INTO ls_mseg_refdoc         "MAA2
            WITH KEY mblnr     = mseg-smbln                 "MAA2
                     mjahr     = mseg-sjahr                 "MAA2
                     maa_urzei = mseg-smblp                 "MAA2
                     ebeln     = mseg-ebeln                 "MAA2
                     ebelp     = mseg-ebelp                 "MAA2
                     zekkn     = mseg-zekkn.                "MAA2
      IF sy-subrc IS INITIAL.   "EHP6 doc                   "MAA2
        smblp = ls_mseg_refdoc-zeile.                       "MAA2
      ELSE.                     "EHP4/5 doc                 "MAA2
        smblp = mseg-smblp.                                 "MAA2
      ENDIF.                                                "MAA2
    ENDIF.                                                  "MAA2
    strtyp = a.
    PERFORM serialnummern_kopieren USING  matnum
                                          ummatnum
                                          dm07m-sernp
                                          xanzsn
                                          dmblnr
                                          mseg-smbln
                                          mseg-sjahr
                                          mkpf-mjahr        "321098
*                                          mseg-smblp       "MAA2
                                          smblp             "MAA2
                                          mseg-zeile
                                          mkpf-blart
                                          mseg-bwart
                                          mseg-shkzg
                                          mseg-werks
                                          mseg-lgort
                                          charge
                                          cuobj
                                          vm07m-vrgng
                                          s156s-snbwg
                                          stdpd
                                          mseg-charg.       "1131392
* reversals with optional serial number handling:
* Check if there are serial numbers connected to the material document
* which is to be reversed
* If not no popup is needed -> leave this form.
* If yes - copy the serial numbers to the reversal document
    IF i_t377-serpflicht EQ nzwei.                          "note419362
      CHECK NOT dm07m-anzsn IS INITIAL.                     "note419362
    ENDIF.                                                  "note419362

  ENDIF.
  IF NOT ( xcanc = x AND xmbwl = x ).  "no dialog for bapi
    "or mb_cancel...
*  In case of BAPI/MIGO only form SER_WE_WA is useful
    IF xbapi IS INITIAL AND xmigo IS INITIAL.               "458137
      IF s156s-kzbew = f AND ccode NE ccod-nser
                         AND fcode NE fcod-kp.
        PERFORM ser_fauf.
        IF i_t377-serpflicht EQ nzwei.
          CHECK NOT dm07m-anzsn IS INITIAL.
        ENDIF.
        IF NOT dm07m-anzsn IS INITIAL.
          upd_seri = x.
        ENDIF.
      ENDIF.
* s156s-kzbew = l for GR of delivery items which have been added in the
* delivery (not contained in the PO)
      IF ( s156s-kzbew = b OR im_process = l OR s156s-kzbew = l ) "385402
           AND ( NOT vm07m-vbeln IS INITIAL                 "491680
                 OR NOT dm07m-vbeln_vl IS INITIAL )         "491680
           AND ccode NE ccod-nser AND fcode NE fcod-kp.     "491680
        PERFORM ser_lief_we.
        IF i_t377-serpflicht EQ nzwei.              "note 393941
*     no serial numbers in delivery and optional serialization -> no
*     automatic popup during goods receipt
          CHECK NOT dm07m-anzsn IS INITIAL.         "note 393941
        ENDIF.                                      "note 393941
        IF NOT dm07m-anzsn IS INITIAL.
          upd_seri = x.
        ENDIF.
      ENDIF.
ENHANCEMENT-SECTION MM07MSE0_SERIALNUMMERN_PFLE_01 SPOTS ES_SAPMM07M .
      IF s156s-kzbew = b AND ccode NE ccod-nser                  "1523905
                         AND fcode NE fcod-kp.                   "1523905
        PERFORM ser_po_we.                                       "1523905
        IF i_t377-serpflicht EQ nzwei.                           "1523905
          CHECK NOT dm07m-anzsn IS INITIAL.                      "1523905
        ENDIF.                                                   "1523905
        IF NOT dm07m-anzsn IS INITIAL.                           "1523905
          upd_seri = x.                                          "1523905
        ENDIF.                                                   "1523905
      ENDIF.                                                     "1523905
END-ENHANCEMENT-SECTION.
    ENDIF.                                                  "458137
    PERFORM ser_we_wa USING cuobj
                            stdpd.
  ENDIF.

* BEGIN OF NOTE 1639087                                        "1639087
  IF lv_check_anzsn IS NOT INITIAL
*   new logic, allow decimal for optional serialization, but not if
*   serial numbers have been entered
    AND i_t377-serpflicht EQ '02' AND dm07m-anzsn IS NOT INITIAL.
      MESSAGE e172.
  ENDIF.
* END OF NOTE 1639087                                          "1639087

  IF t158-trtyp = h.
    IF dm07m-anzsn > xanzsn.                                "note330079
*   regardless if serialisation is obligatory or mandatory it is never
*   allowed to post too many serialnumbers.
      MESSAGE e175.                                         "note330079
    ELSEIF dm07m-anzsn NE xanzsn.                           "note330079
      PERFORM serialpflicht_ermitteln.
      IF i_t377-serpflicht = ndrei.
*------ Bei Zustandsänderung darf keine Fehlermeldung kommen
        IF mseg-bwart EQ bwart_341 OR mseg-bwart EQ bwart_342.
          IF cl_uid_cust=>get_uid_used( cl_uid_cust=>gc_iuid ) IS INITIAL. "EHP603-IUID
            MESSAGE w175.
          ELSE.
            MESSAGE w052(iuid) WITH xanzsn dm07m-anzsn.   "EHP603-IUID
          ENDIF.
        ELSE.
          IF cl_uid_cust=>get_uid_used( cl_uid_cust=>gc_iuid ) IS INITIAL. "EHP603-IUID
            MESSAGE e175.
          ELSE.
            MESSAGE e052(iuid) WITH xanzsn dm07m-anzsn.  "EHP603-IUID
          ENDIF.
        ENDIF.
      ELSE.
        IF cl_uid_cust=>get_uid_used( cl_uid_cust=>gc_iuid ) IS INITIAL. "EHP603-IUID
          MESSAGE w175.
        ELSE.
          MESSAGE w052(iuid) WITH xanzsn dm07m-anzsn.     "EHP603-IUID
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    IF NOT dm07m-sernp IS INITIAL AND dm07m-anzsn NE xanzsn.
      MESSAGE s173 WITH mseg-matnr.
    ENDIF.
  ENDIF.
  IF NOT dm07m-anzsn IS INITIAL.
    upd_seri = x.
  ENDIF.
ENDFORM.                    "serialnummern_pflegen