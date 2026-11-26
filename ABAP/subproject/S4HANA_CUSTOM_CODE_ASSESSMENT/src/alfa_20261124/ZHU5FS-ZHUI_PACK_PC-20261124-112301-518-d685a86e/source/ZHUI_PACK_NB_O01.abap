*&---------------------------------------------------------------------*
*&  Include           ZHU_PACK_NB_O01                                *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  init_screen_100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_SCREEN_100 OUTPUT.
  SET TITLEBAR '100'.
  SET PF-STATUS '100'.
  REFRESH : HU_COM, HU_TMP, HU_HU, HU_NEU.
  CLEAR   : CTR1, CTR2, CTR3, HUM_PROFILE_S, GTABIX.
  CLEAR   : ZPACK00, *ZPACK00, HUPAST_T, *HUPAST_T, MSKA, MARA, MAKT,
            VBAK, KNA1, T001W, *T001L, T001L, GS_CHARGDC.

  GB_IS_FREESTOCK = V_NO.

  CALL FUNCTION 'POC_GET_COMPUTER_NAME'
    IMPORTING
      EX_COMPUTER_NAME = GS_COMPUTER_NAME
    EXCEPTIONS
      GUI_ERROR        = 1
      OTHERS           = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF RB1 = V_YES.
    LOOP AT SCREEN .
      IF SCREEN-GROUP1 = 'RB2'.
        SCREEN-INVISIBLE = 1.
        SCREEN-INPUT     = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF RB2 = V_YES.
    LOOP AT SCREEN .
      IF SCREEN-GROUP1 = 'RB1'.
        SCREEN-INPUT     = 0.
        SCREEN-INVISIBLE = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " init_screen_100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  init_screen_200  OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_SCREEN_200 OUTPUT.
  PERFORM F_INIT_SCREEN_200.
ENDMODULE.                 " init_screen_200  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  read_hu_com  OUTPUT
*&---------------------------------------------------------------------*
MODULE READ_HU_COM OUTPUT.

  MAXLOOP = SY-LOOPC.
  POINTER = PAGEBEGIN + SY-STEPL.
  CLEAR VSELEK.
  DATA RHC_NCOUNT TYPE I.

  IF ZPACK00-CHARGDC(10) EQ '0000000000'.
    IF SY-SUBRC NE 0.
      CLEAR : HU_COM-INS0, HU_COM-INS1, HU_COM-INS2,
              HU_COM-INST, HU_COM-EXID, HU_COM-STAT, HU_COM-SELE.
    ENDIF.
    IF HU_COM-EXID NE SPACE AND HU_COM-TABIX NE 0.
      TABIX = HU_COM-TABIX.
      WA = HU_COM.
*     Check in insertion table
      READ TABLE HU_NEU WITH KEY EXID  = WA-EXID.
      IF SY-SUBRC = 0.
        CLEAR HU_COM-EXID.
        CLEAR ZPACK00-EXIDV.
        MESSAGE I000(0K) WITH '* Batch Nr. Already Exist and Deleted.'.
        DELETE HU_NEU WHERE TABIX = TABIX.
        DELETE HU_COM INDEX POINTER.
        TABIX = POINTER.
        READ TABLE HU_COM INDEX TABIX.
      ELSE.
*       Check in current itab
        READ TABLE HU_COM WITH KEY EXID  = WA-EXID
                                   TABIX = 0.
        IF SY-SUBRC = 0.
          CLEAR HU_COM-EXID.
          CLEAR ZPACK00-EXIDV.
          MESSAGE I000(0K) WITH '* Batch Nr. Already Exist and Deleted.'
          .
          DELETE HU_NEU WHERE TABIX = WA-TABIX.
          DELETE HU_COM WHERE TABIX = WA-TABIX.
          TABIX = POINTER.
          READ TABLE HU_COM INDEX TABIX.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  DESCRIBE TABLE HU_COM LINES RHC_NCOUNT.
  IF POINTER > RHC_NCOUNT.
    CLEAR:
      ZPACK00-ZINS01,
      ZPACK00-ZINS02,
      ZPACK00-ZINS03,
      ZPACK00-MATNR,
      ZPACK00-EXIDV,
      ZPACK00-STAT,
      VSELEK.

  ELSE.
    READ TABLE HU_COM INDEX POINTER.

    ZPACK00-ZINS01 = HU_COM-INS0.
    ZPACK00-ZINS02 = HU_COM-INS1.
    ZPACK00-ZINS03 = HU_COM-INS2.
    ZPACK00-MATNR  = HU_COM-INST.
    ZPACK00-EXIDV  = HU_COM-EXID.
    ZPACK00-STAT   = HU_COM-STAT.
    VSELEK         = HU_COM-SELE.
  ENDIF.

  SET CURSOR FIELD ZPACK00-CHARGDC.
  PERFORM MODIFY_SCREEN.
ENDMODULE.                 " read_hu_com  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  init_screen_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_SCREEN_120 OUTPUT.
  SET TITLEBAR '120'.
  SET PF-STATUS '100'.
  REFRESH : HU_COM, HU_TMP, HU_HU, HU_NEU.
  CLEAR   : CTR1, CTR2, CTR3, HUM_PROFILE_S, GTABIX.
  CLEAR   : ZPACK00, *ZPACK00, HUPAST_T, *HUPAST_T, MSKA, MARA, MAKT,
            VBAK, KNA1, T001W, *T001L, T001L, GWA_PCH.

  GB_IS_FREESTOCK = V_YES.

  IF RB1 = V_YES.
    LOOP AT SCREEN .
      IF SCREEN-GROUP1 = 'RB2'.
        SCREEN-INVISIBLE = 1.
        SCREEN-INPUT     = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF RB2 = V_YES.
    LOOP AT SCREEN .
      IF SCREEN-GROUP1 = 'RB1'.
        SCREEN-INPUT     = 0.
        SCREEN-INVISIBLE = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " init_screen_120  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0210 OUTPUT.
  IF GWA_HU_BOX IS INITIAL.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'GB_LABEL_BOX'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SET PF-STATUS ''.
  SET TITLEBAR '210'.

ENDMODULE.                 " STATUS_0210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0010 OUTPUT.
  SET PF-STATUS '010'.

  IF SY-TCODE = 'ZHU5FS'.
    SET TITLEBAR '010'.
  ELSEIF SY-TCODE = 'ZHU5SO'.
    SET TITLEBAR '020'.
  ENDIF.
ENDMODULE.                 " STATUS_0010  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  UNPACK_BUTTON  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE UNPACK_BUTTON OUTPUT.
DATA : V_ERRNO TYPE I.
CHECK RB2 = V_YES AND VCHARG NE ''.
 ZPACK00-CHARGDC = VCHARG.
 CLEAR : VCHARG.
 PERFORM F_CHECK_BATCH_MODEL.
 PERFORM F_CHECK_BATCH_SLOC CHANGING V_ERRNO.
 CHECK V_ERRNO EQ 0.

 CHECK SY-UCOMM EQ SPACE.
 PERFORM F_READ_BATCH.
ENDMODULE.                 " UNPACK_BUTTON  OUTPUT