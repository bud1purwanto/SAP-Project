*&---------------------------------------------------------------------*
*& Report  ZPERTAMAX
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZPERTAMAX.

DATA : BEGIN OF IT_TAB OCCURS 0,
       X1(18),
       X2(10),
       X3(4),
       Y1(10),
       Y2(10),
       Y3(10),
       Y4(10),
       Y5(10),
       Y6(10),
       END OF IT_TAB.

DATA: VV_MODE(1).

DATA: IT_BDCDATA LIKE BDCDATA OCCURS 0 WITH HEADER LINE.

DATA: FNAME TYPE STRING,
      FPATH TYPE IBIPPARMS-PATH.
DATA: Z(9) TYPE N,
      B(10),
      D(10),
      E(10),
      F(10),
      G(10),
      H(10),
      I(10).

START-OF-SELECTION.
*  CALL FUNCTION 'F4_FILENAME'
*    EXPORTING
*      PROGRAM_NAME  = SY-CPROG
*      DYNPRO_NUMBER = SY-DYNNR
*      FIELD_NAME    = ' '
*    IMPORTING
*      FILE_NAME     = fpath.
*
*  MOVE fpath to fname.
*
*  CALL FUNCTION 'GUI_UPLOAD'
*    EXPORTING
*      filename            = fname
*      FILETYPE            = 'ASC'
*      HAS_FIELD_SEPARATOR = 'X'
*    TABLES
*      data_tab            = it_tab.

  Z = 000748137.
  VV_MODE = 'N'.
*  perform open_group.

  WHILE Z < 049999999.
    CLEAR: B,D,E,F,G,H,I,IT_BDCDATA.
    REFRESH: IT_BDCDATA.
    Z = Z + 1.
    CONCATENATE 'Z' Z INTO  B.
    CONCATENATE 'A' Z INTO  D.
    CONCATENATE 'B' Z INTO  E.
    CONCATENATE 'C' Z INTO  F.
    CONCATENATE 'D' Z INTO  G.
    CONCATENATE 'E' Z INTO  H.
    CONCATENATE 'F' Z INTO  I.
    PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'DFBATCH-CHARG'.
    PERFORM BDC_FIELD       USING 'DFBATCH-MATNR'
                                  'ZPERTAMAX'.
    PERFORM BDC_FIELD       USING 'DFBATCH-CHARG'
                                  B.
    PERFORM BDC_FIELD       USING 'DFBATCH-WERKS'
                                  '0001'.
    PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=CLAS'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'MCHA-HSDAT'.
    PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=SAVE'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RCTMS-MWERT(06)'.
    PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'
                                  D.
    PERFORM BDC_FIELD       USING 'RCTMS-MWERT(02)'
                                  E.
    PERFORM BDC_FIELD       USING 'RCTMS-MWERT(03)'
                                  F.
    PERFORM BDC_FIELD       USING 'RCTMS-MWERT(04)'
                                  G.
    PERFORM BDC_FIELD       USING 'RCTMS-MWERT(05)'
                                  H.
    PERFORM BDC_FIELD       USING 'RCTMS-MWERT(06)'
                                  I.
    CALL TRANSACTION 'MSC1N' USING IT_BDCDATA
                     MODE   VV_MODE.
  ENDWHILE.
*  perform close_group.

FORM BDC_DYNPRO USING PROG SCR.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-PROGRAM = PROG.
  IT_BDCDATA-DYNPRO  = SCR.
  IT_BDCDATA-DYNBEGIN = 'X'.
  APPEND IT_BDCDATA.
ENDFORM.

FORM BDC_FIELD USING FNAM FVAL.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-FNAM = FNAM.
  IT_BDCDATA-FVAL  = FVAL.
  APPEND IT_BDCDATA.
ENDFORM.