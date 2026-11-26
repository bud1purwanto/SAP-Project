*eject
*---------------------------------------------------------------------*
*       FORM SUBSCREEN_4602                                           *
*---------------------------------------------------------------------*
*       Ermitteln Subscreen für Dynpro 4602 Lieferdaten Lieferpläne   *
*       mit Abrufen                                                   *
*---------------------------------------------------------------------*
FORM SUBSCREEN_4602.

  CASE VBAK-VBKLT.
    WHEN SPACE.
* VBKLT_LP_EDL gibt es erst ab 4.5A - deshalb hier noch Abfrage auf
* VBTTYP zwecks Kompatibilität
      IF VBAK-VBTYP EQ VBTYP_LP_EDL.
        DYNPRO_SUB = '4662'.
      ELSE.
        DYNPRO_SUB = '4661'.
      ENDIF.
    WHEN VBKLT_LP_EDL.
      DYNPRO_SUB = '4662'.
    WHEN VBKLT_LP_AUSL_AUFT.
      DYNPRO_SUB = '4663'.
    WHEN OTHERS.
*     Unknown VBKLT: set default dynpro
      IF VBAK-VBTYP EQ VBTYP_LP_EDL.
        DYNPRO_SUB = '4662'.
      ELSE.
        DYNPRO_SUB = '4661'.
      ENDIF.
  ENDCASE.

ENDFORM.