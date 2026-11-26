***INCLUDE MV45AF0K_KVBKD_PUT_DATA .
*---------------------------------------------------------------------*
*       FORM KVBKD_PUT_DATA                                           *
*---------------------------------------------------------------------*
*       store old header business data for later comparison           *
*---------------------------------------------------------------------*
FORM KVBKD_PUT_DATA.

  LOCAL: XVBKD,
         SVBKD-TABIX.

  PERFORM XVBKD_KOPF_LESEN(SAPFV45K).

  CHECK NOT SVBKD-TABIX IS INITIAL.

  CALL FUNCTION 'SD_KVBKD_PUT_DATA'
       EXPORTING
            I_KVBKD = XVBKD.

ENDFORM.