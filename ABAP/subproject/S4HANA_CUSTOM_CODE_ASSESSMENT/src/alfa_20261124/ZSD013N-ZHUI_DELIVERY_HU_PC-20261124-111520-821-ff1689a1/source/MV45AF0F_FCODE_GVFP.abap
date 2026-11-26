*&---------------------------------------------------------------------*
*&  Include           MV45AF0F_FCODE_GVFP
*&---------------------------------------------------------------------*
FORM FCODE_GVFP.

  if cl_ops_switch_check=>OPS_SFWS_SC_ERPTMS_SCHED( ) = abap_true.
* Aufruf der Gruppenverfügbarkeitsprüfung (analog zu FCODE BVFP)
    PERFORM VERFUEGBARKEIT_PRUEFEN_GRUPPEN(SAPFV45P) USING VERARB_HELL.
  endif.

ENDFORM.