*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FVBAK_ABHOD_SETZEN                                *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FVBAK_ABHOD_SETZEN_VBAK
*&---------------------------------------------------------------------*
*       Wenn das Abholdatum nach dem Kopieren der ersten Position
*       bereits sitzt, wird es in die Funktionsgruppe V45C übergeben
*       damit in diesem Fall auf dem Kopierpopup die Eingabefelder für
*       das Abholfenster über die Feldauswahl auf nicht mehr
*       eingabebereit geschaltet werden können
*----------------------------------------------------------------------*
FORM FVBAK_ABHOD_SETZEN_VBAK.

  CHECK VBAK-VBKLT EQ VBKLT_AUSL_AUFT.
  CALL FUNCTION 'SD_SET_FVBAK_ABHOD'
       EXPORTING
            FVBAK_ABHOD = VBAK-ABHOD
            FVBAK_ABHOV = VBAK-ABHOV
            FVBAK_ABHOB = VBAK-ABHOB
       EXCEPTIONS
            OTHERS      = 1.

ENDFORM.                               " FVBAK_ABHOD_SETZEN_VBAK