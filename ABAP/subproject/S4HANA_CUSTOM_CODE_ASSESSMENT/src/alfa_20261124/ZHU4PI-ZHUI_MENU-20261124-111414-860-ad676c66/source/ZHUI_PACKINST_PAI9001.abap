*&---------------------------------------------------------------------*
*&  Include           ZHUI_PACKINST_PAI9001
*&---------------------------------------------------------------------*

*&spwizard: input module for tc 'CTLTAB_PINS'. do not change this line!
*&spwizard: modify table
MODULE CTLTAB_PINS_MODIFY INPUT.
  MODIFY ITAB_PINS
    INDEX CTLTAB_PINS-CURRENT_LINE.

  IF SY-SUBRC EQ 4.
    APPEND ITAB_PINS TO ITAB_PINS.
  ENDIF.
ENDMODULE.                    "CTLTAB_PINS_modify INPUT

*&spwizard: input modul for tc 'CTLTAB_PINS'. do not change this line!
*&spwizard: mark table
MODULE CTLTAB_PINS_MARK INPUT.
  DATA: G_CTLTAB_PINS_WA2 LIKE LINE OF ITAB_PINS.
  IF CTLTAB_PINS-LINE_SEL_MODE = 1
  AND ITAB_PINS-SELE = 'X'.
    LOOP AT ITAB_PINS INTO G_CTLTAB_PINS_WA2
      WHERE SELE = 'X'.
      G_CTLTAB_PINS_WA2-SELE = ''.
      MODIFY ITAB_PINS
        FROM G_CTLTAB_PINS_WA2
        TRANSPORTING SELE.
    ENDLOOP.
  ENDIF.
  MODIFY ITAB_PINS
    INDEX CTLTAB_PINS-CURRENT_LINE
    TRANSPORTING SELE.
ENDMODULE.                    "CTLTAB_PINS_mark INPUT

*&spwizard: input module for tc 'CTLTAB_PINS'. do not change this line!
*&spwizard: process user command
MODULE CTLTAB_PINS_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'CTLTAB_PINS'
                              'ITAB_PINS'
                              'SELE'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "CTLTAB_PINS_user_command INPUT


*&---------------------------------------------------------------------*
*&      Module  OKCODE_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE OKCODE_9001 INPUT.
  PERFORM F_OKCODE_9001.
ENDMODULE.                 " OKCODE_9001  INPUT


*&---------------------------------------------------------------------*
*&      Module  check_matnr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MATNR INPUT.
  IF D_ISFREESTOCK = C_YES.
    REFRESH ITAB_MATERIAL.
    SELECT DISTINCT MARA~MATNR MARA~VHART MARA~MTART MEINS MAKTX MAGRV
      INTO TABLE ITAB_MATERIAL
      FROM MARA INNER JOIN MAKT ON MARA~MATNR = MAKT~MATNR
      WHERE MARA~MATNR = ZPACK_PCH-MATNR
        AND SPRAS = SY-LANGU.

    PERFORM F_CHECK_MATNR TABLES ITAB_MATERIAL.
  ENDIF.

ENDMODULE.                 " check_matnr  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_CRITERIA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CRITERIA INPUT.
 PERFORM F_CHECK_CRITERIA CHANGING ERRNO.
 IF ERRNO NE 0.
    RETURN.
 ENDIF.
ENDMODULE.                 " CHECK_CRITERIA  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_HELP_FOR_SLOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_HELP_FOR_SLOC INPUT.

  DATA LT_RETVAL TYPE DDSHRETVAL OCCURS 0 WITH HEADER LINE.
  DATA NCOUNT TYPE I.

  DATA:
    BEGIN OF ITAB_SELECTION OCCURS 0,
      WERKS TYPE T001L-WERKS,
      LGOR1 TYPE ZHU_MAPP-LGOR1,
      LGOBE TYPE T001L-LGOBE,
    END OF ITAB_SELECTION.

  SELECT T001L~WERKS AS WERKS ZHU_MAPP~LGOR1 AS LGOR1
         T001L~LGOBE AS LGOBE
  INTO TABLE ITAB_SELECTION
  FROM ZHU_MAPP
  JOIN T001L ON ZHU_MAPP~LGOR1 = T001L~LGORT
  AND  ZHU_MAPP~WERK1 = T001L~WERKS
  WHERE ZHU_MAPP~TYPES = '12'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'LGORT'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = ITAB_SELECTION
      RETURN_TAB      = LT_RETVAL
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDMODULE.                 " F4_HELP_FOR_SLOC  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_CRITERIA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CHECK_CRITERIA  CHANGING P_ERRNO.
  DATA : COUNT TYPE I,
         LGOR1 TYPE ZHU_MAPP-LGOR1.
  CLEAR : P_ERRNO.
  CHECK SY-TCODE = 'ZHU4FS'.
  COUNT = 0.

  IF ZPACK_PCH-ZZCRITERIABF = 'X'.
    COUNT = COUNT + 1.
  ENDIF.
  IF ZPACK_PCH-ZZCRITERIA1 = 'X'.
    COUNT = COUNT + 1.
  ENDIF.
  IF ZPACK_PCH-ZZCRITERIA2 = 'X'.
    COUNT = COUNT + 1.
  ENDIF.
  IF ZPACK_PCH-ZZCRITERIAR = 'X'.
    COUNT = COUNT + 1.
  ENDIF.

  IF COUNT > 1.
    MESSAGE W009.
    CLEAR : ZPACK_PCH-ZZCRITERIABF,
            ZPACK_PCH-ZZCRITERIA1,
            ZPACK_PCH-ZZCRITERIA2,
            ZPACK_PCH-ZZCRITERIAR.
  ELSEIF COUNT = 0.
    MESSAGE W002 WITH 'Kriteria harus diisi'.
    P_ERRNO = 1.
    RETURN.
  ENDIF.

** cek sloc
  CHECK ZPACK_PCH-LGORT NE ''.
  CLEAR : LGOR1.
  SELECT LGOR1 INTO LGOR1
    FROM ZHU_MAPP
    WHERE TYPES = '12'
    AND   WERK1 = ZPACK_PCH-WERKS
    AND   LGOR1 = ZPACK_PCH-LGORT
    AND   WERK2 = '9999'
    AND   LGOR2 = '9999'.
  ENDSELECT.
  IF LGOR1 NE ZPACK_PCH-LGORT.
    P_ERRNO = 1.
    MESSAGE W002 WITH 'Sloc tidak sesuai'.
    RETURN.
    CLEAR : ZPACK_PCH-LGORT.
  ENDIF.
ENDFORM.                    " F_CHECK_CRITERIA