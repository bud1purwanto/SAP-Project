*---------------------------------------------------------------------*
*       FORM VBFA_SELECT                                              *
*---------------------------------------------------------------------*
*       Belegfluß Auftrag lesen                                       *
*---------------------------------------------------------------------*
FORM VBFA_SELECT USING VALUE(VS_MANDT)
                       VALUE(VS_VBELV).

  IF BUFFERREAD_FLAG-TABLE_VBFA IS INITIAL.
    SELECT * FROM VBFA
           INTO TABLE XVBFA
           WHERE VBELV EQ VBAK-VBELN
           ORDER BY PRIMARY KEY.
  ELSE.
    CALL FUNCTION 'SD_VBFA_READ_WITH_VBELV'
         EXPORTING
              I_VBELV            = VBAK-VBELN
              I_BYPASSING_BUFFER = CHARB
         TABLES
              ET_VBFAVB          = XVBFA
         EXCEPTIONS
              RECORD_NOT_FOUND   = 1
              OTHERS             = 2.
  ENDIF.

ENDFORM.