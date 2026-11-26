************************************************************************
*                                                                      *
* PAI Module Auftragsababwicklung                                      *
*     Module alphabetisch geordnet; hier mit "S" beginnend             *
*                                                                      *
************************************************************************

  INCLUDE MV45AI0S_CALL_DIALOG_IMPORT .
  INCLUDE MV45AI0S_SELEKTION_PRUEFEN_ZUL .
*---------------------------------------------------------------------*
*  MODULE set_fcode_eiba INPUT
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
  MODULE SET_FCODE_EIBA INPUT.
    FCODE = FCODE_BESTELLANFORDERUNG.
  ENDMODULE.                    "set_fcode_eiba INPUT
  INCLUDE MV45AI0S_SET_FCODE_FROM_EHS.
  INCLUDE MV45AI0S_SET_FCODE_IHKZ .
  INCLUDE MV45AI0S_SET_FCODE_KSTC .
  INCLUDE MV45AI0S_SET_FCODE_PSTC .
  INCLUDE MV45AI0S_SET_FCODE_SDUE .
  INCLUDE MV45AI0S_STATUS_AENDERN .
  INCLUDE MV45AI0S_SHIPMENT_INFO_CHECK .
  INCLUDE MV45AI0S_SHIPMENT_VSART_CHECK.
*---------------------------------------------------------------------*
*       MODULE STATUS_BESCHAFFUNG INPUT                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
  MODULE STATUS_BESCHAFFUNG INPUT.
    IF SY-DYNGR EQ 'KOPF'.
      PERFORM STATUS_BESCHAFFUNG(SAPFV45E) USING VBAK-OBJNR.
    ELSEIF SY-DYNGR EQ 'POSI'.
      PERFORM STATUS_BESCHAFFUNG(SAPFV45E) USING VBAP-OBJNR.
    ENDIF.
  ENDMODULE.                    "STATUS_BESCHAFFUNG INPUT