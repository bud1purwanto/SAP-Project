*----------------------------------------------------------------------*
*   INCLUDE RKCOSEI3                                                   *
*----------------------------------------------------------------------*


* Ereignisse
* F4-Hilfe
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR werks.
*  PERFORM value_request_werks.

* Pruefen Eingaben
AT SELECTION-SCREEN ON werks.
  perform kokrs_adjust using werks[].
* PERFORM werks_text_get USING     werks  'X'
*                        CHANGING  txtw.