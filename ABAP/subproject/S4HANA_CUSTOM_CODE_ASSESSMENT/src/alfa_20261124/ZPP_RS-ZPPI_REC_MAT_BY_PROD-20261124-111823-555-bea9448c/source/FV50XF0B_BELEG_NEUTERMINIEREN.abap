***INCLUDE FV50XF0B_BELEG_NEUTERMINIEREN .
*&---------------------------------------------------------------------*
*&      Form  BELEG_NEUTERMINIEREN
*&---------------------------------------------------------------------*
FORM beleg_neuterminieren.

  DATA: lf_flag_kodat_changed TYPE c.

  LOOP AT xlikp WHERE updkz NE updkz_delete.
    likp = xlikp.
    PERFORM likp_kodat_ermitteln(sapfv50k)
                              USING likp                  "INPUT
                                    likp                  "OUTPUT
                                    xlikp-vstrm
                                    xlikp-trtrm
                                    lf_flag_kodat_changed.
    MOVE-CORRESPONDING likp TO xlikp.
    MODIFY xlikp.
  ENDLOOP.

ENDFORM.                               " BELEG_NEUTERMINIEREN