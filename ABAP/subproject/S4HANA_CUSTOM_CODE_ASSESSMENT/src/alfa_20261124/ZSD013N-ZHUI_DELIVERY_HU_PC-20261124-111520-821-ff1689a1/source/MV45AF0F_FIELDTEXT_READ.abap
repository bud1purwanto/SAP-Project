*---------------------------------------------------------------------*
*       FORM FIELDTEXT_READ                                           *
*---------------------------------------------------------------------*
FORM FIELDTEXT_READ USING US_TBNAM
                          US_FDNAM
                 CHANGING CH_FDTXT.


  DATA: DA_DFIES_TAB LIKE DFIES.

  CALL FUNCTION 'RV_FIELD_READ'
       EXPORTING
            FDR_FIELD       = US_FDNAM
            FDR_LANGU       = SY-LANGU
            FDR_TABLE       = US_TBNAM
       IMPORTING
            FDR_DFIES       = DA_DFIES_TAB
       EXCEPTIONS
            FIELD_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC = 0.
    CH_FDTXT = DA_DFIES_TAB-SCRTEXT_L.
  ELSE.
    CONCATENATE US_TBNAM US_FDNAM
           INTO CH_FDTXT SEPARATED BY '-'.
  ENDIF.

ENDFORM.