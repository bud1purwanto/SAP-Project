***INCLUDE FV50XF0B_NUMMERNVERGABE_LIEFER .
*---------------------------------------------------------------------*
*       FORM NUMMERNVERGABE_LIEFERUNG                                 *
*---------------------------------------------------------------------*
*  -->  IF_KOPF_TABIX                                                 *
*---------------------------------------------------------------------*
FORM nummernvergabe_lieferung USING if_kopf_tabix      LIKE sy-tabix
                                    if_flag_docnum_new TYPE c.

  DATA: tmp_numki         TYPE tvlk-numki,
        retc              TYPE inri-returncode,
        ls_tvlkn          TYPE tvlkn,
        lv_vbeln          TYPE likp-vbeln,
        lv_tmp_numki_save TYPE tvlk-numki.

* Nummernvergabe für Lieferung
  IF xlikp-vbeln = space   OR
     xlikp-vbeln(1) = '$' OR
     ( v50agl-create_decentral NE space AND                 "40C WMS
       if_flag_docnum_new NE space ).

    DATA: modified LIKE leshpmd-splidl.
    PERFORM tvlk_select(sapmv50a) USING xlikp-lfart
                              space
                              sy-subrc.
    tmp_numki = tvlk-numki.
*   Check number interval finding rule for split in decentral system
*   (ULa, 4.6c)
    IF    NOT v50agl-split   IS INITIAL
      AND NOT xlikp-verursys IS INITIAL.
      IF tvlk-numkirule = gc_tvlk_numkirule-tvlkn.
        CALL FUNCTION 'SHP_TVLKN_SELECT_01'
          EXPORTING
            if_lgnum          = xlikp-lgnum
            if_lfart          = xlikp-lfart
          CHANGING
            cs_tvlkn          = ls_tvlkn
          EXCEPTIONS
            no_key_specified  = 01
            no_value_selected = 02
            OTHERS            = 99.
        IF sy-subrc IS INITIAL.
          IF NOT ls_tvlkn IS INITIAL.
            tmp_numki = ls_tvlkn-numki.
          ENDIF.
        ELSE.
          MESSAGE a809(vl). " WITH xlikp-lgnum xlikp-lfart.
        ENDIF.
      ENDIF.
    ELSEIF v50agl-create_uclief <> space AND
           tvlk-spe_numkt       <> space.

      tmp_numki         = tvlk-spe_numkt.
      lv_tmp_numki_save = tmp_numki.

      IF tvlk-spe_nr_recycling <> space.
        CALL FUNCTION '/SPE/GET_VBELN_FROM_RECYCLE'
          EXPORTING
            iv_numki    = tmp_numki
            iv_synchron = v50agl-synchron
          IMPORTING
            ev_vbeln    = lv_vbeln
          EXCEPTIONS
            no_number   = 0
            OTHERS      = 0.
      ENDIF.
    ENDIF.
*   Userexit für Nummernkreisfindung
    PERFORM userexit_number_range(sapmv50a) USING tmp_numki.

    IF lv_tmp_numki_save = tmp_numki AND
       lv_vbeln IS NOT INITIAL.
      xlikp-vbeln = lv_vbeln.
    ELSE.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = tmp_numki
          object                  = 'RV_BELEG'
          ignore_buffer           = tvshp-ignbf         "40C
        IMPORTING
          number                  = xlikp-vbeln
          returncode              = retc
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          OTHERS                  = 99.
      IF sy-subrc NE 0.
        MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.                                                 "v_n_647514
        CASE retc.
*       critical sector of the number range reached
*       message I532(V1).
          WHEN '1'.
            PERFORM message_handling
                        USING posnr_low '532' 'I' 'V1' 'RV_BELEG'
                              tmp_numki space space.
*       the last number of the number range was given
*       message I533(V1).
          WHEN '2'.
            PERFORM message_handling
                        USING posnr_low '533' 'I' 'V1' 'RV_BELEG'
                              tmp_numki space space.
        ENDCASE.                                            "^_n_647514
      ENDIF.
    ENDIF.
    CLEAR lips.

*   In case of delivery split in decentral/LE system the verur delivery
*   number has to be the same as the key because this is the delivery
*   number in the ERP system.    (ULa, 4.6c)
    IF    NOT v50agl-split   IS INITIAL
      AND NOT xlikp-verursys IS INITIAL
      AND     xlikp-verur(1) = '$'.
      xlikp-verur = xlikp-vbeln.
    ENDIF.
    MODIFY xlikp INDEX if_kopf_tabix.
  ENDIF.

ENDFORM.                    "nummernvergabe_lieferung