*&---------------------------------------------------------------------*
*&  Include           /SPE/FV50WF05
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM /spe/update_gen_hu_items                                 *
*---------------------------------------------------------------------*
*       Delete generated items with quanitiy 0 (as previously done in *
*       V51P_GENERATE_OBJECT_ITEMS
*       Furthermore set the closing indicator - if all other items
*       have it set
*---------------------------------------------------------------------*
FORM /spe/update_gen_hu_items CHANGING cf_subrc TYPE sysubrc.

* Local Constants --------------------------------------------------
  CONSTANTS: lc_x              TYPE c             VALUE 'X'
            ,lc_packpos_dele_  TYPE tvshp-spe_packpos_del
                                                  VALUE ' '
            ,lc_packpos_dele_c TYPE tvshp-spe_packpos_del
                                                  VALUE 'C'
            .
* Local data declarations ------------------------------------------
  DATA: ls_tvshp             TYPE tvshp
       ,lf_do_no_set_elikz   TYPE c
       ,lf_accumulated_lfimg TYPE lips-lfimg
       ,lf_exception_det     TYPE REF TO /SPE/DISCREPANCY_EXCPTN_PACK.
       .

* Determine shipping parameters on client level (100% buffered)
  CALL FUNCTION 'SHP_TVSHP_SELECT_01'
    CHANGING
      cs_tvshp       = ls_tvshp.

  LOOP AT xlips WHERE updkz NE updkz_delete.

* 1. Deletion of generated items with quanitity 0
*    This logic is shifted from V51P_GENERATE_OBJECT_ITEMS
    IF     xlips-posar              EQ gc_posar-packing AND
           xlips-lfimg              EQ 0                AND
           ls_tvshp-spe_packpos_del EQ lc_packpos_dele_.
      slips-tabix = sy-tabix.
      ilips-tabix = sy-tabix.
      PERFORM lips_bearbeiten_vorbereiten(sapfv50p).
      PERFORM xlips_loeschen(sapfv50p) USING space 0.

* 2. Item without Closing Indicator
*    -> Second run for setting this indicator can be skipped
    ELSEIF xlips-posar              NE gc_posar-packing AND
           xlips-spe_gen_elikz      IS INITIAL.
      lf_do_no_set_elikz = lc_x.
    ENDIF.

  ENDLOOP.

  IF lf_do_no_set_elikz NE lc_x.

* Pre-Step for determination of POD-relevant data of packing items
    CALL FUNCTION '/SPE/POD_ACCUMULATE_PACK_PRE'
      EXPORTING
        it_xlips       = xlips[].

    LOOP AT xlips WHERE posar EQ gc_posar-packing AND
                        updkz NE updkz_delete.

* 3. Set closing indicator and a default exception code automatically
*    This is to be done for items which would be deleted in step 4. as
*    well ! Otherwise the discrepancy logic in WARENAUSGANG_BUCHEN
*    would not work for a complete loss of packing material.
      slips-tabix = sy-tabix.
      ilips-tabix = sy-tabix.
      PERFORM lips_bearbeiten_vorbereiten(sapfv50p).
* Set closing indicator ...
      lips-spe_gen_elikz   = lc_x.
* and - if appropriate - the correct default exception code for the
* item containing the original delivery quantity
      CALL FUNCTION '/SPE/POD_ACCUMULATE_PACK_QTY'
        EXPORTING
          is_lips                    = xlips
        IMPORTING
          ef_accumulated_lfimg       = lf_accumulated_lfimg
        exceptions
          not_main_item              = 1.

      IF sy-subrc EQ 0.

        TRY.
          GET BADI lf_exception_det.

          CALL BADI lf_exception_det->DETERMINE_FOR_PACKING_ITEM
            EXPORTING
              IS_DELIVERY_HEADER       = xlikp
              IS_DELIVERY_ITEM         = xlips
              IF_ORIGINAL_QTY_BASE_UOM = xlips-ormng
              IF_ACTUAL_QTY_BASE_UOM   = lf_accumulated_lfimg
            IMPORTING
              EF_EXCEPTION_CODE        = lips-spe_except_code
            EXCEPTIONS
              EXCEPTION                = 1.

          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            cf_subrc = sy-subrc.
*            PERFORM protokoll_add_item_default TABLES xprot.
            RETURN.
          ENDIF.

          CATCH CX_BADI_NOT_IMPLEMENTED.
        ENDTRY.

      ENDIF.
      PERFORM lips_bearbeiten(sapfv50p).
* 4. Final Deletion of generated packing items with final Closing
*    indicator (Alternative to Step 1)
      IF xlips-lfimg              EQ 0    AND
         ls_tvshp-spe_packpos_del EQ lc_packpos_dele_c.
        PERFORM xlips_loeschen(sapfv50p) USING space 0.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.