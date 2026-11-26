*&---------------------------------------------------------------------*
*&  Include           /SPE/XHU_MV50AF04
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_items_delete
*&---------------------------------------------------------------------*
* Delete given items from HUs
*----------------------------------------------------------------------*
FORM spe_items_delete TABLES it_hu_items TYPE vsep_t_vepo
                             it_hu_heads TYPE hum_venum_t.  "n_1072781

  DATA: lt_xvekp TYPE vsep_t_vekp.                          "v_n_1072781

  FIELD-SYMBOLS: <fs_xvepo> TYPE vepovb,
                 <fs_xvekp> TYPE vekpvb.                    "^_n_1072781

* Return if no items have to be deleted                     "v_n_1100018
  IF it_hu_items[] IS INITIAL.
    RETURN.
  ENDIF.                                                    "^_n_1100018

  LOOP AT it_hu_items ASSIGNING <fs_xvepo>.
    CALL FUNCTION 'V51P_XVEPO_YVEPO_UPDATE'
      EXPORTING
        if_updkz = updkz_delete
        is_vepo  = <fs_xvepo>
      EXCEPTIONS
        OTHERS   = 0.
  ENDLOOP.

* Remove link from the header of the sub HU                 "v_n_1072781
* to the superior X-HU
  IF it_hu_heads[] IS NOT INITIAL.                          "n_1100018
    CALL FUNCTION 'V51P_GET_TABLES'
      EXPORTING
        it_venum = it_hu_heads[]
      IMPORTING
        et_xvekp = lt_xvekp
      EXCEPTIONS
        OTHERS   = 0.
  ENDIF.                                                    "n_1100018

  LOOP AT lt_xvekp ASSIGNING <fs_xvekp>.
    CLEAR <fs_xvekp>-uevel.
    CALL FUNCTION 'V51P_XVEKP_YVEKP_UPDATE'
      EXPORTING
        if_updkz = updkz_update
        is_vekp  = <fs_xvekp>
      EXCEPTIONS
        OTHERS   = 0.
  ENDLOOP.                                                  "^_n_1072781

ENDFORM.                    " spe_items_delete