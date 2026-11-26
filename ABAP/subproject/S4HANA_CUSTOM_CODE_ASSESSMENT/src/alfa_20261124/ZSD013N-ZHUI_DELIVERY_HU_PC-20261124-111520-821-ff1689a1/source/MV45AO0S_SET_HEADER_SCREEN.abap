*---------------------------------------------------
*   INCLUDE MV45AO0S_SET_HEADER_SCREEN                                 *
*---------------------------------------------------
*&--------------------------------------------------
*&      Module  SET_HEADER_SCREEN  OUTPUT
*&--------------------------------------------------
*       text
*---------------------------------------------------
MODULE SET_HEADER_SCREEN OUTPUT.
  CASE TAXI_TABSTRIP_OVERVIEW.
    WHEN 'T\01'.                       "General overview
      DETAIL_SCREEN = '4440'.

    WHEN 'T\03'.                       "Item detail
      DETAIL_SCREEN = '4480'.
  ENDCASE.

ENDMODULE.                             " SET_HEADER_SCREEN  OUTPUT