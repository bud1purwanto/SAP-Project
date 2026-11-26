*&---------------------------------------------------------------------*
*&      Form  VAS_BASISME_UMRECHNEN
*&---------------------------------------------------------------------*
*       text: get base unit of measure of the subitem and convert      *
*             erfmg  to base uom                                       *
*----------------------------------------------------------------------*
FORM VAS_BASISME_UMRECHNEN using p_vas_mseg_qty
                                 p_vas_mseg_uom
                                 p_umren
                                 p_umrez.

  data rc type c value x.

  if vas_mara-matnr = vas_mseg-matnr.
* matnr hasn't changed -> just take over meins
    move vas_mara-meins to vas_mseg-meins.
    clear rc.
  else.
* read new material masters entry
    CALL FUNCTION 'MARA_SINGLE_READ'
         EXPORTING
              MATNR             = vas_mseg-matnr
         IMPORTING
              WMARA             = vas_mara
         EXCEPTIONS
              LOCK_ON_MATERIAL  = 1
              LOCK_SYSTEM_ERROR = 2
              WRONG_CALL        = 3
              NOT_FOUND         = 4
              OTHERS            = 5.
    if sy-subrc is initial.
      move vas_mara-meins to vas_mseg-meins.
      clear rc.
    endif.
  endif.
  if rc is initial.
* convert qty to basis uom
    CALL FUNCTION 'MB_UNIT_CONVERSION'
         EXPORTING
              matnr                = vas_mseg-matnr
              meins                = vas_mseg-meins
              erfme                = p_vas_mseg_uom
              menge                = vas_mseg-menge
              erfmg                = p_vas_mseg_qty
              umren                = p_umren
              umrez                = p_umrez
         IMPORTING
              o_menge              = vas_mseg-menge
              o_erfmg              = p_vas_mseg_qty
         EXCEPTIONS
              conversion_not_found = 4.
  endif.

ENDFORM.                    " VAS_BASISME_UMRECHNEN