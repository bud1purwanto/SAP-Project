*---------------------------------------------------------------------*
*       FORM CALL_FUNCTION_FLAGS                                      *
*---------------------------------------------------------------------*
*       Flags für Call Function setzen                                *
*---------------------------------------------------------------------*
FORM CALL_FUNCTION_FLAGS USING US_SUPPRESS_TEXT_POPUP
                               US_STATUS_BUFFER_REFRESH
                               US_MESSAGE_POPUP
                               US_SUPPRESS_AVAILIBILITY_DIA.

  CALL_FUNCTION = CHARX.
  DISPLAY_TEXT_POPUP = US_SUPPRESS_TEXT_POPUP.
* Variable für Initialisierung Status-Puffer setzen
  STATUS_BUFF_INIT = US_STATUS_BUFFER_REFRESH.
* Variable zur Steuerung des Popup's 'Hinweis auf Angebote/Kontrakte'
  DISPLAY_MESSAGE_POPUP = US_MESSAGE_POPUP.
* Verfügbarkeitsdialog.
  SUPPRESS_AV_DIALOG = US_SUPPRESS_AVAILIBILITY_DIA.

ENDFORM.