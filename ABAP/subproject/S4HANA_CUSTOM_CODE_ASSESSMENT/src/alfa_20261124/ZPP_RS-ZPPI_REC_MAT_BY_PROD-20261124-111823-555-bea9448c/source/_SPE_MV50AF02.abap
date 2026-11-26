*&---------------------------------------------------------------------*
*&  Include           /SPE/MV50AF02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_delete_kit
*&---------------------------------------------------------------------*
FORM spe_delete_struc TABLES   it_items     TYPE vlkor_items
                      USING    if_vgbel     TYPE vgbel
                               if_spe_struc TYPE /spe/struc.

DATA:          lf_tabix   LIKE sy-tabix.
FIELD-SYMBOLS: <ls_xlips> TYPE lipsvb.

* creation of checked:   delete kit in newly created delivery
  IF NOT v50agl-ucdel_to_del_comb IS INITIAL.

    REFRESH ilips.
    likp = xlikp.

    LOOP AT xlips WHERE vbeln = likp-vbeln
                    AND vgbel EQ if_vgbel
                    AND      spe_struc EQ if_spe_struc
                    AND (    updkz     NE updkz_delete
                          OR updkz     NE updkz_mark_del ).

      lf_tabix = sy-tabix.
      PERFORM korr_check_chp_collect TABLES it_items
                                     USING  xlips.
      lips = xlips.
      PERFORM xlips_loeschen(sapfv50p) USING charx lf_tabix.

      MOVE-CORRESPONDING likp TO xlikp.
      IF v50agl-sammelgang = charx.
        MODIFY xlikp.
      ENDIF.
    ENDLOOP.

* creation of unchecked: delete unchecked deliver(ies)
  ELSEIF NOT v50agl-create_uclief IS INITIAL AND
         xlikp-spe_le_scenario EQ charc.

    REFRESH ilips.
    likp = xlikp.

*   delete all items related to this unchecked delivery
*   error is sent to CRM, customizing inconsistency
    LOOP AT xlips WHERE vbeln EQ likp-vbeln
                    AND vgbel EQ if_vgbel.

      lf_tabix = sy-tabix.
      PERFORM korr_check_chp_collect TABLES it_items
                                     USING  xlips.
      lips = xlips.

      PERFORM xlips_loeschen(sapfv50p) USING charx lf_tabix.


      MOVE-CORRESPONDING likp TO xlikp.
      IF v50agl-sammelgang = charx.
        MODIFY xlikp.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " spe_delete_kit