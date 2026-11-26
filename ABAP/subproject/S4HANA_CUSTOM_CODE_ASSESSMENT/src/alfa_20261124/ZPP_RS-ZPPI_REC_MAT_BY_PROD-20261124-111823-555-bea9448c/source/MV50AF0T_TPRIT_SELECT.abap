*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TPRIT_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TPRIT_SELECT                                             *
*---------------------------------------------------------------------*
*       Read text table for delivery priority                         *
*---------------------------------------------------------------------*
FORM TPRIT_SELECT USING IF_LPRIO LIKE LIKP-LPRIO
                        IF_ERROR TYPE C
                        CF_SUBRC TYPE SYSUBRC.

  CF_SUBRC = 0.
  CHECK: IF_LPRIO NE TPRIT-LPRIO.

  SELECT SINGLE * FROM TPRIT WHERE SPRAS EQ SY-LANGU
                               AND LPRIO EQ IF_LPRIO.

  IF SY-SUBRC NE 0.
    CLEAR TPRIT.
    CF_SUBRC = 4.
  ENDIF.

ENDFORM.




























