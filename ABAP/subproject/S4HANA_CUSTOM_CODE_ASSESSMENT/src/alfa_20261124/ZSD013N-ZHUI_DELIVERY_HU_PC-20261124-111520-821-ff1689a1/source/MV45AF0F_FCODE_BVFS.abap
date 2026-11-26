*&---------------------------------------------------------------------*
*&  Include           MV45AF0F_FCODE_BVFS
*&---------------------------------------------------------------------*
FORM fcode_bvfs USING h185f STRUCTURE t185f
                      h185  STRUCTURE t185
                      h185v STRUCTURE t185v.

  IF cl_ops_switch_check=>ops_sfws_sc_erptms_sched( ) = abap_true.
    t185  = h185.
    t185f = h185f.
    t185v = h185v.

    PERFORM fcode_bvfp.

    PERFORM xvbap_uebersicht_ansteuern(sapfv45p).

    t185f-fcode = fcode_zurueck3.
    h185  = t185.
    h185f = t185f.
    h185v = t185v.
  ENDIF.

ENDFORM.                    "FCODE_BVFS