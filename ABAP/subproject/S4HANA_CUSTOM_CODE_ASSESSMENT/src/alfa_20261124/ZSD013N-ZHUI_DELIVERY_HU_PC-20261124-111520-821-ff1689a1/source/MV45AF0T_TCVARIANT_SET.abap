*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TCVARIANT_SET                                     *
*----------------------------------------------------------------------*
*   Setzen der Transaktionvariante in Abhängigkeit von TVAK-VARIANT    *
*----------------------------------------------------------------------*
FORM TCVARIANT_SET.

* Wenn eine Transaktionsvariante für die Auftragsart hinterlegt ist
* soll diese verwendet werden.
  CALL FUNCTION 'RS_HDSYS_SET_TC_VARIANT'
       EXPORTING
            VARIANT                 = TVAK-VARIANT
            FLAG_CLIENT_INDEPENDENT = CHARX
            OVERWRITE_VARIANT       = CHARX.

ENDFORM.