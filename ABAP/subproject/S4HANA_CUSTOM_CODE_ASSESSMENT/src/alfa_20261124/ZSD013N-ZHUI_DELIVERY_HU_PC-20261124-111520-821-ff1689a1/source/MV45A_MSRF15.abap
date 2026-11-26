*----------------------------------------------------------------------*
***INCLUDE MV45A_MSRF15 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F4_PAYING_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_paying_plant.

  GET CURSOR FIELD help_f LINE help_tabix.
  IF help_tabix > 0.
    READ TABLE svbap INDEX help_tabix.
    IF sy-subrc = 0.
      READ TABLE xvbap INDEX svbap-tabix.
      help_vbap = xvbap.
    ENDIF.
  ELSE.
    help_vbap = vbap.
  ENDIF.

  da_trtyp = t185f-trtyp.

*    DATA: DYNPRO_PROGRAM  LIKE SY-REPID. "Programmpool und Nummer in dem
*    DATA: DYNPRO_NUMBER   LIKE SY-DYNNR. "das aktuelle Dynpro liegt.

  dynpro_program  = sy-repid.          "believe it or not - these
  dynpro_number   = sy-dynnr.          "assignments are necessary!

* zu lesende Feld vormerken.
  REFRESH dynpfields.
  MOVE 'MSR_S_SALES_ITEM-PAYING_PLANT' TO dynpfields-fieldname.
  APPEND dynpfields.

* Feldinhalte explizit auslesen
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname                   = dynpro_program
      dynumb                   = dynpro_number
      perform_input_conversion = 'X'
    TABLES
      dynpfields               = dynpfields
    EXCEPTIONS
      invalid_abapworkarea     = 1
      invalid_dynprofield      = 2
      invalid_dynproname       = 3
      invalid_dynpronummer     = 4
      invalid_request          = 5
      no_fielddescription      = 6
      invalid_parameter        = 7
      undefind_error           = 8
      OTHERS                   = 9.

  READ TABLE dynpfields WITH KEY fieldname = 'MSR_S_SALES_ITEM-PAYING_PLANT'.
  IF dynpfields-fieldinp IS INITIAL.
    da_trtyp = chara.
  ENDIF.

  CALL FUNCTION 'RV_HELP'
    EXPORTING
*     KEY            = HELP_VBAP-MATNR
      key            = msr_s_sales_item-replace_matnr
      key2           = vbak-vkorg
      key3           = tvta-vtwku
      number         = '010'
      trtyp          = da_trtyp
      field_in       = msr_s_sales_item-paying_plant
      description_in = tvapt-vtext
    IMPORTING
      field          = msr_s_sales_item-paying_plant
      description    = t001w-name1.

ENDFORM.                    " F4_PAYING_PLANT

*&---------------------------------------------------------------------*
*&      Form  f4_next_plant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f4_next_plant.

  GET CURSOR FIELD help_f LINE help_tabix.
  IF help_tabix > 0.
    READ TABLE svbap INDEX help_tabix.
    IF sy-subrc = 0.
      READ TABLE xvbap INDEX svbap-tabix.
      help_vbap = xvbap.
    ENDIF.
  ELSE.
    help_vbap = vbap.
  ENDIF.

  da_trtyp = t185f-trtyp.

*    DATA: DYNPRO_PROGRAM  LIKE SY-REPID. "Programmpool und Nummer in dem
*    DATA: DYNPRO_NUMBER   LIKE SY-DYNNR. "das aktuelle Dynpro liegt.

  dynpro_program  = sy-repid.          "believe it or not - these
  dynpro_number   = sy-dynnr.          "assignments are necessary!

* zu lesende Feld vormerken.
  REFRESH dynpfields.
  MOVE 'GS_MSR_SALES_ITEM-NEXT_PLANT' TO dynpfields-fieldname.
  APPEND dynpfields.

* Feldinhalte explizit auslesen
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname                   = dynpro_program
      dynumb                   = dynpro_number
      perform_input_conversion = 'X'
    TABLES
      dynpfields               = dynpfields
    EXCEPTIONS
      invalid_abapworkarea     = 1
      invalid_dynprofield      = 2
      invalid_dynproname       = 3
      invalid_dynpronummer     = 4
      invalid_request          = 5
      no_fielddescription      = 6
      invalid_parameter        = 7
      undefind_error           = 8
      OTHERS                   = 9.

  READ TABLE dynpfields WITH KEY fieldname = 'GS_MSR_SALES_ITEM-NEXT_PLANT'.
  IF dynpfields-fieldinp IS INITIAL.
    da_trtyp = chara.
  ENDIF.

  CALL FUNCTION 'RV_HELP'
    EXPORTING
*     KEY            = HELP_VBAP-MATNR
      key            = vbap-matnr
      key2           = vbak-vkorg
      key3           = tvta-vtwku
      number         = '010'
      trtyp          = da_trtyp
      field_in       = GS_MSR_SALES_ITEM-NEXT_PLANT
      description_in = tvapt-vtext
    IMPORTING
      field          = GS_MSR_SALES_ITEM-NEXT_PLANT
      description    = t001w-name1.

ENDFORM.                    " F4_PAYING_PLANT