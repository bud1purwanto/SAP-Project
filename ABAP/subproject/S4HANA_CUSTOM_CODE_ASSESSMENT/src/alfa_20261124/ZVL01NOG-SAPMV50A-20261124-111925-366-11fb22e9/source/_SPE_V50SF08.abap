*----------------------------------------------------------------------*
***INCLUDE /SPE/V50SF08 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  /spe/add_field_for_requirement
*&---------------------------------------------------------------------*
FORM spe_add_field_for_requirement
                               TABLES ct_sdfields STRUCTURE atpfield
                                      ylikp       STRUCTURE likp
                                      ylips       STRUCTURE lipsvb
                               USING  is_likp     TYPE likp
                                      is_lips     TYPE lipsvb
                                      v50agl      TYPE v50agl.

 FIELD-SYMBOLS: <ls_ylips> TYPE lipsvb
              , <ls_ylikp> TYPE likp
              , <ls_xlips> TYPE lipsvb
              , <ls_xlikp> TYPE likpvb.


* only outbound deliveries
  CHECK is_likp-vbtyp CA vbtyp_lief.

* only for created or changed documents a differenz in date an
* time exists, APO can detect deleted items in a different way
  CHECK xlips-updkz EQ updkz_new OR xlips-updkz EQ updkz_update.

  CLEAR ct_sdfields.

  ct_sdfields-delnr = is_lips-vbeln.
  ct_sdfields-delps = is_lips-posnr.

  ct_sdfields-kfdna = 'LFDAT_NEW'.
  ct_sdfields-value = is_likp-lfdat.
  APPEND ct_sdfields.

  ct_sdfields-kfdna = 'SCENARIO'.
  ct_sdfields-value = is_likp-spe_le_scenario.
  APPEND ct_sdfields.

  ct_sdfields-kfdna = 'LFIMG_NEW'.
  ct_sdfields-value = is_lips-lfimg.
  APPEND ct_sdfields.

  ct_sdfields-kfdna = 'DEL_PROCESS_DATE'.
  ct_sdfields-value = is_lips-spe_process_date.
  APPEND ct_sdfields.

  IF NOT v50agl-ucdel_to_del IS INITIAL.
*  'Check unchecked' keeps the delivery number, therefore UPDKZ = U
*   and ylips are filled
    READ TABLE ylips TRANSPORTING NO FIELDS
                     WITH KEY vgbel = is_lips-vgbel
                              vgpos = is_lips-vgpos.
    CHECK sy-subrc = 0.

    LOOP AT ylips ASSIGNING <ls_ylips> FROM sy-tabix.

*      IF v50agl-ucdel_to_del IS INITIAL.
*        CHECK <ls_ylips>-vbeln <> is_lips-vbeln.
*      ENDIF.
      ct_sdfields-kfdna = 'LFIMG_OLD'.
      ct_sdfields-value = <ls_ylips>-lfimg.
      APPEND ct_sdfields.

      READ TABLE ylikp ASSIGNING <ls_ylikp>
                       WITH KEY vbeln = <ls_ylips>-vbeln.
      IF sy-subrc = 0.
        ct_sdfields-kfdna = 'LFDAT_OLD'.
        ct_sdfields-value = <ls_ylikp>-lfdat.
        APPEND ct_sdfields.
      ENDIF.
      EXIT.
    endloop.
  ELSEIF NOT v50agl-ucdel_to_del_comb IS INITIAL.
*   'Check and combine' creates new deliveries and deletes old ones
*   no ylips, UPDKZ = I
    READ TABLE xlips ASSIGNING <ls_xlips>
                     WITH KEY vgbel = is_lips-vgbel
                              vgpos = is_lips-vgpos
                              updkz = updkz_delete.
    IF sy-subrc = 0.
      ct_sdfields-kfdna = 'LFIMG_OLD'.
      ct_sdfields-value = <ls_xlips>-lfimg.
      APPEND ct_sdfields.

      READ TABLE xlikp ASSIGNING <ls_xlikp>
                       WITH KEY vbeln = <ls_xlips>-vbeln
                                updkz = updkz_delete
                       BINARY SEARCH.
      IF sy-subrc = 0.
        ct_sdfields-kfdna = 'LFDAT_OLD'.
        ct_sdfields-value = <ls_xlikp>-lfdat.
        APPEND ct_sdfields.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " spe_add_field_for_requirement