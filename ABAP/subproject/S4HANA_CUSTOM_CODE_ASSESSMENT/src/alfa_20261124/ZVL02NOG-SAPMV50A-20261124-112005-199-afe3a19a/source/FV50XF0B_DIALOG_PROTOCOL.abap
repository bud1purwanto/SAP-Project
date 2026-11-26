*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_DIALOG_PROTOCOL                                   *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM DIALOG_PROTOCOL                                          *
*---------------------------------------------------------------------*
*       Save a protocol in dialog like in a collective run
*---------------------------------------------------------------------*
form dialog_protocol tables it_xlikp structure likpvb
                            it_vbfs structure vbfs.
  constants:
    lc_smart type SMART value 'L'.

  data:
    lf_active type c,
    lf_sammg type SAMMG,
    ls_vbsk type VBSK,
    lt_vbsk type table of VBSK,
    lt_vbss type table of VBSS,
    lf_rc type SYSUBRC.

* not in a collective run
  check v50agl-sammelgang is initial and
        vbsk-sammg is initial and
        not v50agl-dialog is initial.

* delete previous protocol
  delete it_vbfs where zaehl = '00'.                           "n_832543
  get parameter id 'LE_SHP_LOG_GRN' field lf_sammg.
  if not lf_sammg is initial.
    delete it_vbfs where sammg = lf_sammg.
  endif.
  clear lf_sammg.
  set parameter id 'LE_SHP_LOG_GRN' field lf_sammg.

  check not it_vbfs[] is initial.

* only when activated
  get parameter id 'LE_SHP_LOG' field lf_active.
  check not lf_active is initial.

* create VBSK, VBSS and let VBFS refer to this group
  perform log_create tables it_xlikp
                            it_vbfs
                            lt_vbss
                      using lc_smart
                   changing ls_vbsk
                            lf_rc.

  check lf_rc is initial.
  set parameter id 'LE_SHP_LOG_GRN' field ls_vbsk-sammg.

* update
  append ls_vbsk to lt_vbsk.

  insert VBSK from table lt_vbsk.
  insert VBSS from table lt_vbss.
  insert VBFS from table it_vbfs.
endform.


*---------------------------------------------------------------------*
*       FORM LOG_CREATE                                               *
*---------------------------------------------------------------------*
*       Create VBSK, VBSS, VBFS
*---------------------------------------------------------------------*
form log_create tables it_xlikp structure LIKPVB
                       ct_vbfs structure VBFS
                       et_vbss structure VBSS
                 using if_smart like vbsk-smart
              changing es_vbsk type VBSK
                       cf_rc type SYSUBRC.
  data:
    ls_vbss type VBSS,
    n type i.

  field-symbols:
    <ls_xlikp> type LIKPVB.

  cf_rc = 1.
* VBSK
  perform log_create_vbsk using if_smart
                       changing es_vbsk
                                cf_rc.
  check cf_rc eq 0.

* VBSS
  ls_vbss-mandt = es_vbsk-mandt.
  ls_vbss-sammg = es_vbsk-sammg.
  loop at it_xlikp assigning <ls_xlikp>.
    ls_vbss-vbeln = <ls_xlikp>-vbeln.
    append ls_vbss to et_vbss.
  endloop.

* VBFS
  perform log_create_vbfs tables ct_vbfs
                           using ls_vbss-vbeln
                                 es_vbsk-sammg
                                 es_vbsk-smart.


  describe table ct_vbfs lines n.
  es_vbsk-ernum = n.
  describe table et_vbss lines n.
  es_vbsk-vbnum = n.

  clear cf_rc.
endform.

*---------------------------------------------------------------------*
*       FORM LOG_CREATE_VBSK                                          *
*---------------------------------------------------------------------*
*       Create VBSK
*---------------------------------------------------------------------*
form log_create_vbsk using if_smart type SMART
                  changing cs_vbsk type VBSK
                           cf_rc type SYSUBRC.

  data:
    ls_tvsa type TVSA,
    lf_sammg type SAMMG.

  cf_rc = 1.

  select single * from TVSA into ls_tvsa
    where smart = if_smart.
  check sy-subrc eq 0.

  CALL FUNCTION 'NUMBER_GET_NEXT'
       EXPORTING
            NR_RANGE_NR = ls_tvsa-numki
            OBJECT      = 'RV_SAMMG'
       IMPORTING
            NUMBER      = lf_sammg.

  select single *  from VBSK into cs_vbsk
    where sammg = lf_sammg.
  check sy-subrc ne 0. "number must be unique among all group types

  clear cs_vbsk.
  cs_vbsk-mandt = sy-mandt.
  cs_vbsk-sammg = lf_sammg.
  cs_vbsk-ernam = sy-uname.
  cs_vbsk-erdat = sy-datum.
  cs_vbsk-uzeit = sy-uzeit.
  cs_vbsk-smart = if_smart.
  cs_vbsk-programm = sy-repid.
  cs_vbsk-selset = sy-slset.
  cs_vbsk-batch = sy-batch.

  clear cf_rc.
endform.

*---------------------------------------------------------------------*
*       FORM LOG_CREATE_VBFS                                          *
*---------------------------------------------------------------------*
*       Create VBFS incl. VL592
*---------------------------------------------------------------------*
form log_create_vbfs tables ct_vbfs structure vbfs
                      using if_vbeln type VBELN_VL
                            if_sammg type SAMMG
                            if_smart type SMART.
  data:
    lf_tcode type SYTCODE,
    lf_mode type c,
    lf_msg type c,
    ls_vbfs type VBFS.

  field-symbols:
    <ls_vbfs> type VBFS.

* tcode
  lf_tcode = sy-tcode.
  if t180-trtyp eq charv.
    lf_mode = lf_tcode+3.
    replace '3' with '2' into lf_mode.
    lf_tcode+3(1) = lf_mode.
  endif.

* insert VL592
  message S592(VL) with lf_tcode sy-datum sy-uzeit sy-uname
    into lf_msg.
  ls_vbfs-mandt = sy-mandt.
  ls_vbfs-sammg = if_sammg.
  ls_vbfs-smart = if_smart.
  ls_vbfs-vbeln = if_vbeln.
  ls_vbfs-zaehl  = 1.
  ls_vbfs-msgid = sy-msgid.
  ls_vbfs-msgno = sy-msgno.
  ls_vbfs-msgty = sy-msgty.
  ls_vbfs-msgv1 = sy-msgv1.
  ls_vbfs-msgv2 = sy-msgv2.
  ls_vbfs-msgv3 = sy-msgv3.
  ls_vbfs-msgv4 = sy-msgv4.
  insert ls_vbfs into ct_vbfs index 1.

* change sammg, smart, zaehl of old vbfs entries
  loop at ct_vbfs assigning <ls_vbfs> from 2.
    <ls_vbfs>-sammg = ls_vbfs-sammg.
    <ls_vbfs>-smart = ls_vbfs-smart.
    <ls_vbfs>-zaehl = <ls_vbfs>-zaehl + 1.
  endloop.

endform.

*---------------------------------------------------------------------*
*       FORM LOG_GET                                                  *
*---------------------------------------------------------------------*
*       Get last protocol
*---------------------------------------------------------------------*
form log_get tables et_vbfs structure vbfs
              using if_vbeln type VBELN_VL.
  constants:
    lc_smart type SMART value 'L'.

  data:
    lf_sammg type SAMMG,
    lt_vbss type table of VBSS,
    lt_vbsk type table of VBSK.

  field-symbols:
    <ls_vbsk> type VBSK.

  check not if_vbeln is initial.

* last protocol
  get parameter id 'LE_SHP_LOG_GRN' field lf_sammg.
  if not lf_sammg is initial.
    select * from VBFS into table et_vbfs
      where sammg = lf_sammg.
    read table et_vbfs transporting no fields
      with key vbeln = if_vbeln.
    if sy-subrc eq 0.
      et_vbfs-sammg = lf_sammg. "RV_TREE_LIST_DISPLAY is using this
      exit.
    endif.
  endif.

* last protocol from different delivery -> forget protocol
  refresh et_vbfs.
  clear lf_sammg.
  set parameter id 'LE_SHP_LOG_GRN' field lf_sammg.

* last protocol of vbeln
  select * from VBSS into table lt_vbss
    where vbeln = if_vbeln.
  check sy-subrc eq 0.

  select * from VBSK into table lt_vbsk
    for all entries in lt_vbss
    where sammg = lt_vbss-sammg and
          smart = lc_smart.
  check sy-subrc eq 0.

  sort lt_vbsk descending by erdat uzeit.
  read table lt_vbsk assigning <ls_vbsk> index 1.
  set parameter id 'LE_SHP_LOG_GRN' field <ls_vbsk>-sammg.

  select * from VBFS into table et_vbfs
    where sammg = <ls_vbsk>-sammg.
  et_vbfs-sammg = lf_sammg. "RV_TREE_LIST_DISPLAY is using this
endform.
*&---------------------------------------------------------------------*