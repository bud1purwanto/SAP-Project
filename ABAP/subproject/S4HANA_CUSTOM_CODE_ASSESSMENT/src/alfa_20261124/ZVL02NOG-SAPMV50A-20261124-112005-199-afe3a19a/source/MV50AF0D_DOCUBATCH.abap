*&---------------------------------------------------------------------*
*&  Include           MV50AF0D_DOCUBATCH
*&---------------------------------------------------------------------*

*&--------------------------------------------------------------------*
*&      Form  docubatch_detail_open
*&--------------------------------------------------------------------*
FORM docubatch_detail_open.

  DATA:
    lv_process_id       TYPE docubatch_process_id,
    lv_ebeln            TYPE ebeln,
    lv_ebelp            TYPE ebelp,
    lv_pikmg            LIKE xlips-pikmg,
    lv_vrkmp            LIKE xlips-vrkmp,
    lv_display_only     TYPE xfeld,
    ls_docubatch_com    TYPE docubatch_com,
    ls_vbup             TYPE vbup,
    ls_t340d            type t340d.

  CHECK likp-vbtyp EQ vbtyp_lino
     OR likp-vbtyp EQ vbtyp_liav.

  IF lips-matnr IS INITIAL OR
     lips-werks IS INITIAL OR
     lips-posnr IS INITIAL.
    CLEAR:
*      lipsd-docubatch_charg, " do not clear -> field transport
      lipsd-docubatch_control,
      lipsd-docubatch_mult_entries.
    EXIT.
  ENDIF.

  MOVE-CORRESPONDING likp
    TO ls_docubatch_com.
  MOVE-CORRESPONDING lips
    TO ls_docubatch_com.
* to be enhanced...

* display-mode
  IF t180-trtyp EQ chara.
    lv_display_only = charx.
  ELSE.
    READ TABLE xvbup
      INTO ls_vbup
      WITH KEY vbeln = lips-vbeln
               posnr = lips-posnr.
    IF lips-komkz    CA 'C12' OR
       ( lips-komkz  =  'D' AND
         vbup-lvsta  CA 'AB' AND
         sy-subrc    is initial "READ TABLE xvbup
       )                       OR
       ls_vbup-wbsta EQ 'C'.
      lv_display_only = charx.
    elseif likp-vlstk <> ' ' "distirbution case  note
      and lips-lgnum is not initial.
      call function 'L_T340D_READ_SINGLE'
        exporting
          iv_lgnum        = lips-lgnum
        importing
          es_t340d        = ls_t340d
        exceptions
          not_found       = 1
          others          = 2.
      if sy-subrc <> 0 or
         ls_t340d-decsy <> ' '.
      lv_display_only = charx.
      endif.
    ENDIF.
  ENDIF.

  PERFORM determine_process_id(sapmv50a)
    USING
      lips-vgbel
      lips-vgpos
    CHANGING
      lv_process_id
      lv_ebeln
      lv_ebelp.

* in case of EWM and decentral WM
  IF /spe/cl_ctrl=>get_whnr_typ( i_lgnum = likp-lgnum ) =
     /spe/cl_ctrl=>c_whnr_ewm.
    CASE xlikp-vbtyp.
      WHEN vbtyp_liav. " '7' inbound deliveries
        lv_pikmg = xlips-ebumg.
        lv_vrkmp = xlips-vrkme.
      WHEN vbtyp_lino. " 'J' outbound deliveries
        lv_pikmg = xlips-lfimg.
        lv_vrkmp = xlips-vrkme.
      WHEN OTHERS.
        lv_pikmg = xlips-pikmg.
        lv_vrkmp = xlips-vrkmp.
    ENDCASE.
  ELSEIF ls_vbup-kosta IS INITIAL.
    lv_pikmg = xlips-lfimg.
    lv_vrkmp = xlips-vrkme.
  ELSE.
    lv_pikmg = xlips-pikmg.
    lv_vrkmp = xlips-vrkmp.
  ENDIF.

  CALL FUNCTION 'VBDBDM_DATA_GET_FROM_LE'
    EXPORTING
      i_matnr           = lips-matnr
      i_werks           = lips-werks
      i_docubatch_charg = lipsd-docubatch_charg
      i_quantity        = lv_pikmg
      i_uom             = lv_vrkmp
      i_process_id      = lv_process_id
      i_ebeln           = lv_ebeln
      i_ebelp           = lv_ebelp
      i_vbeln           = lips-vbeln
      i_posnr           = lips-posnr
      i_display_only    = lv_display_only
      is_docubatch_com  = ls_docubatch_com
    IMPORTING
      e_control         = lipsd-docubatch_control
    EXCEPTIONS
      OTHERS            = 0.

ENDFORM.                    "docubatch_detail_open

*&--------------------------------------------------------------------*
*&      Form  docubatch_detail_close
*&--------------------------------------------------------------------*
FORM docubatch_detail_close.

  CHECK likp-vbtyp EQ vbtyp_lino
     OR likp-vbtyp EQ vbtyp_liav.

  IF lips-matnr IS INITIAL OR
     lips-werks IS INITIAL OR
     lips-posnr IS INITIAL.
    EXIT.
  ENDIF.

  CALL FUNCTION 'VBDBDM_DATA_PUT_TO_LE'
    IMPORTING
      e_docubatch_charg = lipsd-docubatch_charg
      e_mult_entries    = lipsd-docubatch_mult_entries.

  READ TABLE xlips
    WITH KEY posnr = lips-posnr
    TRANSPORTING NO FIELDS.
  CHECK sy-subrc IS INITIAL.
  xlips-docubatch_charg        = lipsd-docubatch_charg.
  xlips-docubatch_mult_entries = lipsd-docubatch_mult_entries.
  gs_xlips_main-docubatch_charg = lipsd-docubatch_charg.    "n_1420451
  MODIFY xlips
    INDEX sy-tabix
    TRANSPORTING docubatch_charg
                 docubatch_mult_entries.

ENDFORM.                    "docubatch_detail_close

*&--------------------------------------------------------------------*
*&      Form  determine_pocess_id
*&--------------------------------------------------------------------*
FORM determine_process_id
  USING
    iv_vgbel            TYPE vgbel
    iv_vgpos            TYPE vgpos
  CHANGING
    cv_process_id       TYPE docubatch_process_id
    cv_ebeln            TYPE ebeln
    cv_ebelp            TYPE ebelp.

  CLEAR:
    cv_process_id,
    cv_ebeln,
    cv_ebelp.

  DATA:
    ls_lipspo           TYPE lipspo.

  CHECK lips-posar IS INITIAL.

  CASE likp-vbtyp.
    WHEN vbtyp_liav.
      IF NOT iv_vgbel IS INITIAL AND
         NOT iv_vgpos IS INITIAL.
        cv_process_id = '01'.
        cv_ebeln      = iv_vgbel.
        cv_ebelp      = iv_vgpos.
      ELSEIF xlips-rfvgtyp = 'V' AND
        iv_vgbel IS INITIAL      AND
        iv_vgpos IS INITIAL.
*       decentral case
*       determine purchase order information
        CALL FUNCTION 'SHP_LIPSPO_GET_SINGLE'
          EXPORTING
            if_handle_obj = likp-handle
            if_handle     = xlips-handle
          CHANGING
            cf_lipspo     = ls_lipspo
          EXCEPTIONS
            no_entry      = 1.
        IF sy-subrc IS INITIAL AND
          ls_lipspo IS NOT INITIAL.
          cv_process_id = '01'.
          cv_ebeln      = ls_lipspo-ponum.
          cv_ebelp      = ls_lipspo-itmno.
        ENDIF.

      ENDIF.
    WHEN vbtyp_lino.
      IF likp-werks IS INITIAL.
        cv_process_id = '06'.
      ENDIF.
  ENDCASE.

ENDFORM.                    "determine_process_id