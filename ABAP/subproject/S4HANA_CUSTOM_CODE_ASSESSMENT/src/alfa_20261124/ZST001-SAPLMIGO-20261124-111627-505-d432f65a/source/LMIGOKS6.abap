*&---------------------------------------------------------------------*
*&  Include           LMIGOKS6                                         *
*&---------------------------------------------------------------------*
METHOD screen_modify_transfer_fields.

  DATA: lt_fields        TYPE ty_t_fieldname,
        lt_visible       TYPE ty_t_fieldname,
        lt_invisible     TYPE ty_t_fieldname,
        ls_fields        TYPE migo_fieldname,
        l_fieldname      TYPE migo_fieldname,
        l_status         TYPE migo_fs_status,
        l_status_umlgobe TYPE migo_fs_status,
        l_status_umcha   TYPE migo_fs_status,
        l_status_umbar   TYPE migo_fs_status,
        l_status_ummat   TYPE migo_fs_status.
* The following variable has no effect for the Core Code
* conditions, its value changes only in the switched code.
* This usage makes possible to avoid enh. sections.
  DATA: lv_adsub_umsok   VALUE space.   "EHP604 ADSUB GM080429

  FIELD-SYMBOLS: <f> TYPE ANY.
  IF is_goitem-xresitem = abap_true.
* res_umsok was determined using the original sobkz found in the
* reservation.
* If there is a umsok planned in the reservation, the special stock
* identifiers of the reservation are binding for the movement.
* This coding assumes that:
* - reservations always contain the necessary special stock identifiers
*   for their umsok
* - if a umsok (sobkz) is planned in a reservation it can not be changed
*   during the goods movement
    CASE is_goitem-res_umsok.
      WHEN 'E'.
        APPEND 'GOITEM-UMMAT_KDAUF' TO lt_visible.
        APPEND 'GOITEM-UMMAT_KDPOS' TO lt_visible.
      WHEN 'Q'.
        APPEND 'GOITEM-UMMAT_PSPNR' TO lt_visible.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
* UM-fields for 351
  IF is_goitem-xpoitem = abap_false
     AND NOT is_goitem-kzzug IS INITIAL
     AND s_action-create = abap_true.
*   Transfer fields only visible not input
    APPEND 'GOITEM-UMBAR'     TO lt_visible.
    APPEND 'GOITEM-UMCHA'     TO lt_visible.
ENHANCEMENT-POINT SCREEN_MODIFY_TRANSFER_FIEL_01 SPOTS ES_SAPLMIGO.
    APPEND 'GOITEM-UMHSDAT'   TO lt_visible.
    APPEND 'GOITEM-UMLGO'     TO lt_visible.
    APPEND 'GOITEM-UMLGOBE'   TO lt_visible.
    APPEND 'GOITEM-UMLGPBE'   TO lt_visible.
    APPEND 'GOITEM-UMMAKTX'   TO lt_visible.
    APPEND 'GOITEM-UMMAT'     TO lt_visible.
    APPEND 'GOITEM-UMMAT_CUSTNAME'   TO lt_visible.
    APPEND 'GOITEM-UMMAT_KDAUF'      TO lt_visible.
    APPEND 'GOITEM-UMMAT_KDPOS'      TO lt_visible.
    APPEND 'GOITEM-UMMAT_KUNNR'      TO lt_visible.
    APPEND 'GOITEM-UMMAT_LIFNR'      TO lt_visible.
    APPEND 'GOITEM-UMMAT_PSPNR'      TO lt_visible.
    APPEND 'GOITEM-UMMAT_VENDORNAME' TO lt_visible.
    APPEND 'GOITEM-UMNAME1'   TO lt_visible.
    APPEND 'GOITEM-UMSOK'     TO lt_visible.
    APPEND 'GOITEM-UMSOTXT'   TO lt_visible.
    APPEND 'GOITEM-UMVFDAT'   TO lt_visible.
    APPEND 'GOITEM-UMWRK'     TO lt_visible.
    APPEND 'GOITEM-UMZST'     TO lt_visible.
  ENDIF.
*______________________________________________________________________
  APPEND 'GOITEM-UMMAKTX' TO lt_fields.
  APPEND 'GOITEM-UMNAME1' TO lt_fields.
  APPEND 'GOITEM-UMLGOBE' TO lt_fields.
  APPEND 'GOITEM-UMCHA'   TO lt_fields.
  APPEND 'GOITEM-UMBAR'   TO lt_fields.
* General Check
  LOOP AT lt_fields INTO ls_fields.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = ls_fields
        i_global_counter = is_goitem-global_counter
      RECEIVING
        r_status         = l_status.
    CONCATENATE 'IS_' ls_fields INTO l_fieldname.
    ASSIGN (l_fieldname) TO <f>.
    IF l_status <> lcl_migo_screenmodification=>c_input AND
       NOT <f> IS INITIAL.
      APPEND ls_fields TO lt_visible.
      l_status = lcl_migo_screenmodification=>c_visible.
    ENDIF.
    IF l_status <> lcl_migo_screenmodification=>c_invisible.
      IF ls_fields = 'GOITEM-UMMAKTX'.
        APPEND 'GOITEM-UMMAT' TO lt_visible.
      ELSEIF ls_fields = 'GOITEM-UMNAME1'.
        APPEND 'GOITEM-UMWRK' TO lt_visible.
      ELSEIF ls_fields = 'GOITEM-UMLGOBE'.
        APPEND 'GOITEM-UMLGO' TO lt_visible.
      ENDIF.
    ENDIF.
  ENDLOOP.
*_______________________________________________________________________
* Special checks
  IF is_goitem-umbwtty IS INITIAL.
    APPEND 'GOITEM-UMBAR' TO lt_invisible.
  ENDIF.
* Storage location without relevance for special stock 'OPTVW'
* (-> no storage location useful).
ENHANCEMENT-SECTION EHP604_SCREEN_MODIFY_TRFLD_01 SPOTS ES_SAPLMIGO .
  IF is_goitem-umsok CA 'OPTVW'
    OR ( is_goitem-bustr = '303' AND                             "581603
    lcl_migo_screenmodification=>get_required( i_global_counter
    = is_goitem-global_counter i_field = 'GOITEM-UMLGOBE' ) = SPACE ).
    IF s_action-display IS INITIAL.                             "1037089
      APPEND 'GOITEM-UMLGOBE' TO lt_invisible.
      APPEND 'GOITEM-UMLGO'   TO lt_invisible.
    ENDIF.                                                      "1037089
  ENDIF.
END-ENHANCEMENT-SECTION.

* Not batch mananged or movement type 303
  IF is_goitem-bustr = '303' OR is_goitem-umxchpf IS INITIAL.
    APPEND 'GOITEM-UMCHA' TO lt_invisible.
ENHANCEMENT-POINT SCREEN_MODIFY_TRANSFER_FIEL_02 SPOTS ES_SAPLMIGO.
  ENDIF.
* begin of Outsourced Manufacturing EhP 4
  IF ( is_goitem-umsok = 'O'
     AND is_goitem-kzbwa = '02'
     AND s_action-display = abap_false )
     OR lv_adsub_umsok IS NOT INITIAL.                         "GM080429
    IF s_control-refdoc = 'R01'.
      IF is_goitem-bwtar IS NOT INITIAL OR is_goitem-charg IS NOT INITIAL.
        IF is_goitem-bwtar IS NOT INITIAL.
          APPEND 'GOITEM-UMBAR' TO lt_visible.
        ENDIF.
        IF is_goitem-charg IS NOT INITIAL.
          APPEND 'GOITEM-UMCHA' TO lt_visible.
        ENDIF.
      ELSE.
        APPEND 'GOITEM-UMBAR' TO lt_invisible.
        APPEND 'GOITEM-UMCHA' TO lt_invisible.
      ENDIF.
    ENDIF.
  ENDIF.
* end of Outsourced Manufacturing EhP 4

* UMVFDAT/UMHSDAT: _____________________________________________________
* The content of UMXWMHD depends on T159L (key field: plant). UMWRK was
* filled in method UM_FIELDS_FILL. Therefore the fieldselection for
* UMVFDAT/UMHSDAT has to be done in this method and not in LMIGOKS4
* (in method SCREEN_MODIFY_LINE).
* Must be the same logic as in field selection LMIGOKS4 and LMIGOKL4.
  IF is_goitem-umxwmhd IS INITIAL OR is_goitem-kzmhd IS INITIAL.
    APPEND 'GOITEM-UMHSDAT' TO lt_invisible.
    APPEND 'GOITEM-UMVFDAT' TO lt_invisible.
  ELSE.
    IF is_goitem-umxchpf = abap_false AND is_goitem-ummhdrz IS INITIAL.
      APPEND 'GOITEM-UMHSDAT' TO lt_invisible.
      APPEND 'GOITEM-UMVFDAT' TO lt_invisible.
    ENDIF.
  ENDIF.
  IF is_goitem-shkzg = 'S' AND s_action-migo_mode = 'GT'.
    APPEND 'GOITEM-UMHSDAT' TO lt_invisible.
    APPEND 'GOITEM-UMVFDAT' TO lt_invisible.
  ENDIF.

* Product quantity unit: _______________________________________________
  IF ( is_goitem-shkzg = s AND is_goitem-umxparallel = abap_false AND
                               is_goitem-xparallel   = abap_true
     ) OR
     ( is_goitem-shkzg = h AND is_goitem-umxparallel = abap_true AND
                               is_goitem-xparallel   = abap_false
     ).
*   Status for field MENGE can remain on 'INPUT'
  ELSE.
    IF NOT is_goitem-meins IS INITIAL.                "682391
      APPEND  'GOITEM-MENGE' TO lt_visible.
    ENDIF.                                            "682391
  ENDIF.
ENHANCEMENT-POINT SCREEN_MODIFY_TRANSFER_FIEL_03 SPOTS ES_SAPLMIGO STATIC.

ENHANCEMENT-POINT SCREEN_MODIFY_TRANSFER_FIEL_04 SPOTS ES_SAPLMIGO.

* Change t_fieldselection ---------------------------------------------*
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_global_counter = is_goitem-global_counter
      it_fields        = lt_visible
      i_status         = lcl_migo_screenmodification=>c_visible.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_global_counter = is_goitem-global_counter
      it_fields        = lt_invisible
      i_status         = lcl_migo_screenmodification=>c_invisible.

*_______________________________________________________________________
* GODYNPRO-UMFIELDS must have the same fieldselection as GOITEM-UMFIELDS
* GODYNPRO-UMCHA
  CALL METHOD lcl_migo_screenmodification=>get
    EXPORTING
      i_field          = 'GOITEM-UMCHA'
      i_global_counter = is_goitem-global_counter
    RECEIVING
      r_status         = l_status.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_fields         = 'GODYNPRO-UMCHA'
      i_global_counter = is_goitem-global_counter
      i_status         = l_status.
* GODYNPRO-UMCHA
  CALL METHOD lcl_migo_screenmodification=>get
    EXPORTING
      i_field          = 'GOITEM-UMBAR'
      i_global_counter = is_goitem-global_counter
    RECEIVING
      r_status         = l_status.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_fields         = 'GODYNPRO-UMBAR'
      i_global_counter = is_goitem-global_counter
      i_status         = l_status.
*_______________________________________________________________________
* BUTTONS:
* OK_DETERMINE_RIGHT:
* Now we know if UMLGOBE/UMCHA/UMBAR can be entered, so set stock
* determination field accordingly
  CALL METHOD lcl_migo_screenmodification=>get
    EXPORTING
      i_field          = 'GOITEM-UMLGOBE'
      i_global_counter = is_goitem-global_counter
    RECEIVING
      r_status         = l_status_umlgobe.
  CALL METHOD lcl_migo_screenmodification=>get
    EXPORTING
      i_field          = 'GOITEM-UMCHA'
      i_global_counter = is_goitem-global_counter
    RECEIVING
      r_status         = l_status_umcha.
  CALL METHOD lcl_migo_screenmodification=>get
    EXPORTING
      i_field          = 'GOITEM-UMBAR'
      i_global_counter = is_goitem-global_counter
    RECEIVING
      r_status         = l_status_umbar.
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_fields         = 'OK_DETERMINE_RIGHT'
      i_global_counter = is_goitem-global_counter
      i_status         = lcl_migo_screenmodification=>c_invisible.
* Set Button OK_DETERMINE on input depending on screenmodification
* and field XUMDETERMINATION.
  IF ( ( l_status_umlgobe = lcl_migo_screenmodification=>c_input AND
         is_goitem-umlgobe IS INITIAL ) OR
       ( l_status_umcha   = lcl_migo_screenmodification=>c_input AND
         is_goitem-umcha IS INITIAL ) OR
       ( l_status_umbar   = lcl_migo_screenmodification=>c_input AND
         is_goitem-umbar IS INITIAL ) ) AND
     is_goitem-xumdetermination = abap_true.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_fields         = 'OK_DETERMINE_RIGHT'
        i_global_counter = is_goitem-global_counter
        i_status         = lcl_migo_screenmodification=>c_input.
  ENDIF.
* OK_STOCK_OVER_RIGHT: _________________________________________________
  CALL METHOD lcl_migo_screenmodification=>get
    EXPORTING
      i_field          = 'GOITEM-UMMAT'
      i_global_counter = is_goitem-global_counter
    RECEIVING
      r_status         = l_status_ummat.
  IF l_status_ummat = lcl_migo_screenmodification=>c_invisible.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_fields         = 'OK_STOCK_OVER_RIGHT'
        i_global_counter = is_goitem-global_counter
        i_status         = lcl_migo_screenmodification=>c_invisible.
  ENDIF.

* Process general rules for transfer fields
  CALL METHOD screen_modify_general_rules
    EXPORTING is_goitem = is_goitem.

ENDMETHOD.                    "screen_modify_transfer_fields