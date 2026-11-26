*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CUA_TAXITAB_ALLOW                                 *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CUA_TAXITAB_ALLOW
*&---------------------------------------------------------------------*
*       Build table of inactive tabstrips
*----------------------------------------------------------------------*
FORM CUA_TAXITAB_ALLOW USING IF_FCODE TYPE FCODE
                             IF_ACTION TYPE C.

  CASE IF_ACTION.
    WHEN YES.                          "allow fcode
      LOOP AT TAXI_INACTIVE_FCODES WHERE FCODE EQ IF_FCODE.
        DELETE TAXI_INACTIVE_FCODES.
      ENDLOOP.
    WHEN NO.                           "forbidd fcode
      READ TABLE TAXI_INACTIVE_FCODES WITH KEY FCODE = IF_FCODE
                                      BINARY SEARCH.
      IF SY-SUBRC NE 0.
        TAXI_INACTIVE_FCODES-FCODE = IF_FCODE.
        INSERT TAXI_INACTIVE_FCODES INDEX SY-TABIX.
      ENDIF.
  ENDCASE.

ENDFORM.                               " CUA_TAXITAB_ALLOW