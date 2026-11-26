*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_COPY_CONDITION_CHECK                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  COPY_CONDITION_CHECK
*&---------------------------------------------------------------------*
*       Die Kopierbedingung für Versandelemente wird geprüft
*----------------------------------------------------------------------*
FORM COPY_CONDITION_CHECK CHANGING CH_FOUND_COPY.

  TABLES TVCPL.

  DATA: DA_LFARN_INI LIKE TVCPL-LFARN,
        DA_PSTYV_INI LIKE TVCPL-PSTYV.

  IF TVAK-LFARV IS INITIAL.
    SELECT * FROM TVCPL WHERE LFARN NE DA_LFARN_INI AND
                              AUARV EQ VBAK-AUART AND
                              PSTYV EQ DA_PSTYV_INI.
      CHECK NOT TVCPL-GRUVS IS INITIAL.
      CH_FOUND_COPY = CHARX.
      EXIT.
    ENDSELECT.
  ELSE.
    SELECT SINGLE * FROM TVCPL WHERE LFARN EQ TVAK-LFARV AND
                                     AUARV EQ VBAK-AUART AND
                                     PSTYV EQ DA_PSTYV_INI.
    IF NOT TVCPL-GRUVS IS INITIAL.
      CH_FOUND_COPY = CHARX.
    ENDIF.
  ENDIF.

ENDFORM.                               " COPY_CONDITION_CHECK