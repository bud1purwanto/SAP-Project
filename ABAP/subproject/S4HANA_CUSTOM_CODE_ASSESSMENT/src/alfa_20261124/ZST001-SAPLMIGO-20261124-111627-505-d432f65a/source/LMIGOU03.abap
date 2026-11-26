FUNCTION migo_gr_create.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             REFERENCE(I_ACTION) TYPE  GOACTION DEFAULT 'A04'
*"             REFERENCE(I_REFDOC) TYPE  REFDOC DEFAULT 'R02'
*"             REFERENCE(I_NOTREE) TYPE  CHAR1 DEFAULT 'X'
*"             REFERENCE(I_NO_AUTH_CHECK) TYPE  CHAR1 OPTIONAL
*"             REFERENCE(I_SKIP_FIRST_SCREEN) TYPE  CHAR1 DEFAULT 'X'
*"             REFERENCE(I_DEADEND) TYPE  CHAR1 DEFAULT 'X'
*"             REFERENCE(I_OKCODE) TYPE  OKCODE DEFAULT 'OK_GO'
*"             REFERENCE(I_EBELN) TYPE  EBELN OPTIONAL
*"             REFERENCE(I_EBELP) TYPE  EBELP OPTIONAL
*"             REFERENCE(I_MBLNR) TYPE  MBLNR OPTIONAL
*"             REFERENCE(I_MJAHR) TYPE  MJAHR OPTIONAL
*"----------------------------------------------------------------------

* Function module for naming compatibility. Please use
* MIGO_DIALOG instead.

  CALL FUNCTION 'MIGO_DIALOG'
    EXPORTING
      i_action            = i_action
      i_refdoc            = i_refdoc
      i_notree            = i_notree
      i_no_auth_check     = i_no_auth_check
      i_skip_first_screen = i_skip_first_screen
      i_deadend           = i_deadend
      i_okcode            = i_okcode
      i_ebeln             = i_ebeln
      i_ebelp             = i_ebelp
      i_mblnr             = i_mblnr
      i_mjahr             = i_mjahr.

ENDFUNCTION.