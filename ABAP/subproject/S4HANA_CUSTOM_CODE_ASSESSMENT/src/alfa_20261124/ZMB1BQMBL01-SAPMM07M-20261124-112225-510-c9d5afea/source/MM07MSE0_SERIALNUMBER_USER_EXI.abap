*&---------------------------------------------------------------------*
*&      Form  SERIALNUMBER_USER_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM serialnumber_user_exit TABLES ti_mseg STRUCTURE mseg
                                   ti_ekbe STRUCTURE ekbe.

  CALL FUNCTION 'CALL_EXIT_SAPLIE01_007'
       TABLES
            s7_tab_mseg = ti_mseg
            s7_tab_ekbe = ti_ekbe.

ENDFORM.                               " SERIALNUMBER_USER_EXIT