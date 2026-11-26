*&---------------------------------------------------------------------*
*&  Include           /SPE/MV50AF04
*&---------------------------------------------------------------------*
FORM tcode_set USING iv_tcode TYPE sy-tcode.               "v_n_1614770

* Take over transaction code
  t180-tcode = iv_tcode.

* Set dependent data
  PERFORM t180_interpretieren USING t180-tcode.

ENDFORM.                                                   "^_n_1614770