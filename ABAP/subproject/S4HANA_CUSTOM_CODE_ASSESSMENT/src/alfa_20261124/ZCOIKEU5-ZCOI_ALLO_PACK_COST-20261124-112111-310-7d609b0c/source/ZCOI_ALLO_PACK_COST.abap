*&---------------------------------------------------------------------*
*& Report  ZCOI_ALLO_PACK_COST
*&---------------------------------------------------------------------*
*& Created by : Mualifi
*& Created on : 06-09-2012
*& Program    : ZCOI_ALLO_PACK_COST (Allocate Packing Costs)
*& Desc.      : Upload data use BAPI for KEU5
*&---------------------------------------------------------------------*
REPORT  ZCOI_ALLO_PACK_COST.

DATA : IT_RET   LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
       IT_T811F TYPE TABLE OF T811F WITH HEADER LINE,
       IT_T811K TYPE  T811K OCCURS 0 WITH HEADER LINE,
       IT_T811C TYPE T811C OCCURS 0  WITH HEADER LINE ,
       IT_T811S TYPE T811S OCCURS 0 WITH HEADER LINE,
       IT_T811L TYPE T811L OCCURS 0 WITH HEADER LINE.

data: p_CYCLE like IT_T811F-CYCLE." value '8888ZT1001'.

DATA : fname type string,
       fpath type IBIPPARMS-PATH,
       N type i,
       znoso_low(10) type c,
       znoso_high(10) type c.

DATA : BEGIN OF ITAB occurs 0,
       VCOAREA(8),                "add for new company
       vbeln type n length 10,    " like vbak-vbeln,
       posnr type n length 6,     "like vbap-posnr,
       value type p decimals 2,   "like T811F-value,
       END OF ITAB.

DATA: ITAB2 LIKE ITAB OCCURS 0 WITH HEADER LINE, "add for new company
      VLINE TYPE I,
      VMSG(50).

data: v_prog like Zproginfo-PGMNA value 'ZCOI_ALLO_PACK_COST'.
include Z_PROG_INFO.             "Program Documentation

selection-screen begin of block block1 with frame title text-001.
*PARAMETERS : rb1 radiobutton group 1,
*             rb2 radiobutton group 1.
*selection-screen end of block block1.

SELECTION-SCREEN skip.
SELECTION-SCREEN PUSHBUTTON /17(70) upld USER-COMMAND UPLD.
SELECTION-SCREEN skip.
SELECTION-SCREEN PUSHBUTTON /17(70) keu5 USER-COMMAND KEU5.
SELECTION-SCREEN skip.
SELECTION-SCREEN PUSHBUTTON /17(70) info USER-COMMAND INFO.
selection-screen end of block block1.


*********************
INITIALIZATION.
*********************
  MOVE 'Upload Data' TO UPLD.
  MOVE 'Execute KEU5' TO KEU5.
  MOVE 'Program Information' TO info.

AT SELECTION-SCREEN.
  IF sy-uCOMM = 'INFO'.
    perform f_PROG_INFO using v_prog.
  elseif sy-ucomm = 'KEU5'.
    call transaction 'KEU5'.
  elseif sy-ucomm = 'UPLD'.
    perform process.
  ENDIF.

*start-of-selection.
**  perform process.
*
*end-of-selection.

form process.

*  IF rb2 EQ 'X'.
*    Call TRANSACTION 'KEU5'.
*
*  ELSEIF rb1 EQ 'X'.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SY-CPROG
      DYNPRO_NUMBER = SY-DYNNR
      FIELD_NAME    = ' '
    IMPORTING
      FILE_NAME     = FPATH.

  MOVE FPATH to FNAME.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FNAME
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      data_tab            = ITAB.

  PERFORM CEK_CYCLE.  "ADD FOR NEW COMPANY
  IF VMSG IS NOT INITIAL.
    MESSAGE VMSG TYPE 'I'.
    EXIT.
  ENDIF.

  select * into table it_t811c from t811c
    where CYCLE = P_CYCLE.

  select * into table it_T811S from T811S
where CYCLE = P_CYCLE.

  select * into table it_t811k from t811k
where CYCLE = P_CYCLE.

  select * into table it_t811L from t811L
where CYCLE = P_CYCLE.


  select single * into it_t811f from t811f
where CYCLE = P_CYCLE.

  perform update_data.
  perform cek_data.

  CALL FUNCTION 'KGAL_CHANGE_SEGMENT'
    EXPORTING
      TESTRUN   = ' '
    TABLES
      IT811C    = IT_T811C
      IT811S    = IT_T811S
      IT811K    = IT_T811K
      IT811F    = IT_T811F
      IT811L    = IT_T811L
      ERROR_LOG = IT_RET.


  DATA : ls_subrc type sy-subrc.

  ls_subrc = 0.

  LOOP AT it_ret.
    if it_ret-type eq 'E'.
      write:/ it_ret-message.
    endif.

    if it_ret-type eq 'E' and ls_subrc eq 0.
      ls_subrc = 1.
    endif.
  ENDLOOP.
  .
  IF ls_SUBRC EQ 0.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
*    WRITE : /'Data has been uploaded succesfully'.
    message 'Data has been uploaded succesfuly..!' type 'I'.
  ELSE.
*    WRITE :/ 'Upload Failed'.
    message 'Upload Failed' type 'I'.
  ENDIF.
*  endif.    " rb
endform.


form update_data.
  data: V_somin type n length 10,
        v_somax type n length 10.

  sort ITAB by vbeln posnr.
  loop at ITAB.
    if sy-tabix = 1.
      it_t811k-VALMIN = ITAB-vbeln.
    endif.
    it_t811k-VALMAX = ITAB-vbeln.

    it_t811F-FPOS = sy-tabix.
    it_t811F-ELEMENT1 = ITAB-vbeln.
    it_t811F-ELEMENT2 = ITAB-posnr.
    it_t811F-value = ITAB-value.
    append it_t811F.
  endloop.

  modify it_t811k transporting VALMIN VALMAX where FIELD = 'KAUFN' AND CYCLE = P_CYCLE .".'8888ZT1001'.  "ADD FOR NEW COMPANY
endform.



form cek_data.
*  data: v_cek type p decimals 2.
*  loop at itab.
*    v_cek = v_cek + itab-value.
*  endloop.
*
*  if v_cek ne 10000.
*    message 'Total procentage of value must be 10000......!' type 'E'.
*  endif.

  loop at itab where vbeln ge '5000000'.
    exit.
  endloop.

  if sy-subrc = 0.
    message 'Salah SO number ( out of range)...!' type 'E'.
  endif.
endform.

*&---------------------------------------------------------------------*
*&      Form  CEK_CYCLE
*&---------------------------------------------------------------------*
*       text "add for new company
*----------------------------------------------------------------------*
FORM CEK_CYCLE.
  CLEAR: ITAB2, P_CYCLE, VMSG.
  REFRESH: ITAB2.

  ITAB2[] = ITAB[].
  DELETE ADJACENT DUPLICATES FROM ITAB2 COMPARING VCOAREA.
  DESCRIBE TABLE ITAB2 LINES VLINE.

  IF VLINE = 1.
    READ TABLE ITAB2 INDEX 1.
    IF SY-SUBRC = 0.
      IF ITAB2-VCOAREA = 'TSCO'.
        P_CYCLE = '8888ZT1001'.
      ELSEIF ITAB2-VCOAREA = 'TACO'.
        P_CYCLE = '8888ZT2001'.
      ELSEIF ITAB2-VCOAREA = 'TTCO'.
        P_CYCLE = '6500ZT1001'.
      ENDIF.
    ENDIF.
  ELSE.
    VMSG = 'CEK TEMPLATE FIELD CO AREA' .
    EXIT.
  ENDIF.

ENDFORM.                    "CEK_CYCLE