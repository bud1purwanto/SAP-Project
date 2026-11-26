*&---------------------------------------------------------------------*
*&  Include           /SPE/XHU_MV50AF05
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_xhu_items_determine
*&---------------------------------------------------------------------*
*  Determine itmes in X-HUs refering to the HUs given in table it_hus
*----------------------------------------------------------------------*
FORM spe_xhu_items_determine TABLES it_hus       TYPE hum_rehang_hu_t
                                    ct_xhu_items TYPE vsep_t_vepo
                                    ct_hu_heads  TYPE hum_venum_t."n_1072781

  DATA: lt_venum     TYPE hum_venum_t,
        lt_xvekp     TYPE vsep_t_vekp,
        lt_xvekp_sub TYPE vsep_t_vekp,
        lt_xvepo     TYPE vsep_t_vepo,
        ls_venum     TYPE hum_venum,
        ls_flags     TYPE v51p_select_flags,
        ls_hu        TYPE hum_rehang_hu,
        ls_vekp      TYPE vekpvb,
        ls_vepo      TYPE vepovb,
        ls_vekp_sub  TYPE vekpvb,
        ls_xhu_item  TYPE huitem_key.

  CHECK it_hus[] IS NOT INITIAL.

* Filter out HUs which are packed into another HU

* Collect top delivery specific HUs
  LOOP AT it_hus INTO ls_hu.
    ls_venum-venum = ls_hu-top_hu_internal.
    COLLECT ls_venum INTO lt_venum.
  ENDLOOP.

* Set flags for reading HUs
  ls_flags-lock_hu     = gc_x.
  ls_flags-add_and_exp = gc_x.
  ls_flags-more_hus    = gc_x.
  ls_flags-mara_packmittel  = gc_x.                                  "n_1528859

  CALL FUNCTION 'V51P_GET_TABLES'
    EXPORTING
      is_flags    = ls_flags
      it_venum    = lt_venum
    IMPORTING
      et_xvekp    = lt_xvekp
      et_xvepo    = lt_xvepo
    EXCEPTIONS
      hus_locked  = 1
      no_hu_found = 2
      fatal_error = 3
      OTHERS      = 4.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  SORT lt_xvekp BY venum.
  SORT lt_xvepo BY venum unvel.

* LT_XVEKP contains the complete HU hierarchy
  LOOP AT lt_venum INTO ls_venum.

    READ TABLE lt_xvekp INTO ls_vekp_sub
                        WITH KEY venum = ls_venum-venum
                        BINARY SEARCH.
* line deleted with note 1072781
    CHECK sy-subrc = 0 AND
          ls_vekp_sub-uevel <> space.

* First check if superior HU is a X-HU
    READ TABLE lt_xvekp INTO ls_vekp
                        WITH KEY venum = ls_vekp_sub-uevel
                        BINARY SEARCH
                        TRANSPORTING vpobj.
    CHECK sy-subrc = 0 AND
          ( ls_vekp-vpobj = gc_pacobj-x_obdlvry OR
            ls_vekp-vpobj = gc_pacobj-x_ibdlvry   ).

* Now read item of packed HU
    READ TABLE lt_xvepo INTO ls_vepo
                        WITH KEY venum = ls_vekp_sub-uevel
                                 unvel = ls_vekp_sub-venum
                        BINARY SEARCH.
    CHECK sy-subrc = 0.

    APPEND ls_vepo TO ct_xhu_items.
    APPEND ls_vekp_sub-venum TO ct_hu_heads.                  "n_1072781

  ENDLOOP.

ENDFORM.                    " spe_xhu_items_determine