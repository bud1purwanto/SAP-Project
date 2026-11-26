*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_TDAT                                        *
*----------------------------------------------------------------------*
*   Selection date on the initial screen of VL01 is resetted to
*   current date.
*----------------------------------------------------------------------*

FORM FCODE_TDAT.

  LV50C-DATBI = SY-DATLO.
  SET PARAMETER ID 'LEDAT' FIELD LV50C-DATBI.

ENDFORM.