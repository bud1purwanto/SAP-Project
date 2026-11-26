*----------------------------------------------------------------------*
*   INCLUDE MV50AF0U                                                   *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM UPDATE_INIT_V50L                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM update_init_v50l.

  v50agl-no_commit = charx.
  PERFORM no_dequeue.

ENDFORM.
*eject
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_UNIVERSAL_ENTRY
*&---------------------------------------------------------------------*
*       This form routine provides the possibility to process a delivery
*       without knowing the delivery type
*----------------------------------------------------------------------*
FORM user_command_universal_entry USING if_fcode TYPE fcode.

  DATA: lt_bdcdata LIKE bdcdata OCCURS 0 WITH HEADER LINE,
        lt_messtab TYPE TABLE OF bdcmsgcoll.

* Macro definition for batch-input processing
  DEFINE set_var_batchinput.
    clear lt_bdcdata.
    lt_bdcdata-fnam = &1.
    lt_bdcdata-fval = &2.
    append lt_bdcdata.
  END-OF-DEFINITION.

  DEFINE set_dynp_batchinput.
    clear lt_bdcdata.
    lt_bdcdata-program = &1.
    lt_bdcdata-dynpro  = &2.
    lt_bdcdata-dynbegin = 'X'.
    append lt_bdcdata.
  END-OF-DEFINITION.

  CASE if_fcode.
    WHEN 'ABBR_T' OR 'BABA_T' OR 'BACK_T'.
      LEAVE TO SCREEN 0.
    WHEN 'DLUN_T'.
      SELECT SINGLE * FROM likp
                      WHERE vbeln = likp-vbeln.
      IF sy-subrc NE 0.
        MESSAGE s302 WITH likp-vbeln.
      ELSE.
        CASE likp-vbtyp.
          WHEN vbtyp_lino.
            SET PARAMETER ID 'VL' FIELD likp-vbeln.
            CALL TRANSACTION 'VL02N' AND SKIP FIRST SCREEN.
          WHEN vbtyp_liav.
            SET PARAMETER ID 'VLM' FIELD likp-vbeln.
            CALL TRANSACTION 'VL32N' AND SKIP FIRST SCREEN.
        ENDCASE.
      ENDIF.
    WHEN 'DLOB_T'.
      SET PARAMETER ID 'VL' FIELD gf_vbeln_outb.
      CALL TRANSACTION 'VL02N' AND SKIP FIRST SCREEN.
    WHEN 'DLIB_T'.
      SET PARAMETER ID 'VLM' FIELD gf_vbeln_inb.
      CALL TRANSACTION 'VL32N' AND SKIP FIRST SCREEN.
    WHEN 'DLWB_T'.
      SELECT SINGLE * FROM likp
                      WHERE vbeln = likp-vbeln.
      IF sy-subrc NE 0.
        MESSAGE s302 WITH likp-vbeln.
      ELSE.
        CASE likp-vbtyp.
          WHEN vbtyp_lino.
            set_dynp_batchinput 'SAPMV50A' '4004'.
            set_var_batchinput 'LIKP-VBELN' likp-vbeln.
            set_var_batchinput 'BDC_OKCODE' 'WABU_T'.
            CALL TRANSACTION 'VL02N' USING lt_bdcdata
                                    MODE 'E'
                                    UPDATE 'A'
                                    MESSAGES INTO lt_messtab.
          WHEN vbtyp_liav.
            set_dynp_batchinput 'SAPMV50A' '4104'.
            set_var_batchinput 'LIKP-VBELN' likp-vbeln.
            set_var_batchinput 'BDC_OKCODE' 'WABU_T'.
            CALL TRANSACTION 'VL32N' USING lt_bdcdata
                                    MODE 'E'
                                    UPDATE 'A'
                                    MESSAGES INTO lt_messtab.
        ENDCASE.
      ENDIF.
    WHEN 'DLWE_T'.
      set_dynp_batchinput 'SAPMV50A' '4104'.
      set_var_batchinput 'LIKP-VBELN' gf_vbeln_inb.
      set_var_batchinput 'BDC_OKCODE' 'WABU_T'.
      CALL TRANSACTION 'VL32N' USING lt_bdcdata
                              MODE 'E'
                              UPDATE 'A'
                              MESSAGES INTO lt_messtab.
    WHEN 'DLWA_T'.
      set_dynp_batchinput 'SAPMV50A' '4004'.
      set_var_batchinput 'LIKP-VBELN' gf_vbeln_outb.
      set_var_batchinput 'BDC_OKCODE' 'WABU_T'.
      CALL TRANSACTION 'VL02N' USING lt_bdcdata
                              MODE 'E'
                              UPDATE 'A'
                              MESSAGES INTO lt_messtab.

  ENDCASE.

ENDFORM.                               " USER_COMMAND_UNIVERSAL_ENTRY