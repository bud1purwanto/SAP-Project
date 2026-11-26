*&---------------------------------------------------------------------*
*&      Form  serialnumber_get_anzsn
*&---------------------------------------------------------------------*
* an extern-report gets the number of serialnumbers
*-----------------------------------------------------------------------
FORM  serialnumber_get_anzsn CHANGING p_anzsn.

  p_anzsn = dm07m-anzsn.

ENDFORM.