*----------------------------------------------------------------------*
***INCLUDE MV45AOAP_XVBAP_EXIT_LOOP_PAYSP .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  XVBAP_EXIT_FROM_LOOP_PAYSP  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE xvbap_exit_from_loop_paysp OUTPUT.

* Payment Service Provider
  IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true AND
     vbak-sppaym EQ cv_sppaym01 AND
     t180-trtyp EQ charv.
    PERFORM xvbap_exit_from_loop(sapfv45p).
  ENDIF.
ENDMODULE.                 " XVBAP_EXIT_FROM_LOOP_PAYSP  OUTPUT