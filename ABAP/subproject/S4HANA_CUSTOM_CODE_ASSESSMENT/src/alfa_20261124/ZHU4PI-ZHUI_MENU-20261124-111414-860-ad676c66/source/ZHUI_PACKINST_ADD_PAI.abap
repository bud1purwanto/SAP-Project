*&---------------------------------------------------------------------*
*&  Include           ZHUI_PACKINST_ADD_PAI
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  check_packing_instruction  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PACKING_INSTRUCTION INPUT.
  IF ZPACK_PCH-PINNR IS INITIAL AND ZPACK_PCH-VBELN IS INITIAL.
    MESSAGE E001(00) WITH
      'Isi Packing Instruction Number atau Sales Order Number.'.
  ELSE.
    IF ZPACK_PCH-PINNR IS INITIAL.
      SELECT SINGLE * FROM ZPACK_PCH
        WHERE VBELN = ZPACK_PCH-VBELN
          AND POSNR = ZPACK_PCH-POSNR.

      IF SY-SUBRC NE 0.
        MESSAGE E001(00) WITH
          'Packing Instruction untuk Sales document tidak ada.'.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM ZPACK_PCH
        WHERE PINNR = ZPACK_PCH-PINNR.
*          AND ( pinst = c_pinst_completed OR pinst = c_pinst_inprogress ).
*
*      IF sy-subrc NE 0.
*        MESSAGE e001(00) WITH
*          'Fasilitas ini hanya untuk packing instruction '
*          'In Progress atau Completed.'.
*      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_packing_instruction  INPUT


*&---------------------------------------------------------------------*
*&      Module  process_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PROCESS_9000 INPUT.
  DATA : ERRNO TYPE SY-SUBRC.
  CASE SY-UCOMM.
    WHEN 'ENTE'.
      PERFORM F_CHECK_REPLACE_PALLET USING ERRNO.
      IF ERRNO NE 0.
        B_IS_REPLACE = V_NO.
        MESSAGE W002(ZMM) WITH 'Pallet Nomer' S_PLTNO 'Tidak ada'.
      ELSEIF ERRNO = 0.
        PERFORM F_ADD_INSTRUCTION.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " process_9000  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_BOX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_BOX INPUT.
  PERFORM F_CHECK_BOX.
ENDMODULE.                 " CHECK_BOX  INPUT


*&---------------------------------------------------------------------*
*&      Module  CHECK_PALLET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PALLET INPUT.
  PERFORM F_CHECK_PALLET.
ENDMODULE.                 " CHECK_PALLET  INPUT

*&---------------------------------------------------------------------*
*&      Module  search_packing_instruction  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEARCH_PACKING_INSTRUCTION INPUT.
  PERFORM F_SEARCH_PACKING_INSTRUCTION.
ENDMODULE.                 " search_packing_instruction  INPUT

*&---------------------------------------------------------------------*
*&      Module  process_9000x  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PROCESS_9000X INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      LEAVE PROGRAM.

  ENDCASE.
ENDMODULE.                 " process_9000x  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_REPLACE_PALLET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_REPLACE_PALLET INPUT.
  CLEAR : ERRNO.
  PERFORM F_CHECK_REPLACE_PALLET CHANGING ERRNO.
  IF ERRNO NE 0.
    B_IS_REPLACE = V_NO.
    MESSAGE W002(ZMM) WITH 'Pallet Nomer' S_PLTNO 'Tidak ada'.
    RETURN.
  ENDIF.
ENDMODULE.                 " CHECK_REPLACE_PALLET  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_REPLACE_PALLET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CHECK_REPLACE_PALLET  CHANGING P_ERRNO.
  DATA : ZINS01 TYPE ZPACK_PC-ZINS01.

  CHECK B_IS_REPLACE NE ''.
  IF S_PLTNO = ''.
    P_ERRNO = 1.
  ELSE.
  SELECT ZINS01 INTO ZINS01
    FROM ZPACK_PC
    WHERE PINNR = ZPACK_PCH-PINNR
    AND   ZINS01 = S_PLTNO.
  ENDSELECT.
  P_ERRNO = SY-SUBRC.
  ENDIF.
ENDFORM.                    " F_CHECK_REPLACE_PALLET