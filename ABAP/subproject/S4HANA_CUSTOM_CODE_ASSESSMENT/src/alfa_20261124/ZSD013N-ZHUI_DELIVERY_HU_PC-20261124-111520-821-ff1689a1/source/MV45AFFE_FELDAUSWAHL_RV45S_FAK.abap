*----------------------------------------------------------------------*
*   INCLUDE MV45AFFE_FELDAUSWAHL_RV45S_FAK                             *
*----------------------------------------------------------------------*

FORM FELDAUSWAHL_RV45S-FAKKD.

  IF T180-TRVOG CN '0'.
    SCREEN-ACTIVE = 0.
  ENDIF.

ENDFORM.