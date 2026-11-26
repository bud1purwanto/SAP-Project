*&---------------------------------------------------------------------*
*&  Include           ZBDC                                             *
*&---------------------------------------------------------------------*

DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA:   nodata_character VALUE '/'.

*&---------------------------------------------------------------------*
*&      Form  bdc_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_MESSTAB text
*      -->FU_TCODE   text
*      -->FU_MODE    text
*      -->FU_BINPT   text
*----------------------------------------------------------------------*
*FORM bdc_transaction TABLES ft_messtab USING fu_tcode fu_mode fu_nobinpt.
*  DATA: l_subrc LIKE sy-subrc.
*  DATA: s_options TYPE ctu_params.
*
*  s_options-dismode  = fu_mode.
*  s_options-updmode  = 'S'.
*  s_options-racommit = 'X'.
*  s_options-nobinpt  = fu_nobinpt.
*  s_options-nobiend  = 'X'.
*
*  CALL TRANSACTION fu_tcode USING bdcdata
*                   OPTIONS FROM s_options
*                   MESSAGES INTO ft_messtab.
*
*  l_subrc = sy-subrc.
*  REFRESH bdcdata.
*  sy-subrc = l_subrc.
*ENDFORM.                    "BDC_TRANSACTION2


*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval <> nodata_character.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM.                    "BDC_FIELD

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_nodata USING p_nodata.
  nodata_character = p_nodata.
ENDFORM.                    "BDC_NODATA