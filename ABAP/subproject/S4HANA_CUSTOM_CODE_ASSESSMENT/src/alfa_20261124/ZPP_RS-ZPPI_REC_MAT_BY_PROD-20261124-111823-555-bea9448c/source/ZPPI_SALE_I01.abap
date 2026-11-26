*&---------------------------------------------------------------------*
*&  Include           ZPPI_SALE_I01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_3000 INPUT.
  IF ZWERKS EQ '1000'.
    ZVSTEL = '1000'.
    ZLGORT = '1700'.
  ELSEIF ZWERKS EQ '2000'.
    ZVSTEL = '2000'.
    ZLGORT = '2700'.
  ELSEIF ZWERKS EQ '3000'.
    MESSAGE 'Delivery scrap can only be done from plant 1000 or 2000.' TYPE 'I'.
    EXIT.
  ELSE.
    ZVSTEL = ''.
  ENDIF.

  CLEAR :ZNAME1.
  SELECT SINGLE KNA1~NAME1
    INTO ZNAME1
    FROM KNA1
    WHERE KNA1~KUNNR = KNA1-KUNNR.

  CLEAR : V_NIK.
  SELECT SINGLE PA0001~PERNR
    INTO V_NIK
    FROM PA0001
    WHERE PA0001~PERNR = ZNIK.

  IF SY-SUBRC <> 0.
    MESSAGE 'Wrong NIK.' TYPE 'E'.
    EXIT.
  ENDIF.

  CASE SY-UCOMM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXECUTE'.
      PERFORM UPLOAD_DATA.
      IF V_DELIVERY NE ''.
        PERFORM CHANGE_DATA.
        CLEAR : V_KOSTK.
        SELECT SINGLE VBUK~KOSTK
          INTO V_KOSTK
          FROM VBUK
          WHERE VBUK~VBELN = V_DELIVERY.
      ENDIF.
      PERFORM SAVE_DATA.
      IF V_DELIVERY NE ''.
        SET PARAMETER ID 'VL' FIELD V_DELIVERY.
        CALL TRANSACTION 'ZVL02NOG' AND SKIP FIRST SCREEN.
      ELSE.
        MESSAGE 'ODO can not created.' TYPE 'I'.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_3000  INPUT


*&---------------------------------------------------------------------*
*&      Module  EX_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EX_3000 INPUT.

  LEAVE PROGRAM.

ENDMODULE.                 " EX_3000  INPUT