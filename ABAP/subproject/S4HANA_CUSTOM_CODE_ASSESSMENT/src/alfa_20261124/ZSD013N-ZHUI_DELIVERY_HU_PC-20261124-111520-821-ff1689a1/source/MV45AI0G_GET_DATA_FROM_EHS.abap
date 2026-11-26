*&---------------------------------------------------------------------*
*&  Include           MV45AI0G_GET_DATA_FROM_EHS                       *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  get_data_from_ehs  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_DATA_FROM_EHS INPUT.

  CALL FUNCTION 'EHS003_GET_DATA_EHS'
    IMPORTING
      E_TC_SELLINE = TC_SELLINE
    TABLES
      E_XVBUVTAB   = XVBUV
      E_DVBUVTAB   = DVBUV
      E_HVBUVTAB   = HVBUV
    CHANGING
      X_DATALOSS   = R185D-DATALOSS
    EXCEPTIONS
      OTHERS_      = 1.

*delete entries from ivbap
  LOOP AT IVBAP.
    CLEAR IVBAP-SELKZ.
    MODIFY IVBAP.
  ENDLOOP.

ENDMODULE.                 " get_data_from_ehs  INPUT