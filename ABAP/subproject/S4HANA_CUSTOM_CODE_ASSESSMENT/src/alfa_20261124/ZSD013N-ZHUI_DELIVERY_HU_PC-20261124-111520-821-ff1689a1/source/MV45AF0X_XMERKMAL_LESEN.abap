*----------------------------------------------------------------------*
*   INCLUDE MV45AF0X_XMERKMAL_LESEN                                    *
*----------------------------------------------------------------------*
FORM xmerkmal_lesen USING us_atnam
                          us_error
                          us_tabix
                 CHANGING us_subrc.

  CLEAR us_subrc.

  READ TABLE xmerkmal WITH KEY INDEX = us_tabix.
  IF sy-subrc > 0.
    SELECT SINGLE * FROM cabn WHERE atnam = us_atnam.
    IF sy-subrc <> 0.
* Merkmal physisch gelöscht
      us_subrc = sy-subrc.
      EXIT.
    ENDIF.
    xmerkmal-atnam = us_atnam.
    xmerkmal-atinn = cabn-atinn.
    xmerkmal-atein = cabn-atein.
    xmerkmal-atinp = cabn-atinp.
ENHANCEMENT-POINT XMERKMAL_LESEN_01 SPOTS ES_SAPMV45A.
* Text zum Merkmal holen
    SELECT SINGLE * FROM cabnt WHERE atinn = cabn-atinn AND
                                     spras = sy-langu.
    IF sy-subrc = 0.
      xmerkmal-atbez = cabnt-atbez.
    ELSE.
      CLEAR xmerkmal-atbez.
    ENDIF.
    xmerkmal-index = us_tabix.
    APPEND xmerkmal.
  ENDIF.

ENDFORM.