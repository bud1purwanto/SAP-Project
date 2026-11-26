*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_VERP                                              *
*----------------------------------------------------------------------*
*       perForm  CHK_ITEM_NUM.
*       perForm  CHK_SALES_UNIT.
*       perForm  CHK_UNIT_OF_MEASURE.

*&---------------------------------------------------------------------*
*&      Form  CHK_ITEM_NUM
*&---------------------------------------------------------------------*
FORM CHK_ITEM_NUM TABLES   IT_VERPO STRUCTURE VERPO
                           IT_XLIPS STRUCTURE XLIPS.

  DATA: BEGIN OF LT_MEM_POSNR OCCURS 10,
           POSNR LIKE IT_VERPO-POSNR,
        END OF LT_MEM_POSNR.
  CLEAR LT_MEM_POSNR.
  REFRESH LT_MEM_POSNR.

* check for invalid item number
 LOOP AT IT_VERPO TRANSPORTING NO FIELDS WHERE POSNR NE SPACE.
   EXIT.
 ENDLOOP.
 CHECK SY-SUBRC IS INITIAL.
 LOOP AT IT_VERPO WHERE EXIDV IS INITIAL AND POSNR NE SPACE.
    READ TABLE LT_MEM_POSNR WITH KEY POSNR = IT_VERPO-POSNR
                                     TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      READ TABLE IT_XLIPS WITH KEY VBELN = IT_VERPO-VBELN
                                   POSNR = IT_VERPO-POSNR.
      IF SY-SUBRC NE 0.
        MESSAGE E216 WITH IT_VERPO-POSNR.
      ENDIF.
      LT_MEM_POSNR-POSNR = IT_VERPO-POSNR.
      APPEND LT_MEM_POSNR.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " CHK_ITEM_NUM
*&---------------------------------------------------------------------*
*&      Form  CHK_SALES_UNIT
*&---------------------------------------------------------------------*
FORM CHK_SALES_UNIT TABLES   IT_VERPO STRUCTURE VERPO
                             IT_XLIPS STRUCTURE XLIPS.

  DATA: BEGIN OF LT_MEM_POSNR OCCURS 10,
           POSNR LIKE IT_VERPO-POSNR,
           VRKME LIKE IT_VERPO-VRKME,
        END OF LT_MEM_POSNR.
  CLEAR LT_MEM_POSNR.
  REFRESH LT_MEM_POSNR.

* check for invalid sales unit
 LOOP AT IT_VERPO TRANSPORTING NO FIELDS WHERE VRKME NE SPACE.
   EXIT.
 ENDLOOP.
 CHECK SY-SUBRC IS INITIAL.
 LOOP AT IT_VERPO WHERE EXIDV IS INITIAL AND NOT VRKME IS INITIAL.
    READ TABLE LT_MEM_POSNR WITH KEY POSNR = IT_VERPO-POSNR
                                     VRKME = IT_VERPO-VRKME
                                     TRANSPORTING NO FIELDS.
    IF SY-SUBRC NE 0.
      READ TABLE IT_XLIPS WITH KEY VBELN = IT_VERPO-VBELN
                                   POSNR = IT_VERPO-POSNR
                                       TRANSPORTING VRKME.
      IF SY-SUBRC EQ 0.
        IF IT_VERPO-VRKME NE IT_XLIPS-VRKME.
           MESSAGE E293(vl) WITH IT_VERPO-VRKME IT_XLIPS-VRKME.
        ENDIF.
      ENDIF.
      LT_MEM_POSNR-POSNR = IT_VERPO-POSNR.
      LT_MEM_POSNR-VRKME = IT_VERPO-VRKME.
      APPEND LT_MEM_POSNR.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " CHK_SALES_UNIT
*&---------------------------------------------------------------------*
*&      Form  CHK_UNIT_OF_MEASURE
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*      -->IT_VERKO                                                     *
*      -->IT_VERPO                                                     *
*----------------------------------------------------------------------*
FORM CHK_UNIT_OF_MEASURE TABLES   IT_VERKO STRUCTURE VERKO.
  DATA:     LF_RETCODE    LIKE SY-SUBRC.
  DATA: LF_TEXT_UNIT(3) TYPE C.
  DATA: BEGIN OF LT_MEM_UNIT_MASS OCCURS 10,
           UNIT LIKE T006-MSEHI,
        END OF LT_MEM_UNIT_MASS.
  DATA: BEGIN OF LT_MEM_UNIT_VOL OCCURS 10,
           UNIT LIKE T006-MSEHI,
        END OF LT_MEM_UNIT_VOL.

  CLEAR LT_MEM_UNIT_MASS.
  REFRESH LT_MEM_UNIT_MASS.
  CLEAR LT_MEM_UNIT_VOL.
  REFRESH LT_MEM_UNIT_VOL.

  LOOP AT IT_VERKO WHERE NOT GEWEI_MAX IS INITIAL
                      OR NOT VOLEH_MAX IS INITIAL.
    IF NOT IT_VERKO-GEWEI_MAX IS INITIAL.
      READ TABLE LT_MEM_UNIT_MASS WITH KEY UNIT = IT_VERKO-GEWEI_MAX.
      IF SY-SUBRC NE 0.
*   check for valid mass unit of measure (T006)
        PERFORM CHECK_UNIT_MASS USING     IT_VERKO-GEWEI_MAX
                                CHANGING  LF_RETCODE.
        IF LF_RETCODE NE 0.
          LF_TEXT_UNIT = IT_VERKO-GEWEI_MAX.
          MESSAGE E077 WITH LF_TEXT_UNIT.
        ENDIF.
        LT_MEM_UNIT_MASS-UNIT = IT_VERKO-GEWEI_MAX.
        APPEND LT_MEM_UNIT_MASS.
      ENDIF.
    ENDIF.
    IF NOT IT_VERKO-VOLEH_MAX IS INITIAL.
*   check for valid volume unit of measure (T006)
      READ TABLE LT_MEM_UNIT_VOL WITH KEY UNIT = IT_VERKO-VOLEH_MAX.
      IF SY-SUBRC NE 0.
        PERFORM CHECK_UNIT_VOL USING    IT_VERKO-VOLEH_MAX
                               CHANGING LF_RETCODE.
        IF LF_RETCODE NE 0.
          LF_TEXT_UNIT = IT_VERKO-VOLEH_MAX.
          MESSAGE E078 WITH LF_TEXT_UNIT.
        ENDIF.
        LT_MEM_UNIT_VOL-UNIT = IT_VERKO-VOLEH_MAX.
        APPEND LT_MEM_UNIT_VOL.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " CHK_UNIT_OF_MEASURE
*&---------------------------------------------------------------------*
*&      Form  CHECK_UNIT_MASS
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM CHECK_UNIT_MASS USING    LF_UNIT    LIKE T006-MSEHI
                     CHANGING CF_RETCODE LIKE SY-SUBRC.

  CF_RETCODE = 0.
*   check legal units of measure
  CALL FUNCTION 'DIMENSIONCHECK_MASS'
       EXPORTING
            GEWEI               = LF_UNIT
       EXCEPTIONS
            DIMENSION_NOT_MASS  = 1
            T006D_ENTRY_MISSING = 2
            T006_ENTRY_MISSING  = 3
            OTHERS              = 4.

  IF SY-SUBRC NE 0.
    CF_RETCODE = 1.
  ENDIF.
ENDFORM.                               " CHECK_UNIT_MASS
*&---------------------------------------------------------------------*
*&      Form  CHECK_UNIT_VOL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM CHECK_UNIT_VOL  USING    LF_UNIT    LIKE T006-MSEHI
                     CHANGING CF_RETCODE LIKE SY-SUBRC.

  CF_RETCODE = 0.

  CALL FUNCTION 'DIMENSIONCHECK_VOLUME'
       EXPORTING
            VOLEH                = LF_UNIT
       EXCEPTIONS
            DIMENSION_NOT_VOLUME = 1
            T006D_ENTRY_MISSING  = 2
            T006_ENTRY_MISSING   = 3
            OTHERS               = 4.

  IF SY-SUBRC NE 0.
    CF_RETCODE = 1.
  ENDIF.
ENDFORM.                               " CHECK_UNIT_VOL