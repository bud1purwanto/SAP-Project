*---------------------------------------------------------------------*
*       FORM FCODE_PKSE                                               *
*---------------------------------------------------------------------*
*       Übergang zum Positionspreisbild via Dialogbaustein            *
*---------------------------------------------------------------------*
FORM FCODE_PKSE USING H185F STRUCTURE T185F H185  STRUCTURE T185
                                            H185V STRUCTURE T185V.
  DATA: DA_MAINTAIN_MODE,
        DA_ENQUEUE,
        FP_CHANGE.

* Entsprechende Daten bereitstellen
  PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).

* KOMK und KOMP füllen
  PERFORM PREISFINDUNG_VORBEREITEN(SAPFV45P) USING 'P'.
  IF T180-TRTYP EQ CHARH AND VBAK-VBELN IS INITIAL.
    TKOMK-BELNR = '$TEMP'.
  ENDIF.

* Kalkulationsschema für Preisvereinbarungen in TKOMK stellen
  TKOMK-KALSM = TVAK-KSKPF.

* Die Stammkonditionen lesen (aber nur einmalig)
  CALL FUNCTION 'SD_CONTRACT_READ_CONDITIONS'
    EXPORTING
      SR_VBELN            = VBAK-VBELN
      SR_KAPPL            = 'V'
      SR_POSNR            = VBAP-POSNR
      TRANSACTION_MODE    = T180-TRTYP
    EXCEPTIONS
      CANCEL_REQUESTED    = 04
      NO_CONDITIONS_FOUND = 08.
  IF SY-SUBRC = 4.
    H185F-FCODE = FCODE_ZURUECK.
    EXIT.
  ENDIF.
* Konditionssätze vorschlagen falls keine da sind.
  IF T180-TRTYP NE CHARA.
    CALL FUNCTION 'SD_CONTRACT_PROPOSE_CONDITIONS'
      EXPORTING
        KALSM                 = TVAK-KSPOS
        I_KOMK                = TKOMK
        I_KOMP                = TKOMP
        I_KOPF                = ' '
      EXCEPTIONS
        NO_TABLE_SPECIFIED    = 01
        NO_SELECTION          = 02
        RECORDS_ALREADY_EXIST = 03.
    IF SY-SUBRC EQ 0.
      R185D-DATALOSS = CHARX.
    ENDIF.
  ENDIF.

* Variable für Konditionssperre sicherheitshalber zurücksetzen
  CLEAR DA_ENQUEUE.
* Konditionssätze auf dem variablen Listbild anzeigen
  IF T180-TRTYP EQ CHARA.
    DA_MAINTAIN_MODE = CHARC.
  ELSEIF T180-TRTYP EQ CHARH.
    DA_MAINTAIN_MODE = CHARA.
  ELSE.
    DA_MAINTAIN_MODE = CHARB.
    DA_ENQUEUE       = CHARX.
  ENDIF.

* Positionsnummer mitgeben da in TKOMG nicht vorhanden
  CLEAR TKOMG.
  TKOMG-VBELN = TKOMK-BELNR.
  TKOMG-POSNR = VBAP-POSNR.

  CALL FUNCTION 'RV_CONDITION_MAINTENANCE'
    EXPORTING
      APPLICATION              = 'V'
      FIRST_SCREEN             = 'D'
      KEY_FIELDS               = TKOMG
      MAINTAIN_MODE            = DA_MAINTAIN_MODE
      ENQUEUE                  = DA_ENQUEUE
      I_KOMK                   = TKOMK
      I_KOMP                   = TKOMP
      SOURCE                   = 'A'
      CONTEXT_REQUESTED        = 'X'
    IMPORTING
      CHANGE_IN_RECORD         = FP_CHANGE
    EXCEPTIONS
      ENQUEUE_ON_RECORD        = 01
      INVALID_APPLICATION      = 02
      INVALID_CONDITION_NUMBER = 03
      INVALID_CONDITION_TYPE   = 04
      NO_AUTHORITY_EKORG       = 05
      NO_AUTHORITY_KSCHL       = 06
      NO_AUTHORITY_VKORG       = 07
      NO_SELECTION             = 08
      TABLE_NOT_VALID          = 09
      TERMINATED_BY_USER       = 10.

  IF FP_CHANGE NE SPACE.
    R185D-DATALOSS = CHARX.
*   Perform new pricing if price agreements were changed
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
    PERFORM PREISFINDUNG(SAPFV45P) USING CHARC.
    PERFORM VBAP_PRUEFEN_ENDE(SAPFV45P).
*     Statusermittlung
    PERFORM XVBUP_PFLEGEN_AKTUELL(SAPFV45P).
    PERFORM XVBAP_AENDERN(SAPFV45P).

  ENDIF.

  H185F-FCODE = FCODE_ZURUECK.

ENDFORM.                    "FCODE_PKSE