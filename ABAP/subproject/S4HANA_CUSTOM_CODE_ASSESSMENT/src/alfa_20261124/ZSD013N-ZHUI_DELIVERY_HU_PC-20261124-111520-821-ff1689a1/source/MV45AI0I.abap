************************************************************************
*                                                                      *
* PAI Module Auftragsababwicklung                                      *
*     Module alphabetisch geordnet; hier mit "I" beginnend             *
*                                                                      *
************************************************************************

*&---------------------------------------------------------------------*
*&      Module  IVBAP_AENDERN_SELKZ INPUT
*&---------------------------------------------------------------------*
*       Selektionskennzeichen in IVBAP übernehmen
*----------------------------------------------------------------------*
MODULE IVBAP_AENDERN_SELKZ.

  PERFORM IVBAP_AENDERN(SAPFV45P).

ENDMODULE.

INCLUDE MV45AI0I_IDOC_INPUT_OPEN.

*eject

ENHANCEMENT-POINT MV45AI0I_01 SPOTS ES_SAPMV45A STATIC.