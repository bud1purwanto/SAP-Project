*&---------------------------------------------------------------------*
*&  Include           ZPPI_REC_EXEC_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_7000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7000 OUTPUT.
  SET PF-STATUS 'PFST_7000'.
  SET TITLEBAR  'TB_7000'.
ENDMODULE.                 " STATUS_7000  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_RECYCLE01'. DO NOT CHANGE THIS LIN
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE ZTC_RECYCLE01_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_RECYCLE01 LINES ZTC_RECYCLE01-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_RECYCLE01'. DO NOT CHANGE THIS LIN
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE ZTC_RECYCLE01_GET_LINES OUTPUT.
  G_ZTC_RECYCLE01_LINES = SY-LOOPC.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_7200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7100 OUTPUT.
*  CLEAR: ZRESOURCE.
*  FREE MEMORY ID 'AGR'.
  ZPOSDATE = SY-DATUM.
  SET PF-STATUS 'PFST_7100'.
  SET TITLEBAR  'TB_7100'.

  LOOP AT SCREEN.
    IF SCREEN-NAME = 'WA_RECYCLE01-LGORT2'.
      IF IT_RECYCLE01[] IS NOT INITIAL.
        SCREEN-INPUT = 1.
        MODIFY SCREEN.
      ELSE.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " STATUS_7200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_7210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_7210 OUTPUT.
*  SELECTION-SCREEN BEGIN OF SCREEN 7210 AS SUBSCREEN.
*    SELECTION-SCREEN BEGIN OF BLOCK spr_cancel WITH FRAME TITLE FRMT7210.
*
*      SELECTION-SCREEN BEGIN OF LINE.
*        SELECTION-SCREEN COMMENT (12) TXT1.
*        SELECT-OPTIONS: so_plant FOR afpo-dwerk OBLIGATORY.
*      SELECTION-SCREEN END OF LINE.
*
*      SELECTION-SCREEN BEGIN OF LINE.
*        SELECTION-SCREEN COMMENT (12) TXT2.
*        SELECT-OPTIONS: so_matnr FOR afpo-matnr.
*      SELECTION-SCREEN END OF LINE.
*
*      SELECTION-SCREEN BEGIN OF LINE.
*        SELECTION-SCREEN COMMENT (12) TXT3.
*        SELECT-OPTIONS: so_aufnr FOR afpo-aufnr.
*      SELECTION-SCREEN END OF LINE.
*
*      SELECTION-SCREEN BEGIN OF LINE.
*        SELECTION-SCREEN COMMENT (12) TXT4.
*        SELECT-OPTIONS: so_res   FOR rcrde-resource NO INTERVALS NO-EXTENSION.
*      SELECTION-SCREEN END OF LINE.
*
*      SELECTION-SCREEN BEGIN OF LINE.
*        SELECTION-SCREEN COMMENT (12) TXT5.
*        SELECT-OPTIONS: so_posdt FOR aufk-erdat NO INTERVALS NO-EXTENSION.
*      SELECTION-SCREEN END OF LINE.
*
*    SELECTION-SCREEN END OF BLOCK spr_cancel.
*  SELECTION-SCREEN END OF SCREEN 7210.

  FRMT7210 = 'Cancellation'.
  TXT1 = 'Plant'.
  TXT2 = 'Material'.
  TXT3 = 'Order'.
  TXT4 = 'Resource'.
  TXT5 = 'Posting Date'.
ENDMODULE.                 " SEL_SCR_7210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_7200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7200 OUTPUT.
  SET PF-STATUS 'PFST_7200'.
  SET TITLEBAR  'TB_7200'.
ENDMODULE.                 " STATUS_7200  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_CANCEL01'. DO NOT CHANGE THIS LINE
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE ZTC_CANCEL01_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_CANCEL01 LINES ZTC_CANCEL01-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_CANCEL01'. DO NOT CHANGE THIS LINE
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE ZTC_CANCEL01_GET_LINES OUTPUT.
  G_ZTC_CANCEL01_LINES = SY-LOOPC.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_7310  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_7310 OUTPUT.
*
*  SELECTION-SCREEN BEGIN OF SCREEN 7310 AS SUBSCREEN NO INTERVALS.
*    SELECTION-SCREEN BEGIN OF BLOCK spr_error WITH FRAME TITLE FRMT7310.
*
*      SELECTION-SCREEN BEGIN OF LINE.
*        SELECTION-SCREEN COMMENT (12) TXT6.
*        SELECT-OPTIONS: so_plnt2 FOR afpo-dwerk OBLIGATORY NO INTERVALS NO-EXTENSION.
*      SELECTION-SCREEN END OF LINE.
*
*      SELECTION-SCREEN BEGIN OF LINE.
*        SELECTION-SCREEN COMMENT (12) TXT7.
*        SELECT-OPTIONS: so_res2  FOR rcrde-resource NO INTERVALS NO-EXTENSION.
*      SELECTION-SCREEN END OF LINE.
*
*      SELECTION-SCREEN BEGIN OF LINE.
*        SELECTION-SCREEN COMMENT (12) TXT8.
*        SELECT-OPTIONS: so_psdt2 FOR aufk-erdat NO INTERVALS NO-EXTENSION.
*      SELECTION-SCREEN END OF LINE.
*
*      SELECTION-SCREEN BEGIN OF LINE.
*        SELECTION-SCREEN COMMENT (12) TXT9.
*        SELECT-OPTIONS: so_mtnr2 FOR afpo-matnr NO INTERVALS NO-EXTENSION.
*      SELECTION-SCREEN END OF LINE.
*
*      SELECTION-SCREEN BEGIN OF LINE.
*        SELECTION-SCREEN COMMENT (12) TXT10.
*        SELECT-OPTIONS: so_lgort FOR afpo-lgort NO INTERVALS NO-EXTENSION.
*      SELECTION-SCREEN END OF LINE.
*
*    SELECTION-SCREEN END OF BLOCK spr_error.
*  SELECTION-SCREEN END OF SCREEN 7310.
*
  FRMT7310 = 'Error Handling'.
  TXT6  = 'Plant'.
  TXT7  = 'Resource'.
  TXT8  = 'Posting Date'.
  TXT9  = 'Material'.
  TXT10 = 'Sloc GI'.
  TXT11 = 'NIK'.
  TXT12 = 'Order Number'.
  TXT13 = 'Created On'.

ENDMODULE.                 " SEL_SCR_7310  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_7300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7300 OUTPUT.
  SET PF-STATUS 'PFST_7300'.
  SET TITLEBAR  'TB_7300'.
ENDMODULE.                 " STATUS_7300  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_ERRHAND'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE ZTC_ERRHAND_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_ERROR01 LINES ZTC_ERRHAND-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC_ERRHAND'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE ZTC_ERRHAND_GET_LINES OUTPUT.
  G_ZTC_ERRHAND_LINES = SY-LOOPC.
ENDMODULE.