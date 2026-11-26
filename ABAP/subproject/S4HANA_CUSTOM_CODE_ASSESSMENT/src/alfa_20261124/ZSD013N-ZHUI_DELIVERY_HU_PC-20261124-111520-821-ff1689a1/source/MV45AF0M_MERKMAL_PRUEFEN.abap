*----------------------------------------------------------------------*
*   INCLUDE MV45AF0_MERKMAL_PRUEFEN                                    *
*----------------------------------------------------------------------*
FORM merkmal_pruefen USING us_atnam
                           us_error
                           us_subrc.

  CHECK not us_atnam is initial.

* prüfen ob Merkmal existiert
  CALL FUNCTION 'CTUT_FEATURE_DATA'
       EXPORTING
            feature_neutral_name = us_atnam
  exceptions
       invalid_class_type          = 1
       missing_feature_information = 2
       no_feature_found            = 3
       no_feature_valid            = 4
       no_language                 = 5
       others                      = 6.

  IF sy-subrc <> 0.
    IF us_error ne space.
      MESSAGE e033(cl) WITH us_atnam.
    ELSE.
      us_subrc = sy-subrc.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.