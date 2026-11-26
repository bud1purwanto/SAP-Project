*---------------------------------------------------------------------*
*       MODULE TKNUM_HILFE                                            *
*---------------------------------------------------------------------*
MODULE TKNUM_HILFE.

  CALL FUNCTION 'SD_F4_EXTENDED'
       EXPORTING
            MODE   = 'HELP'
       EXCEPTIONS
            OTHERS = 0.

  GET PARAMETER ID 'TNR' FIELD RM07M-TKNUM.

ENDMODULE.                             " TKNUM_HILFE  INPUT