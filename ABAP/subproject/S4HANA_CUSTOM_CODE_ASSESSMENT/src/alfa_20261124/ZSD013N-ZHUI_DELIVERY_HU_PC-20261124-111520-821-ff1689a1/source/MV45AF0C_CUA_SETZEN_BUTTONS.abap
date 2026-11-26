*---------------------------------------------------------------------*
*       FORM CUA_SETZEN_BUTTONS                                       *
*---------------------------------------------------------------------*
*       Buttonleiste für Übersichtsbilder bestimmen                   *
*       Normalerweise wird als Buttonleiste das Dynpro SAPMV45A 4050  *
*       als Subscreen eingesetzt.                                     *
*---------------------------------------------------------------------*
FORM CUA_SETZEN_BUTTONS.
ENHANCEMENT-SECTION     CUA_SETZEN_BUTTONS_01 SPOTS ES_SAPMV45A.
  IF TVAK-ABDIS NE SPACE.            "Lieferpläne Zulieferer
    DYNPRO_BUTTONS = '4051'.
  ELSEIF TVAK-VBKLT CA 'FG' AND      "Reparaturabwicklung
         TVAK-VBTYP CA VBTYP_AUFTR.
    DYNPRO_BUTTONS = '4054'.
  ELSEIF TVAK-VBTYP EQ VBTYP_KONT.   "Kontrakte
    DYNPRO_BUTTONS = '4052'.
  ELSEIF TVAK-VBTYP EQ VBTYP_GRUKO.  "Gruppenkontrakt
    DYNPRO_BUTTONS = '4053'.
  ELSE.
    DYNPRO_BUTTONS = '4050'.         "Standard-Buttonleiste
  ENDIF.
END-ENHANCEMENT-SECTION.
ENDFORM.