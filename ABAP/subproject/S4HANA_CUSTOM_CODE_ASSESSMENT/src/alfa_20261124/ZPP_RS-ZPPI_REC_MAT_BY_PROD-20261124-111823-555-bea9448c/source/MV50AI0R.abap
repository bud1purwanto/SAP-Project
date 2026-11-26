************************************************************************
*                                                                      *
* PAI Module Versand                                                   *
*     Module alphabetisch geordnet; hier mit "R" beginnend             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       Eingabeprüfung: Sparte                                        *
*---------------------------------------------------------------------*
MODULE RV50A-SPART_PRUEFEN.

  CHECK FCODE(4) NE FCODE_ABBRECHEN    "46A BEY
    AND FCODE(4) NE FCODE_ENDE.

  IF   RV50A-SPART IS INITIAL
    OR RV50A-SPART = '?'.
    SET CURSOR FIELD RV50A-SPART.
    MESSAGE E092.
  ELSE.
    PERFORM TSPA_SELECT USING RV50A-SPART
                        SPACE
                        SY-SUBRC.
  ENDIF.

ENDMODULE.
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Vertriebsweg                                  *
*---------------------------------------------------------------------*
MODULE RV50A-VTWEG_PRUEFEN.

  CHECK FCODE(4) NE FCODE_ABBRECHEN    "46A BEY
    AND FCODE(4) NE FCODE_ENDE.

  IF RV50A-VTWEG IS INITIAL
    OR RV50A-VTWEG = '?'.
    SET CURSOR FIELD RV50A-VTWEG.
    MESSAGE E091.
  ELSE.
    PERFORM TVTW_SELECT USING RV50A-VTWEG
                        CHARX
                        SY-SUBRC.
  ENDIF.

ENDMODULE.
*eject

*&---------------------------------------------------------------------*
*&      Module  REFERENCE_OUTB_PROCESS  INPUT
*&---------------------------------------------------------------------*
MODULE REFERENCE_OUTB_PROCESS INPUT.

  PERFORM REFERENCE_OUTB_PROCESS.

ENDMODULE.                             " REFERENCE_OUTB_PROCESS  INPUT

*&---------------------------------------------------------------------*
*&      Module  REFERENCE_INB_PROCESS  INPUT
*&---------------------------------------------------------------------*
MODULE REFERENCE_INB_PROCESS INPUT.

  PERFORM REFERENCE_INB_PROCESS.

ENDMODULE.                             " REFERENCE_INB_PROCESS  INPUT
*&---------------------------------------------------------------------*
*&      Module  RESCHEDULE_EXECUTE  INPUT
*&---------------------------------------------------------------------*
*       If rescheduling is planned by the system it is executed now
*----------------------------------------------------------------------*
MODULE RESCHEDULE_EXECUTE INPUT.

  PERFORM RESCHEDULE_EXECUTE.

ENDMODULE.                             " RESCHEDULE_EXECUTE  INPUT

ENHANCEMENT-POINT MV50AI0R_01 SPOTS ES_SAPMV50A STATIC .