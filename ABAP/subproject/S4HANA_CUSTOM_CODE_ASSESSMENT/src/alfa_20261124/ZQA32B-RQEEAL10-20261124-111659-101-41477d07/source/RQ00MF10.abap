***INCLUDE RQ00MF10.
*---------------------------------------------------------------------*
*       FORM VARIANT_F10                                              *
*---------------------------------------------------------------------*
*       Benutzervariante einstellen    -> User-Command                *
*---------------------------------------------------------------------*
FORM variant_f10.

  DATA: h_repid LIKE sy-repid.

  h_repid = sy-repid.
  CALL FUNCTION 'PM_CHANGE_SELOPT'
    EXPORTING
      repname = h_repid
      tcode   = ' '
      uname   = sy-uname.

ENDFORM.                    "VARIANT_F10

*---------------------------------------------------------------------*
*       FORM VARIANT_START_F10                                        *
*---------------------------------------------------------------------*
*       Start über Variante                                           *
*---------------------------------------------------------------------*
FORM variant_start_f10.

  DATA: h_subrc LIKE sy-subrc.
  DATA: h_repid LIKE sy-repid.
  DATA: h_variant LIKE rsvar-variant.

  IF sy-slset IS INITIAL AND sy-calld IS INITIAL AND
     sy-tcode <> 'SE38' AND sy-tcode <> 'SA38'.
*
    h_repid = sy-repid.
    CLEAR h_variant.
    h_variant = 'U_'.
    WRITE sy-uname TO h_variant+2.
*   User Variant U_<username>
    CALL FUNCTION 'RS_VARIANT_EXISTS'
      EXPORTING
        report  = h_repid
        variant = h_variant
      IMPORTING
        r_c     = h_subrc.
    IF h_subrc <> 0.
      CLEAR h_variant.
      h_variant = 'CUS&TCODE_'.
      WRITE sy-tcode TO h_variant+10.
*     Customer variant CUS&TCODE_<sy-tcode>
      CALL FUNCTION 'RS_VARIANT_EXISTS'
        EXPORTING
          report  = h_repid
          variant = h_variant
        IMPORTING
          r_c     = h_subrc.
    ENDIF.
    IF h_subrc <> 0.
      CLEAR h_variant.
      h_variant = 'CUS&'.
      WRITE sy-tcode TO h_variant+5.
*     Customer variant CUS&<sy-tcode>
      CALL FUNCTION 'RS_VARIANT_EXISTS'
        EXPORTING
          report  = h_repid
          variant = h_variant
        IMPORTING
          r_c     = h_subrc.
    ENDIF.
    IF h_subrc <> 0.
      CLEAR h_variant.
      h_variant = 'SAP_TCODE_'.
      WRITE sy-tcode TO h_variant+10.
*       SAP variant SAP_TCODE_<sy-tcode>
      CALL FUNCTION 'RS_VARIANT_EXISTS'
        EXPORTING
          report  = h_repid
          variant = h_variant
        IMPORTING
          r_c     = h_subrc.
    ENDIF.
    IF h_subrc <> 0.
      CLEAR h_variant.
      h_variant = 'SAP&TCODE_'.
      WRITE sy-tcode TO h_variant+10.
*       SAP variant SAP&TCODE_<sy-tcode>
      CALL FUNCTION 'RS_VARIANT_EXISTS'
        EXPORTING
          report  = h_repid
          variant = h_variant
        IMPORTING
          r_c     = h_subrc.
    ENDIF.

    IF h_subrc = 0.
      CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
        EXPORTING
          report               = h_repid
          variant              = h_variant
        EXCEPTIONS
          variant_not_existent = 01
          variant_obsolete     = 02.
    ENDIF.
  ENDIF.

ENDFORM.                    "VARIANT_START_F10
*&---------------------------------------------------------------------*
*&      Form  USER_FC_STEUERN
*&---------------------------------------------------------------------*
*  Ausblenden der User-Fcodes auf dem Einstiegsbild bei Variantenpflege*
*----------------------------------------------------------------------*
FORM user_fc_steuern.
  DATA:
     h_repid LIKE sy-repid,
     l_submitinfo  LIKE rssubinfo,
     l_excl_fc_tab LIKE sy-ucomm    OCCURS 2.

  h_repid = sy-repid.


  CALL FUNCTION 'RS_SUBMIT_INFO'
    IMPORTING
      p_submit_info = l_submitinfo.
  IF l_submitinfo-mode_norml IS INITIAL.
*   keine normale Pflege
    APPEND 'FC01' TO l_excl_fc_tab.
*...append 'FC02' to l_excl_fc_tab.

    CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
      EXPORTING
        p_status  = sy-pfkey
        p_program = h_repid
      TABLES
        p_exclude = l_excl_fc_tab.
  ENDIF.

ENDFORM.                    " USER_FC_STEUERN