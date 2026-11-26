*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TRANSFORM_DOUBLECLICK                             *
*----------------------------------------------------------------------*
* By default, double click actions (FCODE assigned to function key F2)
* are calling FCODE IDET_T. On some screens, another FCODE should be
* active instead

FORM TRANSFORM_DOUBLECLICK CHANGING CF_FCODE TYPE FCODE.

  CHECK CF_FCODE EQ 'IDET_T'.

  IF TAXI_SCREEN_GROUP(1) EQ C_TAXI_SCRGRP_OVERVIEW(1).
    CF_FCODE = 'IDET_T'.
  ELSE.
    CASE TAXI_PANEL.
      WHEN 'CHSP'.                     "item batch split
        CF_FCODE = 'CDET_T'.
      WHEN 'HPAR'.                     "partner
        CF_FCODE = 'PSDE'.
      WHEN 'HKON' OR 'IKON'.           "conditions
        CF_FCODE = 'V69A_KODE'.
      WHEN OTHERS.
        CF_FCODE = FCODE_GLEICHE_SEITE.
    ENDCASE.
  ENDIF.

ENDFORM.