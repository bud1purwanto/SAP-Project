*&---------------------------------------------------------------------*
*&  Include           ZPPI_MASTER_U_INSPECTION_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE OK_CODE.
    WHEN 'EXECUTE'.
       IF RB2 EQ 'X'.
          SUBMIT ZPPC_UPLOAD_INSPECTIONSETUP
            VIA SELECTION-SCREEN
            AND RETURN.
       ELSEIF RB1 EQ 'X'.
          SUBMIT ZPPC_UPLOAD_QMVIEW
             VIA SELECTION-SCREEN
               AND RETURN.
       ENDIF.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0100  INPUT