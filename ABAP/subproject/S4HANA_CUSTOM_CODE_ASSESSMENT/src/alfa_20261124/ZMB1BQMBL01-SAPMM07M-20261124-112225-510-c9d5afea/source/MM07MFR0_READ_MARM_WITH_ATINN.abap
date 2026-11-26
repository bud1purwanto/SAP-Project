*eject
*&---------------------------------------------------------------------*
*&      Form  READ_MARM_WITH_ATINN
*&---------------------------------------------------------------------*
* Checks whether material has any product/active ingredient UOMs
*----------------------------------------------------------------------*
FORM read_marm_with_atinn CHANGING p_x_no_altme.

  DATA: l_marm_tab LIKE marm OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'VBWS_UNITS_OF_MATERIAL'
       EXPORTING
            i_matnr          = mseg-matnr
       TABLES
            ws_marm_tab      = l_marm_tab
       EXCEPTIONS
            wrong_call       = 1
            no_units         = 2
            units_not_active = 3
            OTHERS           = 4.

  IF sy-subrc NE 0.
    p_x_no_altme = x.
  ELSE.
    CLEAR p_x_no_altme.
  ENDIF.
  CLEAR sy-subrc.


ENDFORM.                               " READ_MARM_WITH_ATINN