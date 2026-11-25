*&---------------------------------------------------------------------*
*& Report  ZVA_YOURREF
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZBADI_ADD_TAB_SO.

TYPES: BEGIN OF T_TAB,
         VBELN TYPE VBAP-VBELN,            "SO Number
         POSNR TYPE VBAP-POSNR,            "SO Item
         ZDATE TYPE VBAP-ZDATE,
         ZLINE TYPE VBAP-ZLINE,
         END OF T_TAB.

DATA: ITAB TYPE STANDARD TABLE OF T_TAB.
DATA: WA_TAB LIKE LINE OF ITAB.

DATA: ZDATE TYPE VBAP-ZDATE,
      ZLINE TYPE VBAP-ZLINE,
      ZGRUP TYPE ZMAPPG-GRPPRD3,
      ZSBU  TYPE ZMAPPG-SBU,
      ZSO   TYPE VBAP-VBELN,
      ZITEM TYPE VBAP-POSNR,
      ZMATKL TYPE T025T-BKBEZ.

SET PARAMETER ID 'ZDATE'  FIELD SPACE.
SET PARAMETER ID 'ZLINE'  FIELD SPACE.
SET PARAMETER ID 'ZGRUP'  FIELD SPACE.
SET PARAMETER ID 'ZSBU'   FIELD SPACE.
SET PARAMETER ID 'ZMATKL' FIELD SPACE.
SET PARAMETER ID 'ZSO'    FIELD SPACE.
SET PARAMETER ID 'ZITEM'  FIELD SPACE.

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO OUTPUT.
  IF SY-TCODE EQ 'VA03'.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'ZDATE'.
        SCREEN-INPUT = '0'.
        MODIFY SCREEN.
        CLEAR SCREEN.
      ELSEIF SCREEN-NAME = 'ZLINE'.
        SCREEN-INPUT = '0'.
        MODIFY SCREEN.
        CLEAR SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  GET PARAMETER ID 'ZDATE' FIELD ZDATE.
  GET PARAMETER ID 'ZLINE' FIELD ZLINE.
  GET PARAMETER ID 'ZGRUP' FIELD ZGRUP.
  GET PARAMETER ID 'ZSBU'  FIELD ZSBU.
  GET PARAMETER ID 'ZSO'   FIELD ZSO.
  GET PARAMETER ID 'ZITEM' FIELD ZITEM.
  GET PARAMETER ID 'ZMATKL' FIELD ZMATKL.

  IF ZLINE IS NOT INITIAL.
    SELECT SINGLE ZPROD1 INTO ZMATKL FROM ZMAP_LINEBR WHERE ZLINE = ZLINE.
    IF SY-SUBRC EQ 0.
      SET PARAMETER ID 'ZMATKL' FIELD ZMATKL.
    ENDIF.
  ELSE.
    SET PARAMETER ID 'ZMATKL' FIELD SPACE.
    CLEAR ZMATKL.
  ENDIF.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI INPUT.
  SET PARAMETER ID 'ZDATE' FIELD ZDATE.
  SET PARAMETER ID 'ZLINE' FIELD ZLINE.
  SET PARAMETER ID 'ZGRUP' FIELD ZGRUP.
  SET PARAMETER ID 'ZSBU'  FIELD ZSBU.
  SET PARAMETER ID 'ZSO'   FIELD ZSO.
  SET PARAMETER ID 'ZITEM' FIELD ZITEM.
  SET PARAMETER ID 'ZMATKL' FIELD ZMATKL.

  IMPORT ITAB TO ITAB FROM MEMORY ID 'ZBADI_ADD_TAB_SO'.
  READ TABLE ITAB INTO WA_TAB WITH KEY VBELN = ZSO POSNR = ZITEM.
  IF SY-SUBRC EQ 0.
    WA_TAB-ZDATE = ZDATE.
    WA_TAB-ZLINE = ZLINE.
    MODIFY ITAB FROM WA_TAB TRANSPORTING ZDATE ZLINE WHERE VBELN = ZSO AND POSNR = ZITEM.
  ELSE.
    WA_TAB-VBELN = ZSO.
    WA_TAB-POSNR = ZITEM.
    WA_TAB-ZDATE = ZDATE.
    WA_TAB-ZLINE = ZLINE.
    APPEND WA_TAB TO ITAB.
  ENDIF.
  EXPORT ITAB FROM ITAB TO MEMORY ID 'ZBADI_ADD_TAB_SO'.
ENDMODULE.                 " PAI  INPUT

*----------------------------------------------------------------------*
*  MODULE F4_ZLINE INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE F4_ZLINE INPUT.
  DATA: LT_RETVAL  TYPE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
        V_PRODLINE LIKE CABN-ATINN.
  DATA: BEGIN OF T_LINE OCCURS 0,
        ATWRT TYPE CAWN-ATWRT,
        ATWTB TYPE CAWNT-ATWTB,
        END OF T_LINE.

  SELECT SINGLE ATINN INTO V_PRODLINE FROM CABN WHERE ATNAM = 'ZZPRODLINE'.
  SELECT ATWRT ATWTB INTO CORRESPONDING FIELDS OF TABLE T_LINE
    FROM CAWN
    JOIN CAWNT
      ON CAWN~ATINN EQ CAWNT~ATINN
     AND CAWN~ATZHL EQ CAWNT~ATZHL
   WHERE CAWN~ATINN EQ V_PRODLINE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ATWRT'
      WINDOW_TITLE    = 'Production Line Help List'
      VALUE_ORG       = 'S'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZLINE'
    TABLES
      VALUE_TAB       = T_LINE
      RETURN_TAB      = LT_RETVAL
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

ENDMODULE.                    "F4_ZLINE INPUT
