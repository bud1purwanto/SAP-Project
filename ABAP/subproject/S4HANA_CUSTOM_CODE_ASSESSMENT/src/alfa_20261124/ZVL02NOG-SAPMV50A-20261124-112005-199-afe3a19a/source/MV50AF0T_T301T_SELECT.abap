*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T301T_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T301T_SELECT                                             *
*---------------------------------------------------------------------*
*       Read text for the storage type                                *
*---------------------------------------------------------------------*
FORM T301T_SELECT USING IF_LGTYP LIKE LIPS-LGTYP           "hp_314544
                        if_lgnum like lips-lgnum.

  CHECK IF_LGTYP NE T301T-LGTYP or
        if_lgnum ne t301t-lgnum    .

  SELECT SINGLE * FROM T301T WHERE SPRAS = SY-LANGU AND
                                   lgnum = if_lgnum and
                                   LGTYP = IF_LGTYP.

  IF SY-SUBRC NE 0.
    CLEAR T301T.
  ENDIF.

ENDFORM.