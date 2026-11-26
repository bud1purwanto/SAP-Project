*&---------------------------------------------------------------------*
*&  Include           LMIGOKU3                                         *
*&---------------------------------------------------------------------*
METHOD um_fields_fill.

  DATA: lt_xbwtar      TYPE STANDARD TABLE OF bwtar,
        ls_xbwtar      TYPE bwtar,
        ls_mtcom       TYPE mtcom,
        l_status       TYPE migo_fs_status,
        l_lines        TYPE sy-tabix,
        ls_mcha_buffer TYPE mcha,
        ls_got001l     TYPE got001l,
        ls_migo_fields TYPE tys_migo_move_fields,
        lt_migo_fields TYPE tyt_migo_move_fields.

  DATA lo_badi_batch_number_int TYPE REF TO badi_batch_number_int.

* Get the complete field selection information for the movement type
  CALL METHOD cl_mmim_migo_move_fields=>get_fields
    EXPORTING
      i_bwart   = cs_goitem-bwart
    IMPORTING
      et_fields = lt_migo_fields.

* SPECIAL STOCK IDENTIFIER______________________________________________
* Copy MAT_LIFNR/MAT_KUNNR to UMMAT-fields, if sending and receiving
* special stock are the same. Not useful for special stock E/Q, because
* it is possible that UMMAT-field <> MAT-field
  IF cs_goitem-sobkz = cs_goitem-umsok.
    cs_goitem-ummat_lifnr      = cs_goitem-mat_lifnr.
    cs_goitem-ummat_vendorname = cs_goitem-mat_vendorname.
    cs_goitem-ummat_kunnr      = cs_goitem-mat_kunnr.
    cs_goitem-ummat_custname   = cs_goitem-mat_custname.
    IF cs_goitem-ummat_pspnr IS INITIAL.
      cs_goitem-ummat_pspnr = cs_goitem-mat_pspnr.
    ENDIF.
    IF cs_goitem-ummat_kdauf IS INITIAL.
      cs_goitem-ummat_kdauf = cs_goitem-mat_kdauf.
    ENDIF.
    IF cs_goitem-ummat_kdpos IS INITIAL.
      cs_goitem-ummat_kdpos = cs_goitem-mat_kdpos.
    ENDIF.
  ENDIF.
ENHANCEMENT-POINT LMIGOKU3_01 SPOTS ES_SAPLMIGO.
* MATNR/UMATNR__________________________________________________________
  CLEAR ls_migo_fields.
  READ TABLE lt_migo_fields INTO ls_migo_fields
             WITH KEY fieldname = 'UMMAT'.
  IF ls_migo_fields-entry <> '+'.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = 'GOITEM-UMMAKTX'
        i_global_counter = cs_goitem-global_counter
      RECEIVING
        r_status         = l_status.
    IF ( l_status = lcl_migo_screenmodification=>c_invisible ) OR
       ( l_status = lcl_migo_screenmodification=>c_input AND
         cs_goitem-ummaktx IS INITIAL AND
         cs_goitem-xummaktx_manual IS INITIAL ).
      cs_goitem-ummaktx = cs_goitem-maktx.
      cs_goitem-ummat   = cs_goitem-matnr.
    ENDIF.
  ENDIF.
* WERKS/UMWRK___________________________________________________________
  CLEAR ls_migo_fields.
  READ TABLE lt_migo_fields INTO ls_migo_fields
             WITH KEY fieldname = 'UMWRK'.
  IF ls_migo_fields-entry <> '+'.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = 'GOITEM-UMNAME1'
        i_global_counter = cs_goitem-global_counter
      RECEIVING
        r_status         = l_status.
    IF ( l_status = lcl_migo_screenmodification=>c_invisible ) OR
       ( l_status = lcl_migo_screenmodification=>c_input AND
         cs_goitem-umname1 IS INITIAL AND
         cs_goitem-xumname1_manual IS INITIAL ).
      cs_goitem-umname1 = cs_goitem-name1.
      cs_goitem-umwrk   = cs_goitem-werks.
    ENDIF.
  ENDIF.
* LGORT/UMLGO___________________________________________________________
  CLEAR ls_migo_fields.
  READ TABLE lt_migo_fields INTO ls_migo_fields
             WITH KEY fieldname = 'UMLGO'.
  IF ls_migo_fields-entry <> '+'.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = 'GOITEM-UMLGOBE'
        i_global_counter = cs_goitem-global_counter
      RECEIVING
        r_status         = l_status.
    IF ( l_status = lcl_migo_screenmodification=>c_invisible ) OR
       ( l_status = lcl_migo_screenmodification=>c_input AND
         cs_goitem-umlgobe IS INITIAL AND
         cs_goitem-xumlgobe_manual IS INITIAL ).
*   Check if issuing storage location exists in receiving plant
      CALL METHOD lcl_migo_buffer=>storage_loc_get
        EXPORTING
          i_plant       = cs_goitem-umwrk
          i_storage_loc = cs_goitem-lgort
        RECEIVING
          e_storage_loc = ls_got001l
        EXCEPTIONS
          OTHERS        = 1.
*   Check if storage loc. exists in plant
      IF sy-subrc = 0.
        cs_goitem-umlgobe = ls_got001l-lgobe.
        cs_goitem-umlgo   = cs_goitem-lgort.
      ELSE.
        CLEAR: cs_goitem-umlgo,
               cs_goitem-umlgobe.
      ENDIF.
    ENDIF.
  ENDIF.
* Storage location without relevance for special stock 'OPTVW'
* (-> no storage location useful).
  IF cs_goitem-umsok CA 'OPTVW'
    OR ( cs_goitem-bustr = '303' AND                             "581603
    lcl_migo_screenmodification=>get_required( i_global_counter
    = cs_goitem-global_counter i_field = 'GOITEM-UMLGOBE' ) = SPACE ).
    CLEAR: cs_goitem-umlgo,
           cs_goitem-umlgobe.
  ENDIF.

* begin of note 608593
* And only if something has changed since the last run
  IF ( ( ps_pslbuffer-umwrk   <> cs_goitem-umwrk   ) OR
       ( ps_pslbuffer-umname1 <> cs_goitem-umname1 ) OR
       ( ps_pslbuffer-umlgo   <> cs_goitem-umlgo   ) OR
       ( ps_pslbuffer-umlgobe <> cs_goitem-umlgobe ) ).
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = 'GOITEM-UMNAME1'
        i_global_counter = cs_goitem-global_counter
      RECEIVING
        r_status         = l_status.
* Convert every time; BUT NOT if UMWRK is initial, because it
* is not visible
    IF NOT
      ( cs_goitem-umwrk IS INITIAL AND
        l_status = lcl_migo_screenmodification=>c_invisible ).
      CALL METHOD mm_sloc_convert
        CHANGING
          c_plant     = cs_goitem-umwrk
          c_planttext = cs_goitem-umname1
          c_sloc      = cs_goitem-umlgo
          c_sloctext  = cs_goitem-umlgobe.
    ENDIF.
    IF cs_goitem-umwrk IS INITIAL AND NOT cs_goitem-umlgo IS INITIAL.
      cs_goitem-umlgobe = cs_goitem-umlgo.
      CLEAR cs_goitem-umlgo.
    ENDIF.
    MOVE-CORRESPONDING cs_goitem TO ps_pslbuffer.
  ENDIF.
* end of note 608593

* Material read________________________________________________________
  CALL METHOD transfer_read
    CHANGING
      cs_goitem = cs_goitem.

* CHARG/UMCHA___________________________________________________________
  CLEAR ls_migo_fields.
  READ TABLE lt_migo_fields INTO ls_migo_fields
             WITH KEY fieldname = 'UMCHA'.
  IF ls_migo_fields-entry <> '+'.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = 'GOITEM-UMCHA'
        i_global_counter = cs_goitem-global_counter
      RECEIVING
        r_status         = l_status.
    IF ( l_status = lcl_migo_screenmodification=>c_invisible OR
         ( l_status = lcl_migo_screenmodification=>c_input   AND
           cs_goitem-umcha IS INITIAL AND
           cs_goitem-xumcha_manual IS INITIAL
          )
        )
       AND NOT cs_goitem-umxchpf IS INITIAL.
      cs_goitem-umcha = cs_goitem-charg.
      TRY.
        GET BADI lo_badi_batch_number_int.
        CALL BADI lo_badi_batch_number_int->change_um_fields
          CHANGING
            cs_goitem = cs_goitem.
        CATCH cx_badi_not_implemented .
      ENDTRY.
    ENDIF.
  ENDIF.
* No batch management or movement type 303 or batch on client level
  IF cs_goitem-bustr = '303' OR cs_goitem-umxchpf IS INITIAL
    OR ( lcl_migo_globals=>batch_level = 2
    AND cs_goitem-ummat <> cs_goitem-matnr                       "848262
    AND cs_goitem-umcha = cs_goitem-charg
    AND cs_goitem-chneu CA ' ABC' ).                             "748216
    CLEAR cs_goitem-umcha.
  ENDIF.

* BWTAR/UMBAR___________________________________________________________
  CLEAR ls_migo_fields.
  READ TABLE lt_migo_fields INTO ls_migo_fields
             WITH KEY fieldname = 'UMBAR'.
  IF ls_migo_fields-entry <> '+'.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = 'GOITEM-UMBAR'
        i_global_counter = cs_goitem-global_counter
      RECEIVING
        r_status         = l_status.
    IF ( l_status = lcl_migo_screenmodification=>c_invisible OR
         ( l_status = lcl_migo_screenmodification=>c_input  AND
           cs_goitem-umbar IS INITIAL AND
           cs_goitem-xumbar_manual IS INITIAL
          )
        )
       AND NOT cs_goitem-umbwtty IS INITIAL.
         call method valuation_type_set
           EXPORTING i_matnr     = cs_goitem-ummat
                     i_werks     = cs_goitem-umwrk
                     i_lgort     = cs_goitem-umlgo
                     i_charg     = cs_goitem-umcha
                     i_sobkz     = cs_goitem-umsok
                     i_mat_kdauf = cs_goitem-ummat_kdauf
                     i_mat_kdpos = cs_goitem-ummat_kdpos
                     i_mat_pspnr = cs_goitem-ummat_pspnr
                     i_kzbaa     = cs_goitem-umkzbaa
           IMPORTING e_bwtar     = cs_goitem-umbar.
*     If valuation type is not yet filled, use valuation type of the
*     issuing side if defined.
      IF cs_goitem-umbar IS INITIAL AND cs_goitem-umkzbaa IS INITIAL.
        cs_goitem-umbar = cs_goitem-bwtar.
      ENDIF.
      IF cl_ops_switch_check=>mm_om1_sfws_sc( ) EQ cl_ops_switch_check=>switch_active_true.
*     In case of BUSTR 30A, 30C, 63A and 63C UMBAR use valuation type of the issuing side if defined.
        IF cs_goitem-umbar IS INITIAL
          and ( cs_goitem-bustr EQ '30A'
          OR    cs_goitem-bustr EQ '30C'
          OR    cs_goitem-bustr EQ '63A'
          OR    cs_goitem-bustr EQ '63C' ).
            cs_goitem-umbar = cs_goitem-bwtar.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* Begin Outsourced Manufacturing EhP 4
  IF cs_goitem-kzbwa = '02' and s_control-refdoc = 'R01'.
    IF cs_goitem-charg IS NOT INITIAL.
      cs_goitem-umcha = cs_goitem-charg.
    ENDIF.
    IF cs_goitem-bwtar IS NOT INITIAL.
      cs_goitem-umbar = cs_goitem-bwtar.
    ENDIF.
  ENDIF.
* end Outsourced Manufacturing EhP 4

  IF cs_goitem-umbwtty IS INITIAL.
    CLEAR cs_goitem-umbar.
  ENDIF.

ENDMETHOD.                    "um_fields_fill

*----------------------------------------------------------------------*
* METHOD um_fields_fill_for_posting
*----------------------------------------------------------------------*
METHOD um_fields_fill_for_posting.
  DATA: ls_manu_fields TYPE migo_manu_fields,
        ls_goitem      TYPE goitem,
        ls_old_goitem  TYPE goitem,
        l_tabix        TYPE sy-tabix.

  LOOP AT pt_goitem INTO ls_goitem.
    ls_old_goitem = ls_goitem.
    l_tabix = sy-tabix.
    MOVE-CORRESPONDING ls_goitem TO ls_manu_fields.
    CHECK NOT ls_manu_fields IS INITIAL.
    CLEAR ls_manu_fields.
    MOVE-CORRESPONDING ls_manu_fields TO ls_goitem.
*   Fill UM-fields
    CALL METHOD um_fields_fill
      CHANGING
        cs_goitem = ls_goitem.
*   Modify the data in goitem
    CALL METHOD line_modify
      EXPORTING
        i_tabix           = l_tabix
        i_authority_check = abap_false
      CHANGING
        cs_goitem         = ls_goitem.
  ENDLOOP.

ENDMETHOD.                    "um_fields_fill_for_posting

************************************************************************
* Method umsok_get
* This method checks if there is an entry in table t156b for a given
* combination of bwart and sobkz.
* If there is an entry, t156b-umsok is filled in cs_goitem-umsok.
* If no entry exists, c_sobkz, cs_goitem-sobkz, cs_goitem-umsok are
* cleared. If there is no entry for bwart at all, cs_goitem-bwart is
* cleared too. Depending on the parameter i_error_type there can be an
* e-message, a s-message or no message.
************************************************************************
METHOD umsok_get.
  DATA: l_sobkz TYPE sobkz,
        l_bwart TYPE bwart,
        l_bustr TYPE bustr,
        l_xtransfer TYPE xtransfer_mvt.
* This method must not be performed:
* - during subsequent adjustment, in display - and cancel mode
* - for automatic lines (of transfer postings) they already has a valid
*   umsok
* - when BWART is not filled yet, e.g. when changing refdoc to
*   reservation
* - for non-transfer movements (-> migo_t156)
  CHECK NOT s_control-action = 'A11' AND    "subsequent adjustment
        NOT s_control-action = 'A03' AND    "cancel
        NOT s_control-action = 'A04'.       "display
  CHECK cs_goitem-xauto <> x.
  CHECK NOT cs_goitem-bwart IS INITIAL.
  SELECT SINGLE bustr FROM t156 INTO  l_bustr
                                WHERE bwart = cs_goitem-bwart.
  SELECT SINGLE xtransfer_mvt FROM migo_t156
                              INTO l_xtransfer
                              WHERE bustr = l_bustr.
  CHECK l_xtransfer = 'X'.
  SELECT SINGLE umsok INTO cs_goitem-umsok FROM t156b
     WHERE bwart = cs_goitem-bwart AND
           sobkz = c_sobkz.

ENHANCEMENT-POINT EHP604_LMIGOKU3_01 SPOTS ES_SAPLMIGO .

  IF sy-subrc <> 0.
    l_bwart = cs_goitem-bwart.
    l_sobkz = c_sobkz.
    CLEAR: c_sobkz,
           cs_goitem-sobkz,
           cs_goitem-umsok.
*   combination bwart / sobkz does not exist. does this bwart exist
*   at all?
    SELECT SINGLE bwart INTO l_bwart
                        FROM t156b
                        WHERE bwart = cs_goitem-bwart.
    IF sy-subrc <> 0.
      CLEAR: cs_goitem-bwart,
             cs_goitem-btext.
    ENDIF.
    IF i_error_type = 'S'.
      MESSAGE s057 WITH l_bwart l_sobkz.
    ELSEIF i_error_type = 'E'.
      MESSAGE e057 WITH l_bwart l_sobkz.
    ENDIF.
  ENDIF.
ENDMETHOD.                    "umsok_get
*----------------------------------------------------------------------*
* METHOD mm_sloc_convert (note 608593/modified function mm_sloc_convert)
*----------------------------------------------------------------------*
METHOD mm_sloc_convert.
  data: plant TYPE werks_d,
        sloc  TYPE lgort_d,
        text  TYPE lgobe,
        searchtext TYPE lgobe.
  types: begin of ty_s_hitlist,
           werks TYPE werks_d,
           name1 TYPE name1,
           lgort TYPE lgort_d,
           lgobe TYPE lgobe,
         end of ty_s_hitlist.
  data: wa_hitlist type ty_s_hitlist,
        t_hitlist  type table of ty_s_hitlist.
  data: lines type i,
        title(80).
  DATA: wa_FC TYPE SLIS_FIELDCAT_ALV,
        fc type table of SLIS_FIELDCAT_ALV,
        SELECTION TYPE SLIS_SELFIELD.
  data: wa_pt_t001l type ty_s_t001l.
  data: wa_pt_t001w type ty_s_t001w.

* Load table(s)
  if p_t001w_initialized = space.
    refresh pt_t001w.
    select werks name1
         into corresponding fields of table pt_t001w
         from t001w.
    sort pt_t001w by werks.
    loop at pt_t001w into wa_pt_t001w.
      wa_pt_t001w-nameg = wa_pt_t001w-name1.
      translate wa_pt_t001w-nameg to upper case.          "#EC TRANSLANG
      modify pt_t001w from wa_pt_t001w.
    endloop.
    p_t001w_initialized = 'X'.
  endif.
  SET LOCALE LANGUAGE sy-langu.
  if p_t001l_initialized = space.
    refresh pt_t001l.
    select werks lgort lgobe
         into corresponding fields of table pt_t001l
         from t001l.
    sort pt_t001l by werks lgort.
    loop at pt_t001l into wa_pt_t001l.
      wa_pt_t001l-lgobg = wa_pt_t001l-lgobe.
      translate wa_pt_t001l-lgobg to upper case.          "#EC TRANSLANG
      modify pt_t001l from wa_pt_t001l.
    endloop.
    p_t001l_initialized = 'X'.
  endif.
* If no plaintext given -> delete storage location
  if c_sloctext = space.
    clear c_sloc.
    exit.
  endif.
* Check given combination against the plaintext.
  if c_plant <> space and c_sloc <> space.
    read table pt_t001l with key werks = c_plant
                                lgort = c_sloc  binary search
                                into wa_pt_t001l.
    if wa_pt_t001l-lgobe = c_sloctext.
      exit.
    endif.
  endif.
  text = c_sloctext.
  translate text to upper case.                           "#EC TRANSLANG
  shift text left deleting leading space.
  SET LOCALE LANGUAGE SPACE.

* Try direct access, interpreting the first four characters as ID
  sloc = text.
  plant = c_plant.
  refresh t_hitlist.

* If sloc = 'ABCD' and text = 'ABCDE', then this statement will be
* false. When the text field is longer than sloc field, then it is
* wrong to interpret the first four characters of text field as ID.
  if sloc cs text.
* Plant given -> direct table access
    if plant <> space.
      read table pt_t001l with key werks = plant
                                  lgort = sloc  binary search
                                  into wa_pt_t001l.
      if sy-subrc = 0.
        read table pt_t001l with key werks = plant lgort = sloc
          binary search into wa_pt_t001l.
        c_sloctext = wa_pt_t001l-lgobe.
        read table pt_t001w with key werks = plant into wa_pt_t001w.
        c_planttext = wa_pt_t001w-name1.
        c_plant = plant.
        c_sloc  = sloc.
        exit.
      endif.
    else.
* No plant -> loop t_t001l.
      loop at pt_t001l into wa_pt_t001l where lgort = sloc.
        move-corresponding wa_pt_t001l to wa_hitlist.
        append wa_hitlist to t_hitlist.
      endloop.
    endif.
  endif.

  describe table t_hitlist lines lines.
  if lines = 0.
* Final: Full text search.
    searchtext = text.
    if text = '*'. clear searchtext. endif.
    if plant = space.
      loop at pt_t001l into wa_pt_t001l.
        if wa_pt_t001l-lgobg cs searchtext or
          wa_pt_t001l-lgort cs searchtext.
            move-corresponding wa_pt_t001l to wa_hitlist.
            append wa_hitlist to t_hitlist.
        endif.
      endloop.
    else.
      loop at pt_t001l into wa_pt_t001l where werks = plant.
        if wa_pt_t001l-lgobg cs searchtext or
          wa_pt_t001l-lgort cs searchtext.
            move-corresponding wa_pt_t001l to wa_hitlist.
            append wa_hitlist to t_hitlist.
        endif.
      endloop.
    endif.
  endif.
* Check hitlist
  describe table t_hitlist lines lines.
  if lines = 0.
* No sloc/plant found: suggest all
    if plant = space.
      message s009(migo) with text.
      loop at pt_t001l into wa_pt_t001l.
        move-corresponding wa_pt_t001l to wa_hitlist.
        append wa_hitlist to t_hitlist.
      endloop.
    else.
      message s010(migo) with text c_plant.
      loop at pt_t001l into wa_pt_t001l where werks = plant.
        move-corresponding wa_pt_t001l to wa_hitlist.
        append wa_hitlist to t_hitlist.
      endloop.
    endif.
* Exactly one match -> take it
  elseif lines = 1.
    read table pt_t001l with key werks = wa_hitlist-werks
     lgort = wa_hitlist-lgort binary search into wa_pt_t001l.
    c_sloctext = wa_pt_t001l-lgobe.
    read table pt_t001w with key werks = wa_hitlist-werks
      into wa_pt_t001w.
    c_planttext = wa_pt_t001w-name1.
    c_plant = wa_hitlist-werks.
    c_sloc  = wa_hitlist-lgort.
    exit.
  endif.
* Create PopUp
  loop at t_hitlist into wa_hitlist.
    read table pt_t001w with key werks = wa_hitlist-werks binary search
      into wa_pt_t001w.
    wa_hitlist-name1 = wa_pt_t001w-name1.
    modify t_hitlist from wa_hitlist.
  endloop.
* Send PopUp
  title = text-002.
  replace '&' with text into title.
  refresh fc.
  wa_fc-fieldname = 'WERKS'. wa_fc-ref_tabname = 'T001W'.
  append wa_fc to fc.
  wa_fc-fieldname = 'NAME1'. wa_fc-ref_tabname = 'T001W'.
  append wa_fc to fc.
  wa_fc-fieldname = 'LGORT'. wa_fc-ref_tabname = 'T001L'.
  append wa_fc to fc.
  wa_fc-fieldname = 'LGOBE'. wa_fc-ref_tabname = 'T001L'.
  append wa_fc to fc.
  caLL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      I_TITLE                 = title
      i_tabname               = 'T_HITLIST'
      IT_FIELDCAT             = fc[]
    IMPORTING
      ES_SELFIELD             = selection
    tables
      t_outtab                = t_hitlist[].
  read table t_hitlist index selection-tabindex into wa_hitlist.
  if sy-subrc = 0.
    read table pt_t001l with key werks = wa_hitlist-werks
     lgort = wa_hitlist-lgort binary search into wa_pt_t001l.
    c_sloctext = wa_pt_t001l-lgobe.
    read table pt_t001w with key werks = wa_hitlist-werks
      into wa_pt_t001w.
    c_planttext = wa_pt_t001w-name1.
    c_plant = wa_hitlist-werks.
    c_sloc  = wa_hitlist-lgort.
    exit.
  else.
    clear: c_sloc, c_sloctext.
  endif.

ENDMETHOD.                    "mm_sloc_convert