*----------------------------------------------------------------------*
***INCLUDE MV45A_INTERNAL_HEAD_PASS_FCF01 .
*----------------------------------------------------------------------*
FORM internal_head_pass_fcode .

  IF gs_screenbadi_int_h-handler IS BOUND.
    CALL METHOD gs_screenbadi_int_h-handler->pass_fcode_to_subscreen
      EXPORTING
        is_int_head_tab    = gs_screenbadi_int_h
        iv_fcode_same_page = fcode_gleiche_seite
        iv_fcode           = fcode.
  ENDIF.

ENDFORM.                    " INTERNAL_HEAD_PASS_FCODE