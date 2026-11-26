*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CUA_NAVIGATION_SET                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CUA_NAVIGATION_SET
*&---------------------------------------------------------------------*
*  Controls which of the navigation buttons on the item detail screen
*  are active or not. Importing parameter IF_POSNR contains the current
*  item number, IT_ILIPS the current ILIPS.
*
*  The form routine does not change the current header line of ILIPS!
*
FORM CUA_NAVIGATION_SET TABLES IT_ILIPS STRUCTURE SHP_ILIPS
                        USING  VALUE(IF_POSNR) TYPE POSNR_VL.

  DATA: LF_ILIPS_TABIX TYPE SYTABIX.
  FIELD-SYMBOLS: <LS_ILIPS> TYPE SHP_ILIPS.

* By default: all navigation buttons are active
  PERFORM CUA_FCODE_ALLOW USING 'FITE_T' YES. "first item
  PERFORM CUA_FCODE_ALLOW USING 'PITE_T' YES. "previous item
  PERFORM CUA_FCODE_ALLOW USING 'NITE_T' YES. "next item
  PERFORM CUA_FCODE_ALLOW USING 'LITE_T' YES. "last item

* Check whether first item is reached
  LOOP AT IT_ILIPS ASSIGNING <LS_ILIPS>
                WHERE SELKZ NE SPACE.
    IF <LS_ILIPS>-POSNR GE IF_POSNR.
      PERFORM CUA_FCODE_ALLOW USING 'FITE_T' NO.
      PERFORM CUA_FCODE_ALLOW USING 'PITE_T' NO.
    ENDIF.
    EXIT.
  ENDLOOP.
* Check whether last item is reached
  READ TABLE IT_ILIPS WITH KEY POSNR = IF_POSNR
                      TRANSPORTING NO FIELDS.
  LF_ILIPS_TABIX = SY-TABIX + 1.
  LOOP AT IT_ILIPS ASSIGNING <LS_ILIPS>
                   FROM LF_ILIPS_TABIX
                   WHERE SELKZ NE SPACE.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    PERFORM CUA_FCODE_ALLOW USING 'NITE_T' NO.
    PERFORM CUA_FCODE_ALLOW USING 'LITE_T' NO.
  ENDIF.

ENDFORM.                               " CUA_NAVIGATION_SET