FUNCTION /spe/expimp_set_xeikp.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_SPE_FLAG) TYPE  FLAG OPTIONAL
*"  TABLES
*"      T_EIKP STRUCTURE  EIKP OPTIONAL
*"----------------------------------------------------------------------

  IF iv_spe_flag IS INITIAL.                                "n_1406138
    CALL FUNCTION 'EXPIMP_TABLES_IMPORT'.
  ENDIF.                                                    "n_1406138

  LOOP AT xeikp.
    MOVE-CORRESPONDING xeikp TO t_eikp.
    APPEND t_eikp.
  ENDLOOP.

ENDFUNCTION.