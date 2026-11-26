***INCLUDE MV50AFZZ .


************************************************************************
*                                                                      *
* This include is reserved for user modifications                      *
*                                                                      *
* Forms for delivery processing                                        *
*                                                                      *
* The name of modification modules should begin with 'ZZ'.             *
*                                                                      *
************************************************************************


*---------------------------------------------------------------------*
*       FORM USEREXIT_BATCH_DETERMINATION                             *
*---------------------------------------------------------------------*
*       Userexit zur Ermittlung einer Charge in einer Lieferposition  *
*       zur Verfügung stehen:                                         *
*       LIPS      (die bis dahin aufgebaute Lieferposition)           *
*       Dieses Beispiel zeigt die Selektion einer Charge              *
*       anhand ihres Verfügbarkteitsdatums und ihres Verfalldatums.   *
*       Es wird die erste Charge ermittelt, die gemäß Daten           *
*       verfügbar ist. Die Mengenverfügbarkteit erfolgt zu            *
*       einem späteren Zeitpunkt. Dies bedeutet, daß eine zu diesem   *
*       Zeitpunkt gefundene Charge aufgrund mangelnder Verfügbarkeit  *
*       nicht in die Lieferposition wandert.                          *
*---------------------------------------------------------------------*
FORM USEREXIT_BATCH_DETERMINATION.

  DATA: UBD_SUBRC  LIKE SY-SUBRC VALUE 0.     "eigener subrc

  CHECK NOT LIPS-XCHPF IS INITIAL.            "Material chargenpflichtig
  CHECK LIPS-CHARG IS INITIAL.                "Charge vorhanden?
  CHECK NOT LIPS-MATNR IS INITIAL.            "Material gefüllt?
  CHECK NOT LIPS-WERKS IS INITIAL.            "Werk gefüllt?


* Beispiel einer Selektion
* die erste Charge wird genommen, deren Verfügbarkeits- und Verfalls-
* daten im gewünschten Intervall liegen
*
* SELECT *
*        INTO MCHA
*        FROM MCHA
*        WHERE MATNR = LIPS-MATNR
*        AND   WERKS = LIPS-WERKS.
*
*    UBD_SUBRC = 0.
*... allgemeine Prüfung der Charge
*    PERFORM LIPS-CHARG_PRUEFEN_ALLGEMEIN(SAPFV50P) USING LIPS-MATNR
*                                                         LIPS-WERKS
*                                                         MCHA-CHARG
*                                                         SY-DATUM
*                                                         LIKP-LFDAT
*                                                         SPACE
*                                                         UBD_SUBRC.
*    IF UBD_SUBRC = 0.
*       LIPS-CHARG = MCHA-CHARG.                "Charge übernehmen
*       EXIT.
*    ENDIF.
*
* ENDSELECT.
*
* Falls keine Charge gefunden wurde, erfolgt ein Hinweis im Fehler-
* protokoll
* IF SY-SUBRC > 0 OR
*    UBD_SUBRC > 0.
*    PERFORM MESSAGE_HANDLING USING CVBAP-POSNR
*                                   '207'
*                                   'I'
*                                   'VL'
*                                   SPACE
*                                   SPACE
*                                   SPACE
*                                   SPACE.
* ENDIF.


ENDFORM.
*eject




FORM USEREXIT_LGORT_DETERMINATION.
*       This userexit can be used to fill the field LIPS-LGORT,       *
*       when a delivery is created                                    *
*       This form is called in the form LIPS-LGORT_ERMITTELN in the   *
*       Include FV50XFLP                                              *
*       you can use LIKP, some fields of LIPS, MAAPV, ...             *

* LIPS-LGORT = .......

ENDFORM.





