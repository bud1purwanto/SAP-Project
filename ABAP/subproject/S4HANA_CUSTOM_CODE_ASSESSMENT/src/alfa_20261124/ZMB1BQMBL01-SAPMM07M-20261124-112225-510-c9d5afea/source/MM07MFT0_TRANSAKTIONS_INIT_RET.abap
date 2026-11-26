*eject
*&---------------------------------------------------------------------*
*&      Form  transaktions_init_retail
*&---------------------------------------------------------------------*
*       text  initializing of retail data
*----------------------------------------------------------------------*
FORM TRANSAKTIONS_INIT_RETAIL.

* full product table
  CLEAR VGMSEG.
  REFRESH VGMSEG.
* value added service: tables for subitems
  CLEAR: VAS_MSEG, VAS_MSEG_EINGEMISCHT, VAS_EKBE.
  REFRESH: VAS_MSEG, VAS_MSEG_EINGEMISCHT, VAS_EKBE.
* already processed cross docking positions
  CLEAR CD_MSEG_EINGEMISCHT.
  REFRESH CD_MSEG_EINGEMISCHT.
  CLEAR: CD_EBELN, CD_EBELP.             "note 725182
* switches
  CLEAR: CD_VORGANG_AKTIV, VAS_VORGANG_AKTIV.
* structures vas
  CLEAR VAS_MARA.

ENDFORM.                               " transaktions_init_retail