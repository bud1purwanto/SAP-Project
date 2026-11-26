*---------------------------------------------------------------------*
*       FORM FCODE_KONB                                               *
*---------------------------------------------------------------------*
*       Es wird eine komplett neue Preisfindung durchgefuehrt         *
*---------------------------------------------------------------------*
FORM FCODE_KONB.
  IMPORT GLOBAL_PRICING_TYPE FROM MEMORY ID 'MVLV45PT'.
  IF SY-SUBRC NE 0.
* Ermittlung der Preisfindungsart ohne Popup
    CALL FUNCTION 'PRICING_TYPE_DETERMINE'
         EXPORTING
              KVEWE_I = 'A'
              KAPPL_I = 'V '
              KALSM_I = VBAK-KALSM
         IMPORTING
              KNPRS_E = GLOBAL_PRICING_TYPE.
  ELSE.
* Aufruf der Preisfindung mit diesem Wert
    IF GLOBAL_PRICING_TYPE IS INITIAL.
      GLOBAL_PRICING_TYPE = CHARB.
    ENDIF.
  ENDIF.
  PERFORM PREISFINDUNG_GESAMT USING GLOBAL_PRICING_TYPE.
ENDFORM.