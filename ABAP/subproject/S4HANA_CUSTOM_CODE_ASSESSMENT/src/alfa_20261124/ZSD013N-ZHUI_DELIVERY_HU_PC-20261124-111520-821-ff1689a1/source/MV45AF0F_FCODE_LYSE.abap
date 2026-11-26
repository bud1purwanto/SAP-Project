*---------------------------------------------------------------------*
*       FORM FCODE_LYSE                                               *
*---------------------------------------------------------------------*
*       Report Analyse Lieferabruf                                    *
*---------------------------------------------------------------------*
FORM FCODE_LYSE USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

  DATA: DA_ABART_LINKS  LIKE VBLB-ABART,
        DA_ABART_RECHTS LIKE VBLB-ABART.

  IF VBLB-ABART EQ ABART_PAB.
    DA_ABART_LINKS  = ABART_LAB.
    DA_ABART_RECHTS = ABART_PAB.
  ELSE.
    DA_ABART_LINKS  = ABART_LAB.
    DA_ABART_RECHTS = ABART_FAB.
  ENDIF.

 CALL FUNCTION 'SD_ANALYSE_DELIVERIES'
       EXPORTING
            I_KUWEV        = KUWEV
            I_VBAP         = VBAP
            I_VBAK         = VBAK
            I_KUAGV        = KUAGV
            I_ABART_LINKS  = DA_ABART_LINKS
            I_ABART_RECHTS = DA_ABART_RECHTS
       TABLES
            FXVBEH         = XVBEH
            FXVBEP         = XVBEP.

  H185  = T185.
  H185F = T185F.
  H185V = T185V.

  FCODE = T185F-FCODE.

ENDFORM.