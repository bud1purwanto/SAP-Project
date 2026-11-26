*eject
*---------------------------------------------------------------------*
*       FORM FCODE_PEXI                                               *
*---------------------------------------------------------------------*
*       Ablauf der Ausfuhrkontrolle im Simulationsfall                *
*       --> 'Protokoll'                                               *
*---------------------------------------------------------------------*
FORM FCODE_PEXI USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

  IF TVAK-EXCOK IS INITIAL.
    MESSAGE I652.
  ENDIF.
  PERFORM EXPORT_AUSFUHR USING CHARX.

  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.