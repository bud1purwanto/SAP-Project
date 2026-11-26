*&---------------------------------------------------------------------*
*&  Include           LMIGOKGA
*&  Process generic articles
*&---------------------------------------------------------------------*
METHOD purchase_order_fill_ga.
* Read generic article and its variants from PO to modify goitem
  FIELD-SYMBOLS: <ls_goitem_top>   TYPE goitem.
  DATA: lt_goitem                  TYPE TABLE OF goitem.
* ATTYP = 01 => Generic article, GOITEM-XGATYPE = P (parent item)
* ATTYP = 02 => Variant (general),
*               if related to a generic article: GOITEM-XGATYPE = C
*               (component)
  CASE is_poitem-attyp.
    WHEN '01'.
      cs_goitem-xgatype = 'P'.
      CLEAR: cs_goitem-erfmg.
    WHEN '02'.
*     derive the last header of the GA
      lt_goitem[] = pt_goitem[].
      SORT lt_goitem BY global_counter DESCENDING.
      READ TABLE lt_goitem ASSIGNING <ls_goitem_top>
         WITH KEY xgatype = p
                  ebeln   = cs_goitem-ebeln
                  ebelp   = is_poitem-uebpo
                  lfbnr   = cs_goitem-lfbnr.
      CHECK sy-subrc = 0.
*     No variants with delivery complete indicator
      IF is_poitem-elikz = abap_true
        AND is_poitem-erfmg >= is_poitem-uetmg.
        CLEAR: cs_goitem.
        EXIT.
      ENDIF.
*     organizational data for variants
      cs_goitem-parent = <ls_goitem_top>-global_counter.
      cs_goitem-xgatype = 'C'.
      cs_goitem-depth  = <ls_goitem_top>-depth + 1.
      cs_goitem-zeile  = <ls_goitem_top>-zeile.
      CLEAR: cs_goitem-global_counter.
  ENDCASE.
ENDMETHOD.                    "purchase_order_fill_ga


METHOD purchase_order_ga_header_add.
* In case of more than one GA in a PO we get only one GA header
* and have to add the missing headers
  DATA: lt_poitem                  TYPE ty_t_poitem,
        ls_poitem                  TYPE ty_s_poitem,
        lt_sawe                    TYPE ty_t_sawe,
        ls_sawe                    TYPE ty_s_sawe.
  LOOP AT ct_poitem INTO ls_poitem WHERE attyp <> '02'
                                   AND   attyp <> '01'.
    APPEND ls_poitem TO lt_poitem.
  ENDLOOP.
  READ TABLE ct_poitem WITH KEY attyp = '01'
    TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.
  LOOP AT ct_poitem INTO ls_poitem WHERE attyp = '02'.
    MOVE-CORRESPONDING ls_poitem TO ls_sawe.
    COLLECT ls_sawe INTO lt_sawe.
  ENDLOOP.
  CHECK NOT ls_poitem-lfpos IS INITIAL.
  LOOP AT lt_sawe INTO ls_sawe.
    READ TABLE ct_poitem INTO ls_poitem
               WITH KEY attyp = '01'
                        ebeln = ls_sawe-ebeln
                        ebelp = ls_sawe-uebpo.
    MOVE-CORRESPONDING ls_sawe TO ls_poitem.
    APPEND ls_poitem TO lt_poitem.
  ENDLOOP.
  LOOP AT ct_poitem INTO ls_poitem WHERE attyp = '02'.
    APPEND ls_poitem TO lt_poitem.
  ENDLOOP.
  SORT lt_poitem BY lfbnr lfpos ebeln ebelp.
  ct_poitem[] = lt_poitem[].
ENDMETHOD.                    "purchase_order_ga_header_add


METHOD ga_variants_edit.
* Edit variants of generic article; displays matrix of variants
  DATA: ls_goitem_top    TYPE goitem,
        ls_goitem_comp   TYPE goitem,
        lt_var_goitem    TYPE ty_t_var_goitem,
        ls_var_goitem    TYPE ty_s_var_goitem,
        ls_mtcom         TYPE mtcom,
        ls_mbefu         TYPE mbefu,
        lt_var_values    TYPE ty_t_mtrx_werte,
        ls_var_values    TYPE mtrx_werte,
        l_global_counter TYPE migo_global_counter,
        ls_data_ga       TYPE mtrx_kopf.
* Derive right item if line is expanded or not
  CALL METHOD lcl_migo_globals=>kernel->line_mapping
    EXPORTING
      i_line           = i_line
    IMPORTING
      e_global_counter = l_global_counter
    EXCEPTIONS
      OTHERS           = 1.
* line of generic article
  READ TABLE pt_goitem INTO ls_goitem_top
     WITH KEY global_counter = l_global_counter
              xgatype        = p.
  IF sy-subrc <> 0.
    READ TABLE pt_goitem INTO ls_goitem_comp
      WITH KEY global_counter = l_global_counter
               xgatype        = c.
    READ TABLE pt_goitem INTO ls_goitem_top
      WITH KEY global_counter = ls_goitem_comp-parent
               xgatype        = p.
    IF sy-subrc <> 0.
      ls_goitem_top = is_goitem.
    ENDIF.
  ENDIF.
  CHECK ls_goitem_top-xgatype = p AND s_action-cancel = abap_false.
* Display table control if the user does not have authorization
  IF line_add_authority_check( ls_goitem_top ) = abap_false.
    g_tablev_current_dyn = '0200'.
    MESSAGE e120(M7) WITH ls_goitem_top-werks.
    EXIT.
  ENDIF.
* The fields of detail screen must not be ready for input, if the user
* applies data into the matrix of variants.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_inversion      = abap_true
      i_one_way        = abap_true
      i_global_counter = l_global_counter
      i_status         = lcl_migo_screenmodification=>c_visible.

  REFRESH: lt_var_values, lt_var_goitem.
  LOOP AT pt_goitem INTO ls_var_goitem
       WHERE xgatype = c
       AND   parent  = ls_goitem_top-global_counter.
    IF s_action-cancel = abap_false AND s_action-display = abap_false.
      CHECK ls_var_goitem-parent  = ls_goitem_top-global_counter.
    ENDIF.
    APPEND ls_var_goitem TO lt_var_goitem.
  ENDLOOP.
  LOOP AT lt_var_goitem INTO ls_var_goitem
    WHERE xgatype = c.
* Mode E: Quantity
    CLEAR ls_var_values.
    ls_var_values-matnr = ls_var_goitem-matnr.
    ls_var_values-mode  = e.
    ls_var_values-fwert = ls_var_goitem-erfmg.
    APPEND ls_var_values TO lt_var_values.
* Mode C: Batch
    CLEAR ls_var_values.
    ls_var_values-matnr = ls_var_goitem-matnr.
    ls_var_values-mode  = c.
    ls_var_values-cwert = ls_var_goitem-charg.
    IF ls_var_goitem-xchpf IS INITIAL.
      ls_var_values-wtsta = a.
    ENDIF.
    APPEND ls_var_values TO lt_var_values.
* Mode B: Stock type
    IF ls_var_goitem-migo_insmk IS INITIAL.
      ls_var_goitem-migo_insmk = ls_goitem_top-migo_insmk.
    ENDIF.
    CLEAR ls_var_values.
    ls_var_values-matnr = ls_var_goitem-matnr.
    ls_var_values-mode  = b.
    ls_var_values-cwert = ls_var_goitem-migo_insmk.
    APPEND ls_var_values TO lt_var_values.
* Mode O: Storage location
    IF ls_var_goitem-lgort IS INITIAL.
      ls_var_goitem-lgort = ls_goitem_top-lgort.
    ENDIF.
    CLEAR ls_var_values.
    ls_var_values-matnr = ls_var_goitem-matnr.
    ls_var_values-mode  = o.
    ls_var_values-cwert = ls_var_goitem-lgort.
    APPEND ls_var_values TO lt_var_values.
    IF ls_goitem_top-kzbew = b.
* Mode M: Quantity in unit of entry
      CLEAR ls_var_values.
      ls_var_values-matnr = ls_var_goitem-matnr.
      ls_var_values-mode  = m.
      ls_var_values-fwert = ls_var_goitem-bsmng.
      ls_var_values-wtsta = a.
      APPEND ls_var_values TO lt_var_values.
* Mode L: Quantity in unit of measure from delivery note
      CLEAR ls_var_values.
      ls_var_values-matnr = ls_var_goitem-matnr.
      ls_var_values-mode  = l.
      ls_var_values-cwert = ls_var_goitem-lsmng.
      APPEND ls_var_values TO lt_var_values.
* Mode H: Vendor Batch Number
      CLEAR ls_var_values.
      ls_var_values-matnr = ls_var_goitem-matnr.
      ls_var_values-mode  = h.
      ls_var_values-cwert = ls_var_goitem-licha.
      IF ls_var_goitem-xchpf IS INITIAL.
        ls_var_values-wtsta = a.
      ENDIF.
      APPEND ls_var_values TO lt_var_values.
    ENDIF.
  ENDLOOP.

  IF lt_var_values IS INITIAL.
    g_tablev_current_dyn = '0201'.
  ENDIF.
  MOVE-CORRESPONDING ls_goitem_top TO ls_data_ga.
  MOVE-CORRESPONDING ls_goitem_top TO ls_mtcom.
  ls_mtcom-kenng = 'MBEFU'.

  CALL FUNCTION 'MATERIAL_READ'
    EXPORTING
      schluessel = ls_mtcom
    IMPORTING
      matdaten   = ls_mbefu
    EXCEPTIONS
      OTHERS     = 4.

  ls_data_ga-mtart = ls_mbefu-mtart.
  ls_data_ga-attyp = ls_mbefu-attyp.
  ls_data_ga-meins = ls_goitem_top-erfme.

  CALL FUNCTION 'MB_PROCESS_VARIANTS'
    EXPORTING
      p_kopfdaten   = ls_data_ga
      p_application = 'MB'
      p_aktyp       = h
      p_aufruf      = i_new_variant
      p_subscr      = 'X'
    TABLES
      var_values    = lt_var_values
    EXCEPTIONS
      OTHERS        = 1.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDMETHOD.                    "ga_variants_edit


METHOD ga_line_modify.
* change quantity of generic article as total of variant's quantity
* change expand button according to components
* copy UMWRK from GA to its variants in case transfer postings
* set TAKE_IT of GA if TAKE_IT of any corresponding variant is set
  DATA: ls_goitem_top      TYPE goitem,
        ls_goitem_comp     TYPE goitem,
        ls_change_takeit   TYPE ty_s_change_takeit,
        ls_change_children TYPE ty_s_change_children,
        l_tabix            TYPE sytabix.

  CHECK s_action-cancel = abap_false AND s_action-display = abap_false.
  CASE is_new_goitem-xgatype.
    WHEN c.
      MOVE-CORRESPONDING is_new_goitem TO ls_goitem_comp.
      READ TABLE pt_goitem INTO ls_goitem_top
        WITH KEY xgatype    = p
             global_counter = ls_goitem_comp-parent.
      CHECK sy-subrc = 0.
      l_tabix = sy-tabix.
      IF ls_goitem_comp-invisible = abap_false.
        ls_goitem_top-expand = c_icon_collapse.
      ELSE.
        ls_goitem_top-expand = c_icon_expand.
      ENDIF.
    WHEN p.
      LOOP AT pt_goitem INTO ls_goitem_comp
        WHERE parent  = is_new_goitem-global_counter
        AND   lgort   = is_old_goitem-lgort
        AND   xgatype = c.
        IF sy-tabix > 0 AND is_old_goitem-lgort <> is_new_goitem-lgort.
          READ TABLE pt_change_children
            WITH KEY glc = ls_goitem_comp-global_counter
            TRANSPORTING NO FIELDS.
          CHECK sy-subrc <> 0.
          ls_change_children-glc       = ls_goitem_comp-global_counter.
          ls_change_children-fieldname = 'GOITEM-LGORT'.
          APPEND ls_change_children TO pt_change_children.
        ENDIF.
      ENDLOOP.
      CALL METHOD lcl_migo_globals=>kernel->status_derive.
      MOVE-CORRESPONDING is_new_goitem TO ls_goitem_top.
  ENDCASE.
  CLEAR: ls_goitem_top-erfmg, ls_goitem_top-menge.
  LOOP AT pt_goitem INTO ls_goitem_comp
     WHERE parent  = ls_goitem_top-global_counter
     AND   take_it = abap_true
     AND   xgatype = c.
    ls_goitem_top-take_it = abap_true.
    ls_goitem_comp-sobkz = ls_goitem_top-sobkz.
    IF NOT ls_goitem_top-mat_lifnr IS INITIAL
       AND ls_goitem_comp-mat_lifnr IS INITIAL.
      ls_goitem_comp-mat_lifnr      = ls_goitem_top-mat_lifnr.
      ls_goitem_comp-mat_vendorname = ls_goitem_top-mat_vendorname.
    ENDIF.
    IF NOT ls_goitem_top-lifnr IS INITIAL
       AND ls_goitem_comp-lifnr IS INITIAL.
      ls_goitem_comp-lifnr          = ls_goitem_top-lifnr.
      ls_goitem_comp-vendorname     = ls_goitem_top-vendorname.
    ENDIF.
    IF NOT ls_goitem_top-grund IS INITIAL
       AND ls_goitem_comp-grund IS INITIAL.
      ls_goitem_comp-grund = ls_goitem_top-grund.
    ENDIF.
    IF NOT ls_goitem_top-sgtxt IS INITIAL
       AND ls_goitem_comp-sgtxt IS INITIAL.
      ls_goitem_comp-sgtxt = ls_goitem_top-sgtxt.
    ENDIF.
    IF NOT ls_goitem_top-ablad IS INITIAL
       AND ls_goitem_comp-ablad IS INITIAL.
      ls_goitem_comp-ablad = ls_goitem_top-ablad.
    ENDIF.
    IF NOT ls_goitem_top-wempf IS INITIAL
       AND ls_goitem_comp-wempf IS INITIAL.
      ls_goitem_comp-wempf = ls_goitem_top-wempf.
    ENDIF.
    IF ls_goitem_top-lgort IS INITIAL
       AND NOT ls_goitem_comp-lgort IS INITIAL.
      ls_goitem_top-lgort = ls_goitem_comp-lgort.
      ls_goitem_top-lgobe = ls_goitem_comp-lgobe.
    ENDIF.
    IF ls_goitem_comp-erfmg = 0.
      CLEAR ls_goitem_comp-take_it.
    ENDIF.
    IF s_action-migo_mode = 'GT'.
      ls_goitem_comp-umsok   = ls_goitem_top-umsok.
      IF ls_goitem_top-umwrk IS INITIAL.
        ls_goitem_top-umwrk   = ls_goitem_top-werks.
        ls_goitem_top-umname1 = ls_goitem_top-name1.
      ENDIF.
      ls_goitem_comp-umwrk   = ls_goitem_top-umwrk.
      ls_goitem_comp-umname1 = ls_goitem_top-umname1.
      IF NOT ls_goitem_top-ummat_lifnr IS INITIAL
         AND ls_goitem_comp-ummat_lifnr IS INITIAL.
       ls_goitem_comp-ummat_lifnr      = ls_goitem_top-ummat_lifnr.
       ls_goitem_comp-ummat_vendorname = ls_goitem_top-ummat_vendorname.
      ENDIF.
      IF NOT ls_goitem_top-umlgo IS INITIAL
         AND ls_goitem_comp-umlgo IS INITIAL.
        ls_goitem_comp-umlgo   = ls_goitem_top-umlgo.
        ls_goitem_comp-umlgobe = ls_goitem_top-umlgobe.
      ENDIF.
    ENDIF.
    ls_goitem_top-erfmg = ls_goitem_top-erfmg + ls_goitem_comp-erfmg.
    ls_goitem_top-menge = ls_goitem_top-menge + ls_goitem_comp-menge.
    IF sy-tabix > 0.
      MODIFY pt_goitem FROM ls_goitem_comp INDEX sy-tabix.
    ENDIF.
  ENDLOOP.
  IF sy-subrc <> 0.
    CLEAR ls_goitem_top-take_it.
  ENDIF.
* line of generic article
  CHECK l_tabix > 0.
  MODIFY pt_goitem FROM ls_goitem_top INDEX l_tabix.
ENDMETHOD.                    "ga_line_modify


METHOD ga_variants_pai.
* Read data from matrix of variants
  DATA: lt_var_vart      TYPE ty_t_mtrx_vart,
        ls_var_vart      TYPE mtrx_vart,
        l_return_functioncode TYPE c.
  DATA: ls_goitem_top    TYPE goitem,
        ls_goitem_comp   TYPE goitem,
        l_current_tabix  TYPE sytabix,
        l_old_matnr      TYPE matnr,
        lt_var_goitem    TYPE ty_t_var_goitem,
        ls_var_goitem    TYPE ty_s_var_goitem,
        ls_mtcom         TYPE mtcom,
        ls_mbefu         TYPE mbefu,
        lt_var_values    TYPE ty_t_mtrx_werte,
        ls_var_values    TYPE mtrx_werte,
        lt_var_msel      TYPE ty_t_mtrx_msel,
        lt_var_vali      TYPE ty_t_mtrx_vali,
        lt_var_char      TYPE ty_t_mtrx_char,
        ls_control       TYPE lcl_migo_kernel=>ty_s_control,
        l_fcode          TYPE syucomm,
        l_global_counter TYPE migo_global_counter,
        l_matnr          TYPE numc3,
        l_lines          TYPE i,
        l_line           TYPE i.
* Derive right item if line is expanded or not
  CALL METHOD lcl_migo_globals=>kernel->line_mapping
    EXPORTING
      i_line           = i_line
    IMPORTING
      e_global_counter = l_global_counter
    EXCEPTIONS
      OTHERS           = 1.
* line of generic article
  READ TABLE pt_goitem INTO ls_goitem_top
     WITH KEY global_counter = l_global_counter
              xgatype        = p.
  IF sy-subrc <> 0.
    READ TABLE pt_goitem INTO ls_goitem_comp
      WITH KEY global_counter = l_global_counter
               xgatype        = c.
    READ TABLE pt_goitem INTO ls_goitem_top
      WITH KEY global_counter = ls_goitem_comp-parent
               xgatype        = p.
  ENDIF.
  CHECK ls_goitem_top-xgatype = p AND s_action-cancel = abap_false.
  REFRESH: lt_var_values, lt_var_goitem.
  CALL FUNCTION 'WMMA_MATRIX_RETURN_MB'
    IMPORTING
      return_functioncode     = l_return_functioncode
    TABLES
      var_art                 = lt_var_vart
      var_wsel                = lt_var_values
      var_msel                = lt_var_msel
      vb_char                 = lt_var_char
      vb_val                  = lt_var_vali
    EXCEPTIONS
      mode_error              = 1
      inputdata_error         = 2
      no_value                = 3
      no_char                 = 4
      no_cuobj                = 5
      no_classification_found = 6
      classification_error    = 7
      matrix_cancelled        = 8
      OTHERS                  = 9.
  IF sy-subrc <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  CHECK NOT lt_var_values IS INITIAL.
  LOOP AT lt_var_values INTO ls_var_values.
    READ TABLE lt_var_vart INTO ls_var_vart
      WITH KEY cuobj = ls_var_values-cuobj.
    CHECK sy-subrc = 0.
    IF NOT ls_var_vart-matnr IS INITIAL.
      ls_var_values-matnr = ls_var_vart-matnr.
    ELSEIF ls_var_vart-statu = 'H'.
*     new created variant
      ls_var_values-statu = ls_var_vart-statu.
    ENDIF.
    MODIFY lt_var_values FROM ls_var_values.
  ENDLOOP.

* var_goitem-update_mode:
*   A... append
*   M... modify

  REFRESH lt_var_goitem.
  SORT lt_var_values BY matnr mode.
  MOVE-CORRESPONDING ls_goitem_top TO ls_var_goitem.
  CLEAR: l_current_tabix, ls_goitem_top-erfmg, ls_var_goitem-erfmg,
         ls_var_goitem-ummat, ls_var_goitem-umwrk.

* modify existing variants
  LOOP AT pt_goitem INTO ls_var_goitem
       WHERE xgatype = c
       AND   parent  = ls_goitem_top-global_counter.
    CLEAR: ls_var_goitem-erfmg.
    LOOP AT lt_var_values INTO ls_var_values
      WHERE matnr = ls_var_goitem-matnr.
      CASE ls_var_values-mode.
        WHEN e. ls_var_goitem-erfmg      = ls_var_values-fwert.
        WHEN k. ls_var_goitem-elikz      = ls_var_values-cwert.
        WHEN l. ls_var_goitem-lsmng      = ls_var_values-fwert.
        WHEN c. ls_var_goitem-charg      = ls_var_values-cwert.
        WHEN h. ls_var_goitem-licha      = ls_var_values-cwert.
        WHEN b. ls_var_goitem-migo_insmk = ls_var_values-cwert.
        WHEN o. ls_var_goitem-lgort      = ls_var_values-cwert.
        WHEN m. ls_var_goitem-bsmng      = ls_var_values-cwert.
*          WHEN n. ls_var_goitem-ean11_kon  = ls_var_values-cwert.
      ENDCASE.
      ls_var_goitem-update_mode = 'M'.
    ENDLOOP.
    IF sy-subrc <> 0
       AND ls_var_goitem-parent = ls_goitem_top-global_counter.
      CLEAR ls_var_goitem-erfmg.
    ENDIF.
    APPEND ls_var_goitem TO lt_var_goitem.
    DELETE lt_var_values WHERE matnr = ls_var_goitem-matnr.
    l_current_tabix = l_current_tabix + 1.
  ENDLOOP.
* not ordered items
  LOOP AT pt_goitem INTO ls_var_goitem
         WHERE xgatype = c
         AND   parent  = 0.
    CLEAR: ls_var_goitem-erfmg.
    LOOP AT lt_var_values INTO ls_var_values
       WHERE matnr = ls_var_goitem-matnr.
      CASE ls_var_values-mode.
        WHEN e. ls_var_goitem-erfmg      = ls_var_values-fwert.
        WHEN k. ls_var_goitem-elikz      = ls_var_values-cwert.
        WHEN l. ls_var_goitem-lsmng      = ls_var_values-fwert.
        WHEN c. ls_var_goitem-charg      = ls_var_values-cwert.
        WHEN h. ls_var_goitem-licha      = ls_var_values-cwert.
        WHEN b. ls_var_goitem-migo_insmk = ls_var_values-cwert.
        WHEN o. ls_var_goitem-lgort      = ls_var_values-cwert.
        WHEN m. ls_var_goitem-bsmng      = ls_var_values-cwert.
        WHEN n. ls_var_goitem-ean11_kon  = ls_var_values-cwert.
      ENDCASE.
      ls_var_goitem-update_mode = 'M'.
    ENDLOOP.
    CHECK: sy-subrc = 0, ls_var_goitem-erfmg > 0.
    APPEND ls_var_goitem TO lt_var_goitem.
    DELETE lt_var_values WHERE matnr = ls_var_goitem-matnr.
    l_current_tabix = l_current_tabix + 1.
  ENDLOOP.

* Create new variants on database
*   Check if variant is still in pt_goitem
  CLEAR: l_lines, l_line.
  DESCRIBE TABLE lt_var_vart LINES l_line.
  LOOP AT lt_var_vart INTO ls_var_vart WHERE statu = 'H'.
*   number of new variants
    l_lines = l_lines + 1.
  ENDLOOP.
  l_line = l_line - l_lines.
  IF l_line > 0 AND l_lines > 0.
    LOOP AT lt_var_vart INTO ls_var_vart.
      CHECK sy-tabix = l_line.
      l_matnr = l_line + 1.
      l_line = l_line + 1.
      CONCATENATE ls_goitem_top-matnr l_matnr
        INTO ls_var_vart-matnr.
      READ TABLE pt_goitem
                 WITH KEY xgatype = c
                          parent  = ls_goitem_top-global_counter
                          matnr   = ls_var_vart-matnr
                          TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        READ TABLE lt_var_values INTO ls_var_values
          WITH KEY statu = 'H'
                   matnr = space.                   .
        ls_var_values-matnr = ls_var_vart-matnr.
        MODIFY lt_var_values FROM ls_var_values INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.
  READ TABLE lt_var_vart WITH KEY statu = 'H'
    TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    CALL METHOD oref_log->refresh.
    CALL METHOD oref_log->send_data_to_mick.
* Call method to create new variants on database
    CALL METHOD ga_variants_create
      EXPORTING
        is_goitem_top = ls_goitem_top
        it_var_msel   = lt_var_msel
        it_var_char   = lt_var_char
        it_var_vali   = lt_var_vali
      CHANGING
        ct_var_values = lt_var_values
        ct_var_vart   = lt_var_vart.
*   Display error messages e.g. if variant could not be created
    IF oref_log->message_exist_all( i_error_only = abap_true )
                  = abap_true.
      CALL METHOD oref_log->display.
    ENDIF.
  ENDIF.

* Add new variants
  LOOP AT lt_var_values INTO ls_var_values.
    CASE ls_var_values-mode.
      WHEN e. ls_var_goitem-erfmg      = ls_var_values-fwert.
      WHEN k. ls_var_goitem-elikz      = ls_var_values-cwert.
      WHEN l. ls_var_goitem-lsmng      = ls_var_values-fwert.
      WHEN c. ls_var_goitem-charg      = ls_var_values-cwert.
      WHEN h. ls_var_goitem-licha      = ls_var_values-cwert.
      WHEN b. ls_var_goitem-migo_insmk = ls_var_values-cwert.
      WHEN o. ls_var_goitem-lgort      = ls_var_values-cwert.
      WHEN m. ls_var_goitem-bsmng      = ls_var_values-cwert.
*     when N. ls_var_goitem-ean11_kon = ls_VAR_VALUES-cwert.
    ENDCASE.
    IF l_old_matnr <> ls_var_values-matnr.
      IF ls_var_values-mode <> e.
        CLEAR: ls_var_goitem-erfmg, ls_var_goitem-maktx.
      ENDIF.
      ls_var_goitem-erfme = ls_goitem_top-erfme.
      ls_var_goitem-matnr = ls_var_values-matnr.
*     Organizational data
      ls_var_goitem-parent = ls_goitem_top-global_counter.
      ls_var_goitem-depth  = ls_goitem_top-depth + 1.
      ls_var_goitem-zeile  = ls_goitem_top-zeile.
      ls_var_goitem-update_mode = 'A'.
      ls_var_goitem-xgatype = 'C'.
      READ TABLE pt_goitem INTO ls_goitem_comp
         WITH KEY matnr   = ls_var_values-matnr
                  parent  = ls_goitem_top-global_counter
                  xgatype = c.
      IF sy-subrc = 0.
*       Variant of generic article is still in pt_goitem
        MOVE-CORRESPONDING ls_goitem_comp TO ls_var_goitem.
        CLEAR: ls_var_goitem-erfmg, ls_var_goitem-global_counter,
             ls_var_goitem-expand, ls_var_goitem-loglevel.
*     not ordered item
      ELSEIF NOT ls_goitem_top-xpoitem IS INITIAL.
        READ TABLE pt_goitem INTO ls_goitem_comp
           WITH KEY global_counter = ls_var_goitem-global_counter
                    matnr          = ls_var_values-matnr.
        IF sy-subrc <> 0.
          READ TABLE pt_goitem INTO ls_goitem_comp
            WITH KEY matnr          = ls_var_values-matnr
                     werks          = ls_goitem_top-werks
                     parent         = 0.
          IF sy-subrc <> 0.
            ls_var_goitem-update_mode = 'A'.
            CHECK ls_var_goitem-erfmg > 0.
*           Switch to NEW_POSITION
            ls_control = lcl_migo_globals=>kernel->mode_get( ).
            ls_control-new_line_mode = p.
            CALL METHOD lcl_migo_globals=>kernel->mode_set
              EXPORTING
                is_control = ls_control.
            ls_goitem_comp = default_line_get( ).
          ELSE.
            ls_var_goitem-update_mode = 'M'.
          ENDIF.
          ls_goitem_comp-matnr      = ls_var_goitem-matnr.
          ls_goitem_comp-werks      = ls_var_goitem-werks.
          ls_goitem_comp-erfmg      = ls_var_goitem-erfmg.
          ls_goitem_comp-erfme      = ls_goitem_top-erfme.
          ls_goitem_comp-elikz      = ls_var_goitem-elikz.
          ls_goitem_comp-lsmng      = ls_var_goitem-lsmng.
          ls_goitem_comp-charg      = ls_var_goitem-charg.
          ls_goitem_comp-licha      = ls_var_goitem-licha.
          ls_goitem_comp-migo_insmk = ls_var_goitem-migo_insmk.
          ls_goitem_comp-lgort      = ls_var_goitem-lgort.
          ls_goitem_comp-bsmng      = ls_var_goitem-bsmng.
          MOVE-CORRESPONDING ls_goitem_comp TO ls_var_goitem.
        ENDIF.
      ELSE.
        CLEAR: ls_var_goitem-global_counter, ls_var_goitem-expand,
               ls_var_goitem-loglevel.
      ENDIF.
      ls_var_goitem-umwrk = ls_goitem_top-umwrk.
      APPEND ls_var_goitem TO lt_var_goitem.
      DELETE lt_var_values WHERE matnr = ls_var_goitem-matnr.
      l_old_matnr = ls_var_values-matnr.
      l_current_tabix = l_current_tabix + 1.
    ENDIF.
  ENDLOOP.

* Append / delete / modify variants
  CLEAR ls_goitem_top-erfmg.
  DESCRIBE TABLE lt_var_goitem LINES l_lines.
  CHECK l_lines > 0.
  DESCRIBE TABLE pt_goitem LINES l_current_tabix.
  SORT lt_var_goitem BY update_mode.
  LOOP AT lt_var_goitem INTO ls_var_goitem.
    l_current_tabix = l_current_tabix + 1.
    MOVE-CORRESPONDING ls_var_goitem TO ls_goitem_comp.
    CASE ls_var_goitem-update_mode.
      WHEN a.
*     Append new variant
        IF ls_goitem_comp-erfmg > 0.
          CALL METHOD line_modify
            EXPORTING
              i_tabix          = l_current_tabix
              i_insert         = abap_true
              i_status_delayed = abap_true
            CHANGING
              cs_goitem        = ls_goitem_comp.
        ELSE.
          l_current_tabix = l_current_tabix - 1.
        ENDIF.
      WHEN m.
*     Modify existing variants
        IF ls_goitem_comp-erfmg = 0.
          CLEAR: ls_goitem_comp-take_it.
        ENDIF.
        READ TABLE pt_goitem
          WITH KEY global_counter = ls_goitem_comp-global_counter
          TRANSPORTING NO FIELDS.
        l_current_tabix = sy-tabix.
        CALL METHOD line_modify
          EXPORTING
            i_tabix          = l_current_tabix
            i_status_delayed = abap_true
          CHANGING
            cs_goitem        = ls_goitem_comp.
      ENDCASE.
  ENDLOOP.
  ls_control = lcl_migo_globals=>kernel->mode_get( ).
  CLEAR: ls_control-new_line_mode.
  CALL METHOD lcl_migo_globals=>kernel->mode_set
    EXPORTING
      is_control = ls_control.
  CALL METHOD status_derive.
  READ TABLE pt_goitem INTO goitem
    WITH KEY global_counter = l_global_counter.
  IF sy-subrc = 0.
    CALL METHOD screen_modify_line( goitem ).
    CALL METHOD screen_modify_transfer_fields( goitem ).
  ENDIF.
  SORT pt_goitem BY zeile global_counter.
ENDMETHOD.                                    "ga_variants_pai


METHOD ga_variants_create.
* Add new variants to an generic article on database
* Reactivated nodes and create new MATNR
  DATA: lt_new_var_values TYPE TABLE OF mtrx_werte,
        ls_new_var_values TYPE mtrx_werte,
        ls_var_msel       TYPE mtrx_msel,
        lt_var_vart       TYPE TABLE OF mtrx_vart,
        ls_var_vart       TYPE mtrx_vart,
        ls_var_values     TYPE mtrx_werte,
        ls_var_vali       TYPE mtrx_vali,
        ls_var_char       TYPE mtrx_char,
        lt_nvari          TYPE TABLE OF nvari,
        ls_nvari          TYPE nvari,
        lt_api_cv         TYPE TABLE OF api_cv,
        ls_api_cv         TYPE api_cv,
        lt_varart         TYPE TABLE OF mtrx_vart,
        ls_varart         TYPE mtrx_vart,
        lt_smatnr_hdr     TYPE TABLE OF smatnr_hdr,
        ls_smatnr_hdr     TYPE smatnr_hdr,
        ls_t001w          TYPE t001w,
        l_maxdat          TYPE dats,
        ls_errors         TYPE syst,
        l_msgno           TYPE emseg-msgno.
  CONSTANTS:
        c_xmigo           TYPE c VALUE 'X'.

* STATU = 'H': node was reactivated in matrix and ERFMG was applied
  LOOP AT ct_var_vart INTO ls_var_vart WHERE statu = 'H'.
    CLEAR ls_new_var_values.
    MOVE-CORRESPONDING ls_var_vart TO ls_new_var_values.
    READ TABLE ct_var_values INTO ls_var_values
      WITH KEY cuobj = ls_var_vart-cuobj.
    CHECK: sy-subrc = 0, ls_var_values-matnr IS INITIAL.
    MOVE-CORRESPONDING ls_var_vart TO ls_var_values.
    APPEND ls_new_var_values TO lt_new_var_values.
* Fill tables for report RMBVA002
    MOVE ls_var_vart-cuobj   TO ls_nvari-cuobj.
    MOVE is_goitem_top-matnr TO ls_nvari-matnr.
    MOVE ls_var_values-matnr TO ls_nvari-vatnr.
    MOVE is_goitem_top-werks TO ls_nvari-werks.
    APPEND ls_nvari TO lt_nvari.
    LOOP AT it_var_msel INTO ls_var_msel
      WHERE cuobj = ls_var_vart-cuobj.
      READ TABLE it_var_vali INTO ls_var_vali
        WITH KEY idxwt = ls_var_msel-idxwt.
      IF sy-subrc IS INITIAL.
        READ TABLE it_var_char INTO ls_var_char
          WITH KEY atinn = ls_var_vali-atinn.
      ENDIF.
      IF sy-subrc IS INITIAL.
        MOVE ls_var_values-cuobj TO ls_api_cv-cuobj.
        MOVE ls_var_char-atnam   TO ls_api_cv-atnam.
        MOVE ls_var_vali-atwrt   TO ls_api_cv-atwrt.
        MOVE ls_var_vali-atbez   TO ls_api_cv-atbez.
        MOVE ls_var_vali-atwtb   TO ls_api_cv-atwtb.
        APPEND ls_api_cv TO lt_api_cv.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

* Generate new material numbers (new variants)
  LOOP AT lt_nvari INTO ls_nvari.
     MOVE ls_nvari-cuobj TO ls_varart-cuobj.
    MOVE ls_nvari-vatnr TO ls_varart-matnr.
    APPEND ls_varart TO lt_varart.
  ENDLOOP.
  READ TABLE lt_nvari INTO ls_nvari INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'MATNR_VARIANTS_CREATE'
      EXPORTING
        i_matnr           = ls_nvari-matnr
      TABLES
        t_varart          = lt_varart
        t_api_cv          = lt_api_cv
      EXCEPTIONS
        no_matnr_given    = 1
        too_many_variants = 2
        no_free_number    = 3
        OTHERS            = 4.
    IF sy-subrc <> 0.
      CALL METHOD oref_log->message_add
        EXPORTING
          i_msgty = sy-msgty
          i_msgid = sy-msgid
          i_msgno = sy-msgno
          i_msgv1 = sy-msgv1
          i_msgv2 = sy-msgv2
          i_msgv3 = sy-msgv3
          i_msgv4 = sy-msgv4.
      EXIT.
    ENDIF.
    LOOP AT lt_varart INTO ls_varart.
      READ TABLE lt_nvari INTO ls_nvari
        WITH KEY cuobj = ls_varart-cuobj.
      MOVE ls_varart-matnr TO ls_nvari-vatnr.
      MODIFY lt_nvari FROM ls_nvari
        TRANSPORTING vatnr WHERE cuobj = ls_varart-cuobj.
    ENDLOOP.
  ENDIF.

  READ TABLE lt_nvari INTO ls_nvari INDEX 1.
  IF sy-subrc IS INITIAL.
* Read plant to derive if store or distribution center
    CALL FUNCTION 'LOCATION_SELECT_PLANT'
      EXPORTING
        i_werks                   = is_goitem_top-werks
      IMPORTING
        o_t001w                   = ls_t001w
      EXCEPTIONS
        no_valid_plant            = 1
        plant_not_found           = 2
        more_than_one_entry_found = 3
        OTHERS                    = 4.
    IF sy-subrc <> 0.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = sy-msgty
            i_msgid = sy-msgid
            i_msgno = sy-msgno
            i_msgv1 = sy-msgv1
            i_msgv2 = sy-msgv2
            i_msgv3 = sy-msgv3
            i_msgv4 = sy-msgv4.
      EXIT.
    ENDIF.

    CLEAR ls_smatnr_hdr.
*   Fill LS_MATNR_HDR (Header):
    MOVE-CORRESPONDING is_goitem_top TO ls_smatnr_hdr.
    MOVE 'X' TO ls_smatnr_hdr-grund.
    IF ls_t001w-vlfkz = 'A'.
      MOVE 'X' TO ls_smatnr_hdr-lofid.
    ELSEIF ls_t001w-vlfkz = 'B'.
      MOVE 'X' TO ls_smatnr_hdr-lovzd.
    ENDIF.
    MOVE 'X' TO ls_smatnr_hdr-grund.
    MOVE 'X' TO ls_smatnr_hdr-listd.
    MOVE '1' TO ls_smatnr_hdr-tranc.
    APPEND ls_smatnr_hdr TO lt_smatnr_hdr.
  ENDIF.

  READ TABLE lt_nvari INTO ls_nvari INDEX 1.
  CHECK sy-subrc IS INITIAL.
  CALL FUNCTION 'MARA_SINGLE_READ'
    EXPORTING
      matnr      = ls_nvari-matnr
      sperrmodus = 'E'
    EXCEPTIONS
      OTHERS     = 1.
    IF sy-subrc <> 0.
    CALL METHOD oref_log->message_add
         EXPORTING
            i_msgty = sy-msgty
            i_msgid = sy-msgid
            i_msgno = sy-msgno
            i_msgv1 = sy-msgv1
            i_msgv2 = sy-msgv2
            i_msgv3 = sy-msgv3
            i_msgv4 = sy-msgv4.
    EXIT.
  ENDIF.

* Report RMBVA002 creates the new variants in a new roll area.
* Parameters have to transfered via Export / Import parameters
  EXPORT nvari FROM lt_nvari           TO MEMORY ID 'NEUE_VARIANTE'.
  EXPORT api_cv FROM lt_api_cv         TO MEMORY ID 'MERKMALE_NEUE_VAR'.
  EXPORT smatnr_hdr FROM lt_smatnr_hdr TO MEMORY ID 'HDR_NEUE_VAR'.
  EXPORT xmigo FROM c_xmigo            TO MEMORY ID 'XMIGO'.
  SUBMIT  rmbva002 AND RETURN.
  IMPORT errors TO ls_errors FROM MEMORY ID 'ERRORS'.
  IMPORT nvari TO lt_nvari FROM MEMORY ID 'NEUE_VARIANTE'.
  FREE MEMORY ID 'ERRORS'.
  FREE MEMORY ID 'NEUE_VARIANTE'.

  IF sy-subrc IS INITIAL.
*   Take over the variants
    LOOP AT lt_nvari INTO ls_nvari.
      READ TABLE ct_var_values INTO ls_var_values
        WITH KEY cuobj = ls_nvari-cuobj.
      MOVE ls_nvari-vatnr TO ls_var_values-matnr.
      MODIFY ct_var_values FROM ls_var_values
        TRANSPORTING matnr WHERE cuobj = ls_nvari-cuobj.
      READ TABLE lt_new_var_values INTO ls_new_var_values
        WITH KEY cuobj = ls_nvari-cuobj.
      MOVE ls_nvari-vatnr TO ls_new_var_values-matnr.
      MODIFY lt_new_var_values FROM ls_new_var_values TRANSPORTING matnr
                         WHERE cuobj = ls_nvari-cuobj.
      READ TABLE ct_var_vart INTO ls_var_vart
        WITH KEY cuobj = ls_nvari-cuobj.
      MOVE ls_nvari-vatnr TO ls_var_vart-matnr.
      MODIFY ct_var_vart FROM ls_var_vart
        TRANSPORTING matnr WHERE cuobj = ls_nvari-cuobj.
*     Unlock the new variants
      CALL FUNCTION 'MARA_SINGLE_READ'
           EXPORTING
                kzrfb             = 'X'
                matnr             =  ls_nvari-vatnr
           EXCEPTIONS
                OTHERS            = 5.
      IF sy-subrc <> 0.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = sy-msgty
            i_msgid = sy-msgid
            i_msgno = sy-msgno
            i_msgv1 = sy-msgv1
            i_msgv2 = sy-msgv2
            i_msgv3 = sy-msgv3
            i_msgv4 = sy-msgv4.
        EXIT.
      ENDIF.
*     Listing of the variants
      CALL FUNCTION 'ASSORTMENT_AUTO_LOCAL'
        EXPORTING
          artnr              = ls_nvari-vatnr
          werk               = is_goitem_top-werks
          datbi              = l_maxdat
        EXCEPTIONS
          no_assort_material = 01
          twpa_not_found     = 02
          t001w_not_found    = 03
          wrf1_not_found     = 04
          assortment_error   = 05
          return_with_error  = 06
          no_user_exit       = 07.
      IF sy-subrc <> 0.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = sy-msgty
            i_msgid = sy-msgid
            i_msgno = sy-msgno
            i_msgv1 = sy-msgv1
            i_msgv2 = sy-msgv2
            i_msgv3 = sy-msgv3
            i_msgv4 = sy-msgv4.
      ENDIF.
    ENDLOOP.
  ELSE.
    CALL METHOD oref_log->message_add
      EXPORTING
        i_msgty = ls_errors-msgty
        i_msgid = ls_errors-msgid
        i_msgno = ls_errors-msgno
        i_msgv1 = ls_errors-msgv1
        i_msgv2 = ls_errors-msgv2
        i_msgv3 = ls_errors-msgv3
        i_msgv4 = ls_errors-msgv4.
    CALL METHOD oref_log->message_add
      EXPORTING
        i_msgty = e
        i_msgid = 'M7'
        i_msgno = '277'.
  ENDIF.
ENDMETHOD.                    "ga_create_variants


METHOD ga_buttons_fieldselection.
* Buttons to edit or add variants by matrix of variants (dynpro 0210)
*   xgatype = p (Generic article): buttons ready for input
*   xgatype = c (Variant): buttons ready for input
*   xgatype = SPACE (all other kind of materials): buttons are invisible
  DATA: ls_goitem        TYPE goitem,
        l_global_counter TYPE migo_global_counter,
        lt_fields        TYPE ty_t_fieldname,
        l_line           TYPE sytabix,
        l_name           TYPE lcl_migo_screenobject=>ty_name.

  IF NOT lcl_migo_cursor=>oref_screenobject IS INITIAL.
    CALL METHOD
      lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
        IMPORTING
          e_tabix = l_line
          e_name  = l_name.
  ENDIF.
  IF l_name <> 'TABLEVIEW' OR l_line = 0.
    l_line = i_line.
  ENDIF.
* Derive right item if line is expanded or not
  CALL METHOD lcl_migo_globals=>kernel->line_mapping
    EXPORTING
      i_line           = l_line
    IMPORTING
      e_global_counter = l_global_counter
    EXCEPTIONS
      OTHERS           = 1.
  CLEAR: lt_fields.
  APPEND 'OK_GA_CHANGE_VARIANT' TO lt_fields.
  APPEND 'OK_GA_ADD_VARIANT'    TO lt_fields.
  READ TABLE pt_goitem INTO ls_goitem
     WITH KEY global_counter = l_global_counter.
  IF sy-subrc = 0.
    CASE ls_goitem-xgatype.
      WHEN p OR c.
        CALL METHOD lcl_migo_screenmodification=>set
          EXPORTING
            it_fields = lt_fields
            i_status  = lcl_migo_screenmodification=>c_input.
      WHEN OTHERS.
        CALL METHOD lcl_migo_screenmodification=>set
          EXPORTING
            it_fields = lt_fields
            i_status  = lcl_migo_screenmodification=>c_invisible.
    ENDCASE.
  ELSE.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        it_fields = lt_fields
        i_status  = lcl_migo_screenmodification=>c_invisible.
  ENDIF.
ENDMETHOD.                                    "ga_buttons