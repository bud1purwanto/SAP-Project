*----------------------------------------------------------------------*
*          Serialnummernpflicht ermitteln                              *
*----------------------------------------------------------------------*
FORM serialpflicht_ermitteln.
* *--------- Start of note 1031590 -----------*
* Take over serial numbers from IM into global table "n1031590
* for HUM and read the serial number profile
  DATA: L_SERNP TYPE SERAIL.
  IF NOT DM07M-SERNP IS INITIAL.
    L_SERNP = DM07M-SERNP.
  ELSE.
    L_SERNP = ZDM07M-SERNP.
  ENDIF.
    CALL FUNCTION 'SERIAL_PROFILE_READ'
         EXPORTING
              profile_r     = L_SERNP
            operation_r   = op_mmsl
            snbwg_r       = s156s-snbwg
            pflege        = 'X'
       IMPORTING
            t_377         = i_t377
       EXCEPTIONS
            no_t377_entry = 2
            OTHERS        = 3.
  IF sy-subrc = 2.
    CLEAR i_t377.
  ENDIF.
* *----------- End of note 1031590 -----------*
ENDFORM.