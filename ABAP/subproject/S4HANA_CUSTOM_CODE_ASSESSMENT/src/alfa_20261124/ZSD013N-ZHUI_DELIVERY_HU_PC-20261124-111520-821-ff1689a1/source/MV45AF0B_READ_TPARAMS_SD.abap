*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_READ_TPARAMS_SD
*&---------------------------------------------------------------------*

* MV45AF0B_BELEG_INITIALISIEREN

* INTTAB_ANALYZE
  IF T180-TRTYP NE CHARA.
*   Read table TPARAMS_SD
*   Set variable GV_INTTAB_ANALYZE in function group INTTAB_ANALYZE
    CALL FUNCTION 'SD_READ_TPARAMS_SD'
      EXPORTING
        I_PARKEY                 = 'XYTAB_ANA'
        I_PARNAME1               = 'SALES'
*       I_PARNAME2               =
*       I_PARNAME3               =
*       I_UNAME                  =
*     IMPORTING
*       E_PARVALUE1              =
*       E_PARVALUE2              =
      EXCEPTIONS
        INVALID_PARAMETERS       = 1
        NOT_FOUND                = 2
        OFF                      = 3
        OTHERS                   = 4
             .
    IF SY-SUBRC <> 0.
*     Implement suitable error handling here
    ENDIF.
  ENDIF.