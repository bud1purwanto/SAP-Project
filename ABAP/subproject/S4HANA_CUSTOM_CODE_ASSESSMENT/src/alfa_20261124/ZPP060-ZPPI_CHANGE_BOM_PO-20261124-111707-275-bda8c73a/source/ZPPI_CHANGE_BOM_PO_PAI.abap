*&---------------------------------------------------------------------*
*&  Include           ZPPI_CHANGE_BOM_PO_PAI
*&---------------------------------------------------------------------*

*&SPWIZARD: INPUT MODULE FOR TC 'TC1'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC1_MODIFY INPUT.
  MODIFY T_CEKLIST
    FROM W_CEKLIST
    INDEX TC1-CURRENT_LINE.

  DELETE T_CEKLIST WHERE MATNR_A = V_NO.
  CLEAR W_CEKLIST.
  APPEND W_CEKLIST TO T_CEKLIST.
ENDMODULE.                    "TC1_MODIFY INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC1'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC1_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC1'
                              'T_CEKLIST'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TC1_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE OK_CODE.
    WHEN '&DATA_SAVE'.
      PERFORM F_SAVE.
    WHEN '&EXPORT'.
      PERFORM F_EXPORT.
    WHEN '&IMPORT'.
      PERFORM F_IMPORT.
    WHEN 'PICK'.
      PERFORM F_ADD_FIELD.
    WHEN '&CLOSE'.
      LEAVE PROGRAM.
    WHEN 'ADD'.
      PERFORM INSERT_LINE.
    WHEN '&BACK' OR '&UP'.
      IF CODE = 'P'.
         T_CEKLIST[] = TA_ORI[].
         CLEAR : AUFNRID,CHARGID,TA_ORI,WA_ORI,CODE,WERKS,ERRNO,BKTXTID,MENGE,CHARG,
                 ZZCODE,ZZLINE,ZZLENGTH,ZZWIDTH,ZZCOATING_WEIGHT,COUNT_CLICK,T_CANCEL.
      ELSE.
        PERFORM RESET_ALL USING ''.
        SUBMIT  ZPPI_CHANGE_BOM_PO VIA SELECTION-SCREEN.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT