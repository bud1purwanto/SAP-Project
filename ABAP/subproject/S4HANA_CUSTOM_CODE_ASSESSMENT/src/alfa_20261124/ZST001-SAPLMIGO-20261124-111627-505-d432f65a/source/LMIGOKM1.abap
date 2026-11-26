*----------------------------------------------------------------------*
*   INCLUDE LMIGOKM1                                                   *
*----------------------------------------------------------------------*

* Feb 2009 MM                                               "n1306620
* enable MIGO to display MM docs from the AIS archive, too  "n1306620

* Sept 2002 MM                                                  "n555246
* log function tax auditor                                      "n555246

***********************************************************************
* read material document and modify t_goitem (internal)
***********************************************************************
METHOD materialdocument_get.

*-------------------- field symbols -----------------------------------
  FIELD-SYMBOLS: <ls_mseg> TYPE mseg,
                 <ls_goitem> TYPE goitem,
                 <ls_parent> TYPE goitem.

*-------------------- local data -------------------------------------
* help data
  DATA:
        l_fcode  TYPE t156n-fcode,        "for matdoc_fill_data
        l_evers  TYPE goitem-evers,       "shipping instruction
        ls_tstct TYPE tstct,              "text for transaction code
        l_refdoc_involved TYPE abap_bool, "nec. to get information on
                                          "how to deal with special
                                          "stock e resp. q
        ls_vendordata TYPE lfa1.

* for material document
  DATA: ls_goitem TYPE goitem.

* for output determination
  DATA: ls_nastkey TYPE ty_s_nastkey,
        lt_nastkey TYPE ty_t_nastkey.

* serial numbers
  DATA: lt_goserial        TYPE ty_t_goserial,
        ls_vepwe           TYPE vepwe.                      "731711
  DATA: ls_goserial_kernel TYPE ty_s_goserial_kernel.

* Clear of WM-data
  DATA: ls_gowm1 TYPE gowm1,
        ls_gowm2 TYPE gowm2.

* for foreign trade
  DATA: l_expos     TYPE expos.        "item number

* call mb_read_material_header
  DATA: ls_mkpf TYPE mkpf.             "MatDoc header data

* call mb_read_material_position
  DATA: lt_mseg TYPE TABLE OF mseg,
        ls_mseg_temp TYPE mseg.

* this flag is set when the MM doc was found in the archive "n1306620
  DATA : lv_flag_archive     TYPE  abap_bool.               "n1306620

  DATA:  lv_pstyp            TYPE pstyp.                     "1525459

  DATA : ls_msg              TYPE  bapiret2.

* working fields place in storage to copy and read
  DATA: BEGIN OF ls_mseg_place,
         mblnr TYPE goitem-mblnr,      "needed to read serial numbers
         mjahr TYPE goitem-mjahr,      "needed to read serial numbers
         zeile TYPE goitem-zeile,      "needed to read serial numbers
         matnr TYPE goitem-matnr,
         ummat TYPE goitem-ummat,      "for different behaviour to MBSU
         werks TYPE goitem-werks,
         bwart TYPE goitem-bwart,
         kzbew TYPE goitem-kzbew,
         umwrk TYPE goitem-umwrk,
         umlgo TYPE goitem-umlgo,
         charg TYPE goitem-charg,
         umcha TYPE goitem-umcha,
         erfmg TYPE goitem-erfmg,
         erfme TYPE goitem-erfme,
         kunnr TYPE goitem-kunnr,
         ebeln TYPE goitem-ebeln,
         ebelp TYPE goitem-ebelp,
         mwskz TYPE goitem-mwskz,
         umsok TYPE goitem-umsok,     " OM EhP 604, needed for new SC & cust-consi in-transfer stock
         lifnr TYPE goitem-lifnr.     " OM EhP 604  needed for new SC & cust-consi in-transfer stock
ENHANCEMENT-POINT lmigokm1_02 SPOTS es_saplmigo STATIC.

  DATA:    j_1bexbase TYPE goitem-j_1bexbase,
          END OF ls_mseg_place.

* --- IS ADEC GPD EhP4 declarations
  DATA: ls_st156s  TYPE st156s,
        lv_pspnr   TYPE prps-pspnr,
        lv_grp2grp TYPE xflag.

* Relevant fields that are to be copied from MSEG in case of a goods
* receipt /  goods issue / transfer posting related to a material
* document.  Needed in materialdocument_get as well as in line_check,
* therefore, the type is being defined here.                     ERP 10
  DATA: BEGIN OF ls_mseg_copy,
         matnr      TYPE mseg-matnr,
         werks      TYPE mseg-werks,
         lgort      TYPE mseg-lgort,
         charg      TYPE mseg-charg,
*        the WM-related fields  lgnum, lgtyp, lgpla, bwlvs, tbnum,
*        tbpos, ubnum and tbpri are being cleared from psgoitem
*        via ls_gowm1 and ls_gowm2, as they are to be determined anew
*        with every movement-> they will not be taken from the document.
         parbu      TYPE mseg-parbu,
         pargb      TYPE mseg-pargb,
         ummat      TYPE mseg-ummat,
         umwrk      TYPE mseg-umwrk,
         umlgo      TYPE mseg-umlgo,
         umcha      TYPE mseg-umcha,
         sobkz      TYPE mseg-sobkz,
         insmk      TYPE mseg-insmk,
         bwart      TYPE mseg-bwart,
*        kzbew is deliberately being cleared by not including it here,
*        as the copy function is only intended for material documents
*        without related docs.
         erfmg      TYPE mseg-erfmg,
         erfme      TYPE mseg-erfme,
         wempf      TYPE mseg-wempf,
         ablad      TYPE mseg-ablad,
         sgtxt      TYPE mseg-sgtxt,
         grund      TYPE mseg-grund,
*        bwtar is deliberately being cleared, too. In case of split-
*        valuated as well as in case of batch-managed & split valuated
*        materials, the field charg is filled with valuation type /
*        batch number and can be used to determine bwtar.
         sakto      TYPE mseg-sakto,
         kostl      TYPE mseg-kostl,
*        only pprctr is being copied, as it contains the accounting-
*        profit center. prctr contains the material-profit center and
*        will be determined later on (depends on matnr-werks-
*        combination )
         pprctr     TYPE mseg-pprctr,
         ebeln      TYPE mseg-ebeln,
         ebelp      TYPE mseg-ebelp,
         aufnr      TYPE mseg-aufnr,
         aufps      TYPE mseg-aufps,
         lifnr      TYPE mseg-lifnr,
         kunnr      TYPE mseg-kunnr,
         kdauf      TYPE mseg-kdauf,
         kdpos      TYPE mseg-kdpos,
         ps_psp_pnr TYPE mseg-ps_psp_pnr,
         mat_kdauf  TYPE mseg-mat_kdauf,
         mat_kdpos  TYPE mseg-mat_kdpos,
         umsok      TYPE mseg-umsok,                        "1453570
         mat_pspnr  TYPE mseg-mat_pspnr,
*        Tax-related fields for Brazil / US
*        These fields shall be copied, too, according to internat. dev.
         mwskz      TYPE mseg-mwskz,
         txjcd      TYPE mseg-txjcd,
         j_1bexbase TYPE mseg-j_1bexbase,
  END OF ls_mseg_copy.

* needed to read migo_t156 for checks when taking a material
* documents as a template for a new posting                       ERP 10
  DATA: ls_migo_t156 TYPE migo_t156.

* for the cancelled material document items
  DATA: ls_gocancel  TYPE gocancel.
  DATA: ls_t159n     TYPE t159n.
  DATA: ls_control   TYPE ty_s_control.
  DATA: lt_cancelled TYPE SORTED TABLE OF mblpo
                          WITH UNIQUE KEY table_line,
        ls_cancelled TYPE mblpo.

* for material_prefetch_read
  DATA: lt_prefetch02 TYPE ty_t_prefetch02,
        lt_prefetch03 TYPE ty_t_prefetch03,
        ls_prefetch02 TYPE ty_s_prefetch02,
        ls_prefetch03 TYPE ty_s_prefetch03.

* Delivery flow data
  DATA:                                                     "358454
    ls_mbvbfa TYPE mbvbfa,
    lt_mbvbfa TYPE STANDARD TABLE OF mbvbfa.

* Field is used to call method MODE_SET in order to set the correct
* (MIGO_MODE = 'GT' in case of a transfer posting):
  DATA:
    l_transfer TYPE abap_bool VALUE abap_false.

* In Brazil UMWRK is needed for place in storage.               "804327
  DATA: lv_brazil TYPE xfeld,                               "804327
        lv_br_werks TYPE werks_d.                           "804327

  DATA: ls_ekko TYPE ekko.                                 "Note 875529

* Set the parent_id of automatic transfer lines of a structured article
  DATA: l_parent_st TYPE goitem-parent.

************************ matdoc_read_data ******************************

* several matdocs in two years => popup
  CALL FUNCTION 'MB_READ_MATERIAL_HEADER'
    EXPORTING
      mblnr         = i_mat_doc
      mjahr         = c_doc_year
      trtyp         = a          "Display --> no enqueue
    IMPORTING
      kopf          = ls_mkpf
    EXCEPTIONS
      error_message = 1.

* --- begin of changes -------------------------------------"n1306620
* enable MIGO to display MM docs from the AIS archive, too  "n1306620
  IF s_action-display =  abap_true   AND
     sy-subrc         <> 0           AND
     sy-msgty         =  E           AND
     sy-msgid         = 'M7'         AND
     sy-msgno         = '062'.

*   save error message :
*   Document & does not exist in calendar year &
    MESSAGE  e062(m7)        WITH i_mat_doc c_doc_year
                             INTO  ls_msg-message.
    MOVE : 'M7'              TO  ls_msg-id,
           E                 TO  ls_msg-type,
           sy-msgno          TO  ls_msg-number,
           sy-msgv1          TO  ls_msg-message_v1,
           sy-msgv2          TO  ls_msg-message_v2,
           sy-msgv3          TO  ls_msg-message_v3,
           sy-msgv4          TO  ls_msg-message_v4.

*   try to find the MM doc in the AIS arcive
    CALL METHOD material_doc_from_archive
      EXPORTING
        i_mat_doc        = i_mat_doc
        i_doc_year       = c_doc_year
      CHANGING
        cs_mkpf          = ls_mkpf
        ct_mseg          = lt_mseg
        cv_flag_archive  = lv_flag_archive.

    IF  lv_flag_archive = abap_true.
      CLEAR                  sy-subrc.
    ELSE.
*     sorry, not found in the archive -> send error messag
      def_msg_add oref_doc_log
                             ls_msg-type
                             ls_msg-id
                             ls_msg-number
                             ls_msg-message_v1
                             ls_msg-message_v2
                             ls_msg-message_v3
                             ls_msg-message_v4.
      EXIT.
    ENDIF.
  ENDIF.
* --- end   of changes -------------------------------------"n1306620

  IF sy-subrc <> 0.
    def_msg_add oref_doc_log sy-msgty sy-msgid sy-msgno
                             sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.
* Check whether material document is permitted for the current
* transaction mode.
  sy-subrc = 0.
* Cancel only for matdocs created by Inventory Management.
  IF s_action-cancel = abap_true
     AND NOT ( 'WE WF WA WO' CS ls_mkpf-vgart ).
    def_msg_add oref_doc_log e 'M7' '130' space space space space.
    EXIT.
  ENDIF.
* Return only for matdocs created by Inventory Management and not for
* subsequent adjustment.
  IF s_action-return = abap_true
     AND NOT ( 'WE WF WA' CS ls_mkpf-vgart ).
    def_msg_add oref_doc_log e 'M7' '130' space space space space.
    EXIT.
  ENDIF.
* These actions only for WE documents
  IF ( s_action-release    = abap_true OR
       s_action-subsequent = abap_true )
      AND ls_mkpf-vgart <> 'WE'.
ENHANCEMENT-SECTION     MATERIALDOCUMENT_GET_02 SPOTS ES_SAPLMIGO.
    def_msg_add oref_doc_log e 'M7' '130' space space space space.
    EXIT.
END-ENHANCEMENT-SECTION.
  ENDIF.
* Postings related to a material document are only permitted if one uses
* material documents that had no reference documents, i.e. that were
* either a 'Goods issue Others', 'Goods receipt Others', or a
* 'Transfer postings Others' => VGART has always to be 'WA'       ERP 10
  IF s_action-copy = abap_true AND
     ls_mkpf-vgart <> 'WA'.
    def_msg_add oref_doc_log e 'MIGO' '067' space space space space.
    EXIT.
  ENDIF.
* MSR Returns
* Only cancellation and display is allowed for an MSR material document
  IF cl_ops_switch_check=>ops_sfws_sc_advret1( ) = abap_true.
    IF ( s_action-return = abap_true OR s_action-copy   = abap_true ) AND
         ls_mkpf-msr_active = abap_true.
      def_msg_add oref_doc_log e 'MIGO' '067' space space space space.
      EXIT.
    ENDIF.
  ENDIF.
* Issue message if any check failed.
  IF sy-subrc <> 0.
    def_msg_add oref_doc_log e 'M7' '130' space space space space.
    EXIT.
  ENDIF.
* Return the received material document year (in case of ambiguous
* document numbers).
  c_doc_year = ls_mkpf-mjahr.
* Read items

* --- begin of changes -------------------------------------"n1306620
* enable MIGO to display MM docs from the AIS archive, too  "n1306620
  IF  lv_flag_archive = abap_true.
*   the MM doc items are already read from the archive
    CALL METHOD cl_mmim_line_id_manager=>rebuild_structure
      CHANGING
        ct_mseg = lt_mseg[].
  ELSE.
*   read the MM doc items from the database
    CALL FUNCTION 'MB_READ_MATERIAL_POSITION'
      EXPORTING
        mblnr         = ls_mkpf-mblnr
        mjahr         = ls_mkpf-mjahr
        trtyp         = a          "Display --> no enqueue
      TABLES
        seqtab        = lt_mseg
      EXCEPTIONS
        error_message = 1.

    IF sy-subrc <> 0.
      def_msg_add oref_doc_log sy-msgty sy-msgid sy-msgno
                             sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ENDIF.
* --- end   of changes -------------------------------------"n1306620

* MAA2 Begin
  DATA : lv_flag_maa_active  type  abap_bool.

* check whether the business function multi account assignment is active
  lv_flag_maa_active = cl_ops_switch_check=>mm_sfws_maa( ).

  IF lv_flag_maa_active = abap_true.
    LOOP AT lt_mseg TRANSPORTING NO FIELDS WHERE NOT xmacc IS INITIAL.
      EXIT.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      CALL METHOD go_mmim_maa_2->xmseg_aggregate
                EXPORTING
                  is_action       = s_action
                CHANGING
                  ct_mseg         = lt_mseg[] .
    ENDIF.
  ENDIF.
* MAA2 End

* MIGO cancelation no mseg-kzear should be proposed            "1083162
* initially like in MBST for manual set KZEAR                  "1083162
 IF s_action-cancel = abap_true.                               "1083162
  DATA: wa_mseg type mseg.                                     "1083162
   LOOP at lt_mseg into wa_mseg                                "1083162
        where kzear =  'X' .                                   "1083162
        clear wa_mseg-kzear.                                   "1083162
    Modify lt_mseg from wa_mseg                                "1083162
           transporting kzear.                                 "1083162
   ENDLOOP.                                                    "1083162
  IF sy-subrc <> 0.                                            "1083162
   clear sy-subrc.                                             "1083162
  ENDIF.                                                       "1083162
 ENDIF.                                                        "1083162

* During reading the material document, the line_id_manager
* may have counted some LINE_ID's. To prevent MIGO from
* using the same ones, we update MIGO's global_counter to
* the current max of the manager.
  p_line_id = cl_mmim_line_id_manager=>p_current_line_id.


***************** matdoc_fill_data *************************************

* take posting date of referenced material document only if you are NOT
* in cancel or display mode. In that cases ps_gohead-budat is already
* filled with the actual date. Due to the following move-corresponding
* to ps_gohead we will assure with the following lines that this date
* will not be overwritten.                                   note 206293
  IF s_action-cancel = abap_false AND
     s_action-display = abap_false.
    ls_mkpf-budat = ps_gohead-budat.
  ENDIF.

* clear GR/GI slip number if not in display mode             note 450805
  IF s_action-display = abap_false.
    CLEAR ls_mkpf-xabln.
  ENDIF.

* In copy mode, the current date is to be taken                   ERP 10
  IF s_action-copy = abap_true.
    ls_mkpf-bldat = ps_gohead-bldat.
  ENDIF.

* MOVE-CORRESPONDING ls_mkpf TO ps_gohead.                        ERP 10
* moved to the end of the mseg-loop with the checks -> mkpf should only
* be moved to gohead after all checks are done, else the header data
* would be displayed even though the matdoc cannot be copied

* When copying a material document, VGART is taken from here.
  ls_control = mode_get( ).
  ls_control-vgart = ls_mkpf-vgart.

* l_transfer is used for mode_set to set migo_mode GT (transfer posting)
* l_migo is set:
* - at least one transfer item (umwrk is filled) in display or cancel
*   mode
* - if action is set to remove from stor. (a9) or transfer (a8)
  LOOP AT lt_mseg TRANSPORTING NO FIELDS WHERE umwrk NE space.
    EXIT.
  ENDLOOP.
  IF ( sy-subrc = 0 AND
       ( s_control-action = 'A03' OR s_control-action = 'A04'
         OR s_control-action = 'A02'
       )
     ) OR
     s_control-action = 'A08' OR
     s_control-action = 'A09'.
    l_transfer = abap_true.
  ENDIF.

* In case of a goods issue, goods receipt or transfer posting related to
* a material document -> perform additional checks to make sure the
* document is allowed.                                            ERP 10
  IF s_action-copy = abap_true.
    LOOP AT lt_mseg ASSIGNING <ls_mseg>.

*     In case of a structured article it is not neccesary to check the
*     component because in this case the components will be deleted.
*     Only the header material is neccesary as the bom will be exploded
*     again within SAPMM07M
      IF <ls_mseg>-xauto = s OR <ls_mseg>-xauto = u.
        CONTINUE.
      ENDIF.

*     Make sure that the document does not represent a 'true'
*     cancellation
      IF NOT <ls_mseg>-smbln IS INITIAL.
        def_msg_add oref_doc_log e 'MIGO' '067' space space space space.
        RETURN.
      ENDIF.

*     Check if this really is a material document without reference to
*     an order or purchase order
      IF NOT <ls_mseg>-kzbew IS INITIAL.
        def_msg_add oref_doc_log e 'MIGO' '068' space space space space.
        RETURN.
      ENDIF.

*     There should be no reservation involved
      IF NOT <ls_mseg>-rsnum IS INITIAL.
        def_msg_add oref_doc_log e 'MIGO' '068' space space space space.
        RETURN.
      ENDIF.

*     Get current migo_t156-entry for the following checks regarding
*     transfer postings
      CALL METHOD lcl_migo_buffer=>move_type_get
        EXPORTING
          i_move       = <ls_mseg>-bwart
        IMPORTING
          es_migo_t156 = ls_migo_t156
        EXCEPTIONS
          OTHERS       = 1.

      IF sy-subrc = 1.
        def_msg_add oref_doc_log e 'MIGO' '062' <ls_mseg>-bwart space
                                 space space.
        RETURN.
      ENDIF.

*     Transfer posting
*     check whether the movement type fits (Blocks e.g. common goods
*     issue document from being read as transfer posting document)
      IF   s_control-action = 'A08' AND
           ls_migo_t156-xtransfer_mvt IS INITIAL.
        def_msg_add oref_doc_log e 'MIGO' '067' space space space space.
        RETURN.
      ENDIF.

*     Remove from storage
*     check whether the movement type fits
      IF ( s_control-action = 'A09' AND
           ( ls_migo_t156-xremove_from_mvt IS INITIAL OR
             NOT ls_migo_t156-xplace_in_mvt IS INITIAL
           )
         ).
        def_msg_add oref_doc_log e 'MIGO' '067' space space space space.
        RETURN.
      ENDIF.

*     No transfer-action chosen, but document contains transfer movement
      IF (  ( 'A08 A09' NS s_control-action ) AND
            ( NOT ls_migo_t156-xtransfer_mvt IS INITIAL  OR
              NOT ls_migo_t156-xremove_from_mvt IS INITIAL OR
              NOT ls_migo_t156-xplace_in_mvt IS INITIAL
            )
         ).
        def_msg_add oref_doc_log e 'MIGO' '067' space space space space.
        RETURN.
      ENDIF.

    ENDLOOP.

  ENDIF.

  MOVE-CORRESPONDING ls_mkpf TO ps_gohead.                  "ERP 10

* In case of a goods movement related to a material document      ERP 10
* (s_action-copy is set):
* The migo mode will be set correctly, as VGART will be taken from
* MKPF and as it will not be modified in mode_set.
* Refdoc will always stay 'R02', i.e. material document, to reflect the
* business process. In mode_set, all other flags concerning reference
* documents will also be set for 'R02'.
  CALL METHOD mode_set
    EXPORTING
      is_control = ls_control
      i_transfer = l_transfer.

* Display material document:
* Default value XAUTO_LINES determines, whether automatic lines will be
* displayed or not.
* First check if display of transfer doc is ext.called     "start 726093
  IF s_action-display = abap_true AND
     l_transfer = abap_true AND NOT
     lcl_migo_globals=>external_call_zeile IS INITIAL.
    READ TABLE lt_mseg WITH KEY xauto = abap_true
      TRANSPORTING NO FIELDS.
*  set XAUTO_LINES to avoid wrong display
    IF sy-subrc = 0.
      s_defaults-xauto_lines = abap_true.
    ENDIF.
  ENDIF.                                                    "end 726093
  IF s_action-display = abap_true AND
     s_defaults-xauto_lines = abap_false.
    DELETE lt_mseg WHERE xauto = x.
  ENDIF.

* Text for transaction code
  SELECT SINGLE * FROM tstct INTO ls_tstct
                             WHERE sprsl = sy-langu
                             AND   tcode = ps_gohead-tcode2.
  IF sy-subrc IS INITIAL.
    ps_gohead-ttext = ls_tstct-ttext.
  ENDIF.

* Name and phone of user
  CALL METHOD lcl_migo_buffer=>name_and_phone_get
    EXPORTING
      i_usnam = ps_gohead-usnam
    IMPORTING
      e_exnam = ps_gohead-createdby
      e_telnr = ps_gohead-telusnam.

**** Creation mode for header
  IF s_action-create = abap_true AND NOT ls_mkpf-exnum IS INITIAL.
* Ftrade: assumption: if refdoc has exnum, import relevance
*         copy header data from old doct and get a new gohead-exnum
    CALL FUNCTION 'EXPIMP_TABLES_REFRESH'.
*     Copy header data from refdoc and get a new gohead-exnum
    CALL FUNCTION 'EXPIMP_GENERAL_DATA_COPY'
         EXPORTING
              i_ahbas        = '1WE'
              exnum_o        = ls_mkpf-exnum
         IMPORTING
              exnum_n        = ps_gohead-exnum
         EXCEPTIONS
*             NO_EXPORT_DATA = 1
              OTHERS         = 2
              .
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.
  ENDIF.

**** Display mode for header...
  IF s_action-display = abap_true.
*   Output determination: read NAST records for material document in
*   display mode and set field GOHEAD-XNAPR
    CALL METHOD output_exist
      EXPORTING
        i_mblnr    = ps_gohead-mblnr
        i_mjahr    = ps_gohead-mjahr
      IMPORTING
        i_exist    = ps_gohead-xnapr
        it_nastkey = lt_nastkey.
*   if no output has been generated yet, it is necessary to store mkpf
*   and mseg as private data as user might want to print now
    IF ps_gohead-xnapr = abap_false.   "not printed yet
      ps_mkpf_nast = ls_mkpf.
    ENDIF.
  ENDIF.

* prepare material prefetch
  CLEAR lt_prefetch02.
  CLEAR lt_prefetch03.
  LOOP AT lt_mseg ASSIGNING <ls_mseg> WHERE NOT matnr IS INITIAL.
    MOVE-CORRESPONDING <ls_mseg> TO ls_prefetch02.
    COLLECT ls_prefetch02 INTO lt_prefetch02.
    MOVE-CORRESPONDING <ls_mseg> TO ls_prefetch03.
    COLLECT ls_prefetch03 INTO lt_prefetch03.
*   For delivery flow data
* > Begin of note 875529
    IF <ls_mseg>-kzbew = 'B' AND s_action-return = 'X'.
      IF <ls_mseg>-kzzug = 'X'.
        MOVE-CORRESPONDING <ls_mseg> TO ls_mbvbfa.
        APPEND ls_mbvbfa TO lt_mbvbfa.
      ELSE.
        IF ls_ekko-ebeln NE <ls_mseg>-ebeln.
          CLEAR ls_ekko.
          SELECT SINGLE ebeln reswk FROM  EKKO
                                    INTO CORRESPONDING FIELDS OF ls_ekko
                                    WHERE ebeln = <ls_mseg>-ebeln.
          IF sy-subrc IS INITIAL AND NOT ls_ekko-reswk IS INITIAL.
            MOVE-CORRESPONDING <ls_mseg> TO ls_mbvbfa.
            APPEND ls_mbvbfa TO lt_mbvbfa.
          ENDIF.
        ELSEIF NOT ls_ekko-reswk IS INITIAL.
          MOVE-CORRESPONDING <ls_mseg> TO ls_mbvbfa.
          APPEND ls_mbvbfa TO lt_mbvbfa.
        ENDIF.
      ENDIF.
    ELSEIF <ls_mseg>-kzbew = 'L'.                           "v_n_1024978
      MOVE-CORRESPONDING <ls_mseg> TO ls_mbvbfa.
      APPEND ls_mbvbfa TO lt_mbvbfa.                        "^_n_1024978
    ENDIF.
* > End of note 875529
  ENDLOOP.
  CALL METHOD material_prefetch_read
    EXPORTING
      it_prefetch02 = lt_prefetch02
      it_prefetch03 = lt_prefetch03.

* Retrieve delivery flow data
  CALL FUNCTION 'MB_READ_DELIVERY_FLOW'                     "358454
    EXPORTING
      i_xblnr         = ls_mkpf-xblnr
    TABLES
      ct_mbvbfa       = lt_mbvbfa.
  SORT lt_mbvbfa BY mblnr mjahr zeile.

* Identify positions that have already been cancelled
  IF s_action-cancel = abap_true.
    SELECT smblp FROM mseg
                 INTO ls_cancelled
                 WHERE smbln = ls_mkpf-mblnr
                   AND sjahr = ls_mkpf-mjahr.
      INSERT ls_cancelled INTO TABLE lt_cancelled.
    ENDSELECT.
  ENDIF.

**** Main Loop__________________________________________________________
  LOOP AT lt_mseg ASSIGNING <ls_mseg>.
*   check if Brazil is active                                   "804327
    IF sy-tabix = 1.                                        "804327
      CALL METHOD oref_nota_fiscal->j_1b_check_brazil       "804327
        EXPORTING                                           "804327
          iv_bukrs = <ls_mseg>-bukrs                        "804327
        IMPORTING                                           "804327
          ev_brazil = lv_brazil.                            "804327
    ENDIF.                                                  "804327

ENHANCEMENT-POINT EHP604_MATERIALDOCUMENT_GET_02 SPOTS ES_SAPLMIGO.

    CLEAR ls_goitem.
*   Which lines should be copied from the material document in
*   case of empies, structures, variants, ...?? temp vsa
*   Xauto-lines may have own dependent data (e.g. output, import)
*   so for the time being we keep the xauto-lines in goitem...

*   special handling for structured articles necessary
*   in case of a transfer with structured articles the
*   automatically created transfer lines for the components
*   (xauto = u) get the same parent id as the automatically
*   created transfer line
    IF <ls_mseg>-xauto = x.
      READ TABLE lt_mseg INTO ls_mseg_temp WITH KEY
                         parent_id = <ls_mseg>-line_id.
      IF sy-subrc = 0.
        CHECK ls_mseg_temp-xauto = u.
        l_parent_st = <ls_mseg>-parent_id.
      ENDIF.
      IF s_action-display = abap_false.
        CONTINUE.
      ENDIF.
*      CHECK <ls_mseg>-xauto <> x.
    ENDIF.
*   structured articles: in case of returns do not copy the components
    IF s_action-return = abap_true.
      CHECK <ls_mseg>-xauto <> s OR <ls_mseg>-xauto <> u.
    ENDIF.
*   Copy organizational data from reference document.
*   The material document reading routine ensures that all lines
*   have a LINE_ID, even if the document on the database has not.
    ls_goitem-global_counter = <ls_mseg>-line_id.
*   for automatic created transfer lines of a structured article set
*   the parent to the parent of the line with xauto = x
    IF <ls_mseg>-xauto = u.
      ls_goitem-parent = l_parent_st.
    ELSE.
      ls_goitem-parent         = <ls_mseg>-parent_id.
    ENDIF.
    ls_goitem-depth          = <ls_mseg>-line_depth.
*   HSDAT/VFDAT/UMHSDAT/UMVFDAT have to be initial (except Display-Mode)
*   It doesn't make sense to take this data from original document (same
*   logic as in MB1B), because these fields were maintained for the
*   receiving side.
    IF s_action-migo_mode = 'GT'.
      IF s_action-display = abap_false.
        CLEAR: ls_goitem-umvfdat, ls_goitem-umhsdat,
               <ls_mseg>-vfdat,  <ls_mseg>-hsdat.
      ELSE.
        IF <ls_mseg>-shkzg = h.
          CLEAR ls_mseg_temp.
          IF <ls_mseg>-parent_id IS INITIAL.
            READ TABLE lt_mseg INTO ls_mseg_temp WITH KEY
                               parent_id = <ls_mseg>-line_id.
            ls_goitem-umvfdat = ls_mseg_temp-vfdat.
            ls_goitem-umhsdat = ls_mseg_temp-hsdat.
          ELSE.
            READ TABLE lt_mseg INTO ls_mseg_temp WITH KEY
                               line_id = <ls_mseg>-parent_id.
            ls_goitem-umvfdat = ls_mseg_temp-vfdat.
            ls_goitem-umhsdat = ls_mseg_temp-hsdat.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*   Cancelled positions
    READ TABLE lt_cancelled
         WITH TABLE KEY table_line = <ls_mseg>-zeile
         TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      ls_goitem-xcancel_done = abap_true.
    ENDIF.

****Display mode for item
    IF s_action-display = abap_true.
*     Final delivery from original doc.
      ls_goitem-elikz_matdoc = <ls_mseg>-elikz.
*     Foreign trade: if data exist, set ftrade flag
      IF NOT ps_gohead-exnum IS INITIAL.
        l_expos = <ls_mseg>-zeile.
        CALL FUNCTION 'EXPIMP_ITEM_DATA_READ'
             EXPORTING
                exnum              = ls_mkpf-exnum
                expos              = l_expos
             IMPORTING
*               IMPK               =
*               IMPP               =
*               E_HEADER_EXISTS    =
                e_line_item_exists = ls_goitem-import.
      ENDIF.
*     NAST records for item?
      READ TABLE lt_nastkey WITH TABLE KEY mblnr = <ls_mseg>-mblnr
                                           mjahr = <ls_mseg>-mjahr
                                           zeile = <ls_mseg>-zeile
                            TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        ls_goitem-nast = abap_true.
      ENDIF.
*     not printed yet => store mseg in display mode
      IF ps_gohead-xnapr = abap_false.
        INSERT <ls_mseg> INTO TABLE pt_mseg_nast.
      ENDIF.
    ENDIF.

**** Filling the right fields if action 'place in storage'
    IF s_action-place = abap_true.
      MOVE-CORRESPONDING <ls_mseg> TO ls_mseg_place.
      CLEAR <ls_mseg>.
      MOVE-CORRESPONDING ls_mseg_place TO <ls_mseg>.
*      Different behaviour to MBSU: If UMMAT was entered within
*      movement type 303, then this UMMAT will be used to post
*      the place in storage!
      IF NOT <ls_mseg>-ummat IS INITIAL.
        <ls_mseg>-matnr = <ls_mseg>-ummat.
      ENDIF.
      CLEAR <ls_mseg>-ummat.
      IF NOT <ls_mseg>-umwrk IS INITIAL.
        lv_br_werks = <ls_mseg>-werks.                      "804327
        <ls_mseg>-werks = <ls_mseg>-umwrk.
        IF lv_brazil IS INITIAL.                            "804327
          CLEAR <ls_mseg>-umwrk.
        ELSE.                                               "804327
          <ls_mseg>-umwrk = lv_br_werks.                    "804327
        ENDIF.                                              "804327
      ENDIF.
      IF NOT <ls_mseg>-umlgo IS INITIAL.
        <ls_mseg>-lgort = <ls_mseg>-umlgo.
        CLEAR <ls_mseg>-umlgo.
      ENDIF.
      IF NOT <ls_mseg>-umcha IS INITIAL.
        <ls_mseg>-charg = <ls_mseg>-umcha.
        CLEAR <ls_mseg>-umcha.
      ENDIF.
*       IF <ls_mseg>-parbu IS INITIAL.            "jhm temp
*         <ls_mseg>-parbu = <ls_mseg>-bukrs.
*       ENDIF.
*      Take MWSKZ from original doc.   > Will be mapped against
*      table J1B007 later
      <ls_mseg>-j_1bexbase = ls_mseg_place-j_1bexbase.
      <ls_mseg>-mwskz = ls_mseg_place-mwskz.

      IF cl_ops_switch_check=>mm_om1_sfws_sc( ) EQ cl_ops_switch_check=>switch_active_true..
        IF NOT <ls_mseg>-umsok IS INITIAL.
          <ls_mseg>-sobkz = <ls_mseg>-umsok.
        ENDIF.
        CLEAR <ls_mseg>-umsok.
      ELSE.
        CLEAR: <ls_mseg>-umsok,
               <ls_mseg>-lifnr.
      ENDIF.

      CLEAR ls_mseg_place.
    ENDIF.


*   Clear MSEG-fields that must not be transferred for a goods movement
*   related to a material document                                ERP 10
    IF s_action-copy = abap_true.

*     In case of a structured article copy only the header material
*     because the bom will be exploded again.
      IF <ls_mseg>-xauto = s OR <ls_mseg>-xauto = u.
        CONTINUE.
      ENDIF.

      MOVE-CORRESPONDING <ls_mseg> TO ls_mseg_copy.
      CLEAR <ls_mseg>.
      MOVE-CORRESPONDING ls_mseg_copy TO <ls_mseg>.

    ENDIF.

**** Creation mode for item
    IF s_action-create = abap_true.
      CLEAR l_fcode.
      IF s_action-return = abap_true.
        l_fcode = 'RL'.
      ELSEIF s_action-release = abap_true.
        l_fcode = 'SF'.
      ELSEIF s_action-cancel = abap_true.
        l_fcode = 'ST'.
      ELSEIF s_action-subsequent = abap_true.
        l_fcode = 'SN'.
      ELSEIF s_action-place = abap_true.
        l_fcode = 'SU'.
      ENDIF.
      IF NOT l_fcode IS INITIAL.
        CALL METHOD lcl_migo_buffer=>move_type_next_get
          EXPORTING
            i_move      = <ls_mseg>-bwart
            i_fcode     = l_fcode
          RECEIVING
            e_move_next = <ls_mseg>-bwart
          EXCEPTIONS
            not_found   = 1.
        IF sy-subrc <> 0.
          def_msg_add oref_doc_log 'W' 'MIGO' '029'
                                   space space space space.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.                             "creation mode item

    l_refdoc_involved = abap_false.

*   Merge delivery data if available
    READ TABLE lt_mbvbfa INTO ls_mbvbfa                     "358454
               WITH KEY mblnr = <ls_mseg>-mblnr
                        mjahr = <ls_mseg>-mjahr
                        zeile = <ls_mseg>-zeile
               BINARY SEARCH.
    IF sy-subrc = 0.
      ls_goitem-vbeln = ls_mbvbfa-vbelv.
      ls_goitem-posnr = ls_mbvbfa-posnv.
    ENDIF.

*   If the material document is to be copied as a template:
*   KZBEW should always be initial, as it is being cleared
*   via the move-corresponding above.                             ERP 10
    CASE <ls_mseg>-kzbew.
*-----reference to purchase order
      WHEN b OR o.
        l_refdoc_involved = abap_true.
*       need to set xpoitem here as purchase order might already
*       be archived. In that case method purchase_order_fill_matdoc
*       returns with error and purchase_order_fill_goitem is not
*       processed. As display material document should be possible
*       even if material document is archived, xpoitem needs
*       independant of the fact if PO is read successful or not.
        ls_goitem-xpoitem = abap_true.                      "432683
        CALL METHOD purchase_order_fill_matdoc
          EXPORTING
            is_mseg      = <ls_mseg>
            is_goitem    = ls_goitem
          IMPORTING
            es_goitem    = ls_goitem
          EXCEPTIONS
            no_take_over = 1.
*       if trouble with actual po item (e.g. tied empty)-> skip it; <LG>
*       skip the item only when not in display mode              "432683
        CHECK sy-subrc = 0
              OR s_action-display = abap_true.
*---- reference = production order
      WHEN f.
        l_refdoc_involved = abap_true.
*       same as for case kzbew = b, if order is archived.        "432683
        ls_goitem-xorditem = abap_true.
*       Fill pps_aufnr. Needs to be done here as order might be  "432683
*       archived.
        ls_goitem-pps_aufnr = <ls_mseg>-aufnr.
        ls_goitem-pps_posnr = <ls_mseg>-aufps.
        CALL METHOD order_fill_matdoc
          EXPORTING
            is_mseg      = <ls_mseg>
            is_goitem    = ls_goitem
          IMPORTING
            es_goitem    = ls_goitem
          EXCEPTIONS
            no_take_over = 1.
*       skip the item when not in display mode                   "432683
        CHECK sy-subrc = 0
              OR s_action-display = abap_true.
      WHEN l.
*       kzbew=l is only used for 605 (GR outbound delivery)
*       we have to set xdelivitem here, because delivery will not
*       be read. In all other kzbew cases the corresponding
*       x*item indicators are set in the reading methods for
*       the corresponding reference documents.
        ls_goitem-xdelivitem = abap_true.
        "Determine item text based on item type                 "1525459
        IF <ls_mseg>-ebeln IS NOT INITIAL AND                   "1525459
           <ls_mseg>-ebelp IS NOT INITIAL .                     "1525459
          SELECT SINGLE pstyp FROM ekpo INTO lv_pstyp           "1525459
                                 WHERE ebeln = <ls_mseg>-ebeln  "1525459
                                 AND   ebelp = <ls_mseg>-ebelp. "1525459
          IF sy-subrc = 0.                                      "1525459
            CALL FUNCTION 'ME_ITEM_CATEGORY_OUTPUT'             "1525459
                 EXPORTING                                      "1525459
                      pstyp = lv_pstyp                          "1525459
                 IMPORTING                                      "1525459
                      ptext = ls_goitem-ptext.                  "1525459
          ENDIF.                                                "1525459
        ENDIF.                                                  "1525459
      WHEN OTHERS.
        IF NOT <ls_mseg>-rsnum IS INITIAL.
          l_refdoc_involved  = abap_true.
          ls_goitem-xresitem = abap_true.
          CALL METHOD reservation_fill_matdoc               "355296
            EXPORTING is_mseg   = <ls_mseg>
                      is_goitem = ls_goitem
            IMPORTING es_goitem = ls_goitem.
* use plant and stor.loc.from reservation and not from document
          IF s_control-action = 'A02' AND                        "939014
             s_control-refdoc = 'R02' AND                        "939014
             NOT ls_goitem-werks = <ls_mseg>-werks AND           "939014
             NOT ls_goitem-werks IS INITIAL.                     "939014
              <ls_mseg>-werks = ls_goitem-werks.                 "939014
              <ls_mseg>-lgort = ls_goitem-lgort.                 "939014
          ENDIF.                                                 "939014
        ENDIF.
    ENDCASE.

*   Data from MSEG to GOITEM.
*   EVERS (shipping instruction) always taken from the PO.
    l_evers = ls_goitem-evers.
*   In creation mode, some fields should not be taken from matdoc but
*   from other refdoc (PO)                                   note 329605
    IF s_action-create     = abap_true  AND
       s_action-return     = abap_false AND                  "SIT
       s_action-cancel     = abap_false AND                  "SIT
       s_action-copy       = abap_false AND                  "SIT
       s_action-subsequent = abap_false.                     "SIT
*     In case of 105 take storage location from PO and not 103 doct
      IF <ls_mseg>-lgort IS INITIAL.                        "329605
        <ls_mseg>-lgort = ls_goitem-lgort.
      ENDIF.
    ENDIF.
*                                                            note 330585
*   In case of release and subsequent, batch and LICHA from PO
*   as it is a new goods receipt process,
*   otherwise from material document (licha from batch master).
*   Notice: batch_from_refdoc will be set below.
    IF s_action-release = abap_true OR s_action-subsequent = abap_true.
*      no need to save licha as it is not in mseg... but we need to fill
*       vendorbatch_from_refdoc as not set in PO methods for matdoc.
      <ls_mseg>-charg = ls_goitem-charg.
      ls_goitem-vendorbatch_from_refdoc = ls_goitem-licha.
    ELSE.
*      licha will be read from batch master data in line_check,
*      charg from mseg is already the right one.
      CLEAR ls_goitem-licha.
    ENDIF.
*   note 430347: Fields which should be taken from PO in case of release
*   blocked stock.
    IF s_action-release = abap_true.                        "430347
      <ls_mseg>-insmk = ls_goitem-insmk.
    ENDIF.

    MOVE-CORRESPONDING <ls_mseg> TO ls_goitem.
    ls_goitem-evers = l_evers.

* In case of cancellation clear vfdat, licha and hsdat
* data will be filled later in LMIGOKM2 from batch master
    IF s_action-cancel = abap_true.                         "836216
      CLEAR: ls_goitem-licha, ls_goitem-hsdat, ls_goitem-vfdat."836216
    ENDIF.                                                  "836216

* In case of return delivery clear vfdat, licha and hsdat
* data will be filled later in LMIGOKM2 from batch master
   if s_action-return = abap_true.                              "894340
     clear: ls_goitem-licha, ls_goitem-hsdat, ls_goitem-vfdat.  "894340
   endif.                                                       "894340

*   Clear fields in case of not display. (WM-related fields)
*   These fields are determined anew with every movement.
    IF s_action-create = abap_true.
      CLEAR: ls_gowm1,
             ls_gowm2.
      MOVE-CORRESPONDING: ls_gowm1 TO ls_goitem,
                          ls_gowm2 TO ls_goitem.

*     Do not clear the reason for movement field in case the
*     material document is to be taken as template
      IF s_action-copy IS INITIAL.                          "ERP 10
        CLEAR: ls_goitem-grund.
      ENDIF.

      CLEAR:
           ls_goitem-bukrs,
           ls_goitem-smbln,
           ls_goitem-sjahr,
           ls_goitem-smblp.
    ENDIF.

ENHANCEMENT-POINT ehp604_materialdocument_get_01 SPOTS ES_SAPLMIGO.

*   Fill reference material document number and year             "596300
    IF s_control-action = 'A02' AND s_control-refdoc = 'R02'.
      ls_goitem-r_mblnr = <ls_mseg>-mblnr.
      ls_goitem-r_mjahr = <ls_mseg>-mjahr.
    ENDIF.

*   Special stock handling______________________________________________
*   Set correct special stock identifier for transfer postings
    CALL METHOD special_stock_identifier_set
      CHANGING
        cs_goitem = ls_goitem.
*   we have to check if e.g. mat_kdauf mat_pspnr is
*   filled and we have to remove the values for fields without mat_
*   because they have nothing to do with an assignment.
    CASE ls_goitem-sobkz.
      WHEN e.
        IF ls_goitem-mat_kdauf IS INITIAL.
*         for documents < release 45
          ls_goitem-mat_kdauf = ls_goitem-kdauf.
          ls_goitem-mat_kdpos = ls_goitem-kdpos.
        ENDIF.
*       The following line assumes
*       that kdauf is eq to mat_kdauf if ref. doc is involved. This
*       should be the case because because mat_kdauf is not in interface
*       to all refdocs. Because in that case kdauf is not an assignment
*       it is cleared.
        IF l_refdoc_involved = abap_true.
          CLEAR: ls_goitem-kdauf, ls_goitem-kdpos.
        ENDIF.
      WHEN t.                                                     "SIT
        IF ls_goitem-vlief_avis IS INITIAL.
          ls_goitem-vlief_avis = ls_goitem-mat_kdauf.
          ls_goitem-vbelp_avis = ls_goitem-mat_kdpos.
          CLEAR: ls_goitem-mat_kdauf,
                 ls_goitem-mat_kdpos.
        ENDIF.
      WHEN q.
        IF ls_goitem-mat_pspnr IS INITIAL.
*         for documents < release 45
          ls_goitem-mat_pspnr = ls_goitem-ps_psp_pnr.
        ENDIF.
*       The following line assumes
*       that ps_psp_pnr is eq to mat_pspnr if ref. doc is involved. This
*       should be the case because because mat_pspnr is not in interface
*       to all refdocs. Because in that case pspnr not an assignment
*       it is cleared.
        IF l_refdoc_involved = abap_true.
          CLEAR ls_goitem-ps_psp_pnr.
        ENDIF.
* begin of Outsourced Manufacturing EhP 4
      WHEN o.
        IF ls_goitem-aufnr IS NOT INITIAL AND s_action-migo_mode = 'GI'
           AND ls_goitem-xlbtype is INITIAL.
          ls_goitem-xco_order = abap_true.
          ls_goitem-xpoitem   = abap_true.
        ENDIF.
* end of Outsourced Manufacturing EhP 4
      WHEN OTHERS.
    ENDCASE.
*_______________________________________________________________________

*   Only in cancel mode can the original material document number
*   be copied into SMLBN (see memo to note 357909).
    IF s_action-cancel     = abap_true.
      ls_goitem-smbln = <ls_mseg>-mblnr.
      ls_goitem-sjahr = <ls_mseg>-mjahr.
      ls_goitem-smblp = <ls_mseg>-zeile.
    ENDIF.

*   process in cancel mode only
    IF s_action-cancel = abap_true.
      IF ls_goitem-xcancel_done = abap_true.
        CLEAR ls_goitem-take_it.
      ELSE.
ENHANCEMENT-SECTION     materialdocument_get_01 SPOTS es_saplmigo.
        IF s_defaults-take_it_all = abap_true.
          ls_goitem-take_it = x.
        ENDIF.
END-ENHANCEMENT-SECTION.
      ENDIF.
    ENDIF.

    IF NOT ls_goitem-matnr IS INITIAL.
      IF ls_goitem-bwtor IS INITIAL AND s_action-cancel = abap_true.
        ls_goitem-bwtor = ls_goitem-bwtar.
      ENDIF.
*     take values from data base for the batch master
*     see note 330585: if batch_from_refdoc is not set, we do not read
*     the batch master in line_check
      IF s_action-display = abap_false.
        ls_goitem-batch_from_refdoc = ls_goitem-charg.
      ENDIF.
    ENDIF.
*   structured articles
    IF s_action-cancel = abap_true OR s_action-display = abap_true.
      IF <ls_mseg>-xauto = s OR <ls_mseg>-xauto = u.
        ls_goitem-xsttype = c.
      ENDIF.
    ENDIF.
*   Derive INSMK
    CASE ls_goitem-insmk.
      WHEN ' ' OR 'F'.
        CLEAR ls_goitem-migo_insmk.
      WHEN '2' OR 'X'.
        ls_goitem-migo_insmk = '2'.
      WHEN '3' OR 'S'.
        ls_goitem-migo_insmk = '3'.
      WHEN OTHERS.
    ENDCASE.

*   No BSTME, if KZBEW = SPACE. Relevant for subcontract order
*   Here MSEG-BSTME is filled also for 543-items.
*   If BSTME is cleared, UNIT_CONVERSION uses material master conversion
    IF ls_goitem-kzbew = space AND s_action-create = abap_true.
      CLEAR: ls_goitem-bstmg, ls_goitem-bstme.
    ENDIF.

*   Fields for material
    ls_goitem-bukrs_for_stock = <ls_mseg>-bukrs.
*   Field has just another name in GOITEM (corresponding to IMSEG)
    ls_goitem-konto = <ls_mseg>-sakto.
*   Fields for accounting
*   This may seem to be odd, but the fields bukrs, prctr and gsber of
*   goitem do indeed contain the fields of the respective partner in
*   case of transfers...they are being mapped to imseg in
*   goods_movement_fill. There, imseg-bukrs will be filled from goitem-
*   bukrs_for_stock.
    ls_goitem-bukrs = <ls_mseg>-parbu.
    ls_goitem-prctr = <ls_mseg>-pprctr.
    ls_goitem-gsber = <ls_mseg>-pargb.

*-- MAA-DEV
    if ls_goitem-mulko is initial.
      ls_goitem-konto = <ls_mseg>-sakto.
    endif.
    call method oref_detail_maa->maa_disp_acc
          CHANGING
               cs_goitem    = ls_goitem.
*-- MAA-DEV

    IF s_action-display = abap_true.
      IF NOT <ls_mseg>-umwrk IS INITIAL.
        IF ( ( <ls_mseg>-kostl IS INITIAL AND <ls_mseg>-aufnr IS INITIAL
          AND <ls_mseg>-ps_psp_pnr IS INITIAL
          AND <ls_mseg>-kdauf IS INITIAL )
          OR NOT <ls_mseg>-xauto IS INITIAL ).              "HW 596314
          ls_goitem-gsber = <ls_mseg>-gsber.
          ls_goitem-prctr = <ls_mseg>-prctr.
        ENDIF.
      ENDIF.
    ENDIF.

*   Set SC_ADJUST in case of subsequent adjustment
    IF s_action-migo_mode = 'GS' AND ls_goitem-kzbew IS INITIAL.
      CALL METHOD mvt_sc_adjust_component_get
        EXPORTING
          i_move      = ls_goitem-bwart
        CHANGING
          c_sc_adjust = ls_goitem-sc_adjust.
ENHANCEMENT-POINT lmigokm1_03 SPOTS es_saplmigo.
    ENDIF.

*   Insert default values.
    IF s_action-cancel = abap_false AND s_action-display = abap_false.
      CALL METHOD defaults_merge
        CHANGING
          cs_goitem = ls_goitem.
    ENDIF.

ENHANCEMENT-POINT lmigokm1_01 SPOTS es_saplmigo.
*   Update model
    CALL METHOD line_modify
      EXPORTING
        i_line            = 0
        i_authority_check = abap_true
        i_status_delayed  = abap_true
      CHANGING
        cs_goitem         = ls_goitem.

*   Read serial number data - but not if the materialdocument is being
*   copied.
    IF NOT ls_goitem-sernp IS INITIAL AND s_action-copy IS INITIAL.
      CALL METHOD serialnumbers_read
        EXPORTING
          is_goitem   = ls_goitem
          is_vepwe    = ls_vepwe                            "731711
        IMPORTING
          et_goserial = lt_goserial.
      ls_goserial_kernel-global_counter = ls_goitem-global_counter.
      ls_goserial_kernel-t_goserial =  lt_goserial.
      INSERT ls_goserial_kernel INTO TABLE pt_goserial_kernel.
    ENDIF.
*   Copy ftrade data from previous item to global_counter
    DATA: l_expos_old       TYPE expos,
          l_expos_new       TYPE expos.
    IF ls_goitem-import = abap_true.
      l_expos_old = <ls_mseg>-zeile.
      l_expos_new = ls_goitem-global_counter.
      CALL FUNCTION 'EXPIMP_ITEM_DATA_COPY'
        EXPORTING
          i_ahbas                = '1WE'
          exnum_n                = ps_gohead-exnum
          exnum_o                = ls_mkpf-exnum
          expos_n                = l_expos_new
          expos_o                = l_expos_old
        EXCEPTIONS
          no_export_data         = 1
          no_item_identification = 2
          OTHERS                 = 3.
      IF sy-subrc = 0.
        sy-subrc = sy-subrc.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF s_action-cancel = abap_true AND NOT pt_goitem IS INITIAL."562411
    READ TABLE pt_goitem WITH KEY xcancel_done = abap_false
         TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      def_msg_add oref_doc_log e 'M7' '067'
         ls_goitem-mblnr space space space.
    ENDIF.
  ENDIF.

* Now the Material document has been read. If necessary, a document
* structure has to be rebuild to have the same state as after
* constructing the document online in MIGO.
  LOOP AT pt_goitem ASSIGNING <ls_goitem>.
*   Linking of subitems to superitems.
    IF NOT <ls_goitem>-parent IS INITIAL.
      READ TABLE pt_goitem ASSIGNING <ls_parent>
                 WITH KEY global_counter = <ls_goitem>-parent.
*     If the parent does not exist (e.g. failed authority check) "496258
*     -> Delete 'child'
      IF sy-subrc <> 0.
        DELETE pt_goitem.
        CONTINUE.
      ENDIF.
      IF <ls_parent>-xlbtype = p.
        IF <ls_parent>-xco_order = abap_true.
          CONTINUE.
        ENDIF.
        <ls_goitem>-xlbtype = c.
        <ls_goitem>-zeile   = <ls_parent>-zeile.
        <ls_parent>-expand  = c_icon_collapse.
      ENDIF.
      IF <ls_parent>-xvgtype = p.                                  "<LG>
        IF <ls_goitem>-xvgtype IS INITIAL.
          <ls_goitem>-xvgtype = c.
          <ls_goitem>-uptyp   = c_uptyp_lg.
        ENDIF.
        <ls_goitem>-zeile   = <ls_parent>-zeile.
*       in case of goods receipt w. ref. to po -> MIGO goes through
*       purchase_order_fill_tied_empty and sets invisible to true ->
*       reset here as in this case it's not needed
        CLEAR <ls_goitem>-invisible.
        <ls_parent>-expand  = c_icon_collapse.
      ENDIF.
*     Generic article
      IF <ls_parent>-xgatype = p AND <ls_goitem>-xgatype = c.
        <ls_goitem>-zeile   = <ls_parent>-zeile.
      ENDIF.
*     structured article
      IF <ls_parent>-xsttype IS NOT INITIAL.
        <ls_goitem>-xsttype = c.
        <ls_goitem>-zeile   = <ls_parent>-zeile.
        IF <ls_parent>-xsttype <> c.
          <ls_parent>-expand  = c_icon_collapse.
        ENDIF.
      ENDIF.
*     <ls_goitem>-invisible = abap_true.
*     Now, the screenmodification has to be recalled because
*     automatic lines might have another behaviour.
      CALL METHOD screen_modify_line( <ls_goitem> ).
      CALL METHOD screen_modify_transfer_fields( <ls_goitem> ).
    ENDIF.
*   Removing the expander for subcontracting items without components
    IF <ls_goitem>-xlbtype = p.
      READ TABLE pt_goitem WITH KEY parent = <ls_goitem>-global_counter
                           TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
*       modification of note 315342:
*       in case of display mode: clear expand button
        IF s_control-action = 'A04' AND                     "632597
              s_control-refdoc = 'R02'.
          CLEAR <ls_goitem>-expand.
        ELSE.
          IF <ls_goitem>-kzwes <> x.
*           expand button should not be cleared in case of release
*           stock, because in that case the reference material
*           document has no components but the actual process should
*           have components. -> note 315342
            CLEAR <ls_goitem>-expand.
          ENDIF.
        ENDIF.
      ENDIF.
      CALL METHOD screen_modify_line( <ls_goitem> ).
      CALL METHOD screen_modify_transfer_fields( <ls_goitem> ).
    ENDIF.
  ENDLOOP.

* sort pt_goitem in case of material document with stucture...
* especially for material documents from subsequent adjustment, the
* display should be the same as during the creation of the document. But
* actually the material document has the 121 items before all the
* consumption postings.
  SORT pt_goitem STABLE BY mblnr mjahr zeile.

* in display mode save the number and year of this MM           "n555246
* document in case the user is a tax auditor
* and there is at least one item to be shown
  IF s_action-display = abap_true  AND
     NOT pt_goitem[] IS INITIAL.
    DATA : l_f_repid       TYPE progname.
    MOVE  sy-repid         TO  l_f_repid.

*   start this function module with log function
    CALL FUNCTION 'MB_CHECK_USER_PG_DATE_PLANT'
      EXPORTING
        i_user      = sy-uname
        i_program   = l_f_repid
        i_write_log = 'X'
        i_mblnr     = ls_mkpf-mblnr
        i_mjahr     = ls_mkpf-mjahr
      EXCEPTIONS
        OTHERS      = 3.

    IF  sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  CALL METHOD status_derive.

ENDMETHOD.                    "materialdocument_get


************************************************************************
* Material document read: externally visible
************************************************************************
METHOD materialdocument_read.
* Reset the kernel. Each material document is a separate entity
  CALL METHOD reset.
* Read document and append to pt_goitem
  CALL METHOD materialdocument_get
    EXPORTING
      i_mat_doc  = i_mat_doc
    CHANGING
      c_doc_year = c_doc_year.
ENDMETHOD.                    "materialdocument_read

* --- begin of changes -------------------------------------"n1306620
************************************************************"n1306620
* look for the material document in the arcive              "n1306620
************************************************************"n1306620

METHOD material_doc_from_archive.

* define local working areas
  DATA : lt_mkpf             TYPE  ty_t_mkpf,
         lt_mseg             TYPE  ty_t_mseg,
         ls_borident         TYPE  borident.

  FIELD-SYMBOLS : <ls_mkpf>  LIKE  LINE of lt_mkpf.

*----------------------------------------------------------------------*

  MOVE  abap_false           TO  cv_flag_archive.
  REFRESH                    ct_mseg.
  CLEAR                      cs_mkpf.

* at first :
* check whether the requiered MM doc available in the memory
  IMPORT xmkpf   TO lt_mkpf
         xmseg   TO lt_mseg  FROM MEMORY ID i_mat_doc.

  IF sy-subrc IS INITIAL.
*   get the MM doc header line
    LOOP AT  lt_mkpf         ASSIGNING  <ls_mkpf>.
      IF  <ls_mkpf>-mblnr =  i_mat_doc   AND
          <ls_mkpf>-mjahr =  i_doc_year.
*       OK memory contains the data of the required MM doc
        MOVE : lt_mseg[]     TO  ct_mseg,
               <ls_mkpf>     TO  cs_mkpf,
               abap_true     TO  cv_flag_archive.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

* at second :
* look for the required MM doc in the AIS archive directly if
* memory was empty
  IF  cv_flag_archive = abap_false.
    CONCATENATE  i_mat_doc i_doc_year
                             INTO  ls_borident-OBJKEY.

*   read MM doc data using the MM doc key
    CALL FUNCTION 'ASH_MM_MATBEL_READ'
      EXPORTING
        i_borident     = ls_borident
      TABLES
        et_mkpf        = lt_mkpf
        et_mseg        = ct_mseg
      EXCEPTIONS
        error_message  = 1
        OTHERS         = 4.

*   do not propagate the internal messages from the archive,
    IF sy-subrc IS INITIAL.

*     get the MM doc header line
      LOOP AT  lt_mkpf       ASSIGNING  <ls_mkpf>.
        IF  <ls_mkpf>-mblnr =  i_mat_doc   AND
            <ls_mkpf>-mjahr =  i_doc_year.
*         OK MM doc found
          MOVE : <ls_mkpf>   TO  cs_mkpf,
                 abap_true   TO  cv_flag_archive.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF  cv_flag_archive = abap_true.
*   the MM doc was found in the archive:
*   does the user want to see the success message?
    CALL FUNCTION 'ME_CHECK_T160M'
      EXPORTING
        I_ARBGB          = 'MIGO'
        I_MSGNR          = '071'
      EXCEPTIONS
        NOTHING          = 0
        OTHERS           = 1.

    IF SY-SUBRC <> 0.
*     Material document &1 &1 read from archive
      MESSAGE S071(MIGO)     WITH  i_mat_doc i_doc_year.
    ENDIF.
  ENDIF.

ENDMETHOD.                  " material_doc_from_archive     "n1306620
                                                            "n1306620
* --- end   of changes -------------------------------------"n1306620