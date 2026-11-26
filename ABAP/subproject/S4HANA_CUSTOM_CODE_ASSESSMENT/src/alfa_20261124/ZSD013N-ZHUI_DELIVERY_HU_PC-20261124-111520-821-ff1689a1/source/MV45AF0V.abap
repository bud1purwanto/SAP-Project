***********************************************************************
*  Unterroutinen RV-Auftragsabwicklung alphabetisch sortiert:         *
*  ----------------------------------------------------------         *
*  Buchstabe V:                                                       *
*                                                                     *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM VBELN_UEBERNEHMEN                                        *
*---------------------------------------------------------------------*
*       Bei Eingabe der externen Belegnummer wird diese in            *
*       einige Tabellen übernommen, damit das Lesen mit binary search *
*       noch funktioniert                                             *
*---------------------------------------------------------------------*

  include mv45af0v_vbap_init.
  INCLUDE MV45AF0V_VBAP_MATNR_VALUES .
  INCLUDE MV45AF0V_VBAP_MATNR_GET_F4HELP .
  INCLUDE MV45AF0V_VBELN_UEBERNEHMEN .
  INCLUDE MV45AF0V_VBELN_IN_PARTNER .
  INCLUDE MV45AF0V_VBEX_LESEN .
  INCLUDE MV45AF0V_VBAPD_KORDT_PRUEFEN .
  INCLUDE MV45AF0V_VBAP-TAXMX_VALUES .
  INCLUDE MV45AF0V_VBAP-TAXKX_VALUES .
  INCLUDE MV45AF0V_VBKD_WMINR_PRUEFEN .
  INCLUDE MV45AF0V_VBMUE_HAT_EINTRAG .
  INCLUDE MV45AF0V_VEDA_DATUM_PRUEFEN .
  INCLUDE MV45AF0V_VEDA_CHECK_ITEM_COMPL .
  INCLUDE MV45AF0V_VTBER_BESTIMMEN .
  INCLUDE MV45AF0V_VTBER_ERFORDERLICH .