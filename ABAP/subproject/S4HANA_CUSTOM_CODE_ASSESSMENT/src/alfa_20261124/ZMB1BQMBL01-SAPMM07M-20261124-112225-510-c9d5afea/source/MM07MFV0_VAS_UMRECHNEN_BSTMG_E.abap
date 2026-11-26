*&---------------------------------------------------------------------*
*&      Form  VAS_UMRECHNEN_BSTMG_ERFMG
*&---------------------------------------------------------------------*
*       text: convert qty in order uom to qty in entry uom
*----------------------------------------------------------------------*
FORM VAS_UMRECHNEN_BSTMG_ERFMG.

* use qty in order uom and get qty in base uom
  perform VAS_BASISME_UMRECHNEN using vas_mseg-bstmg
                                      vas_mseg-bstme
                                      xebefu-umren
                                      xebefu-umrez.

  if sy-subrc is initial.
* use base uom and get entry uom
    CALL FUNCTION 'MB_UNIT_CONVERSION'
         EXPORTING
              matnr                = vas_mseg-matnr
              meins                = vas_mseg-meins
              erfme                = vas_mseg-erfme
              menge                = vas_mseg-menge
              erfmg                = vas_mseg-erfmg
         IMPORTING
              o_menge              = vas_mseg-menge
              o_erfmg              = vas_mseg-erfmg
         EXCEPTIONS
              conversion_not_found = 4.

  endif.

ENDFORM.                     "VAS_UMRECHNEN_BSTMG_ERFMG