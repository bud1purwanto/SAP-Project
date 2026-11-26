*&---------------------------------------------------------------------*
*&  Include           MV45AO0S_SET_DATA_EHS                            *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  SET_DATA_TO_EHS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_DATA_TO_EHS OUTPUT.

  CALL FUNCTION 'EHS003_SET_DATA_SD'
    EXPORTING
      I_VBAK_VBTYP = VBAK-VBTYP
      I_TVAK_FEHGR = TVAK-FEHGR
      I_TRTYP      = T180-TRTYP
      I_FEHLER     = FEHLER
      I_FEHLERFELD = FEHLERFELD
      I_TC_SELLINE = TC_SELLINE
      I_POSNR      = XVBAP-POSNR
    TABLES
      I_XVBUVTAB   = XVBUV
      I_DVBUVTAB   = DVBUV
      I_HVBUVTAB   = HVBUV
    EXCEPTIONS
      OTHERS_      = 1.

ENDMODULE.                 " SET_DATA_TO_EHS  OUTPUT