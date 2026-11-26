*---------------------------------------------------------------------*
*       FORM FCODE_KKSE                                               *
*---------------------------------------------------------------------*
*       Es wird das Kopf-Preisbild für Serviceleistungen              *
*       angezeigt                                                     *
*---------------------------------------------------------------------*
FORM FCODE_KKSE USING H185F STRUCTURE T185F H185  STRUCTURE T185
                                            H185V STRUCTURE T185V.
  DATA: DA_MAINTAIN_MODE,
        DA_ENQUEUE,
        FK_CHANGE.

* KOMK
  PERFORM PREISFINDUNG_VORBEREITEN(SAPFV45P) USING 'K'.
  IF T180-TRTYP EQ CHARH AND VBAK-VBELN IS INITIAL.
    TKOMK-BELNR = '$TEMP'.
  ENDIF.

* Kalkulationsschema für Preisvereinbarungen in TKOMK stellen
  TKOMK-KALSM = TVAK-KSKPF.

* Die Stammkonditionen lesen (aber nur einmalig)
* if tvcpa-auarv eq space and tvcpa-auarn eq space.
*   if not tvak-vterl is initial.
  CALL FUNCTION 'SD_CONTRACT_READ_CONDITIONS'
       EXPORTING
            SR_VBELN            = VBAK-VBELN
            SR_KAPPL            = 'V'
            TRANSACTION_MODE    = T180-TRTYP
       EXCEPTIONS
            CANCEL_REQUESTED    = 04
            NO_CONDITIONS_FOUND = 08.
*   endif.
* endif.
  IF SY-SUBRC = 4.
    H185F-FCODE = FCODE_ZURUECK.
    EXIT.
  ENDIF.
* Konditionssätze vorschlagen falls keine da sind.
  IF T180-TRTYP NE CHARA.
    CALL FUNCTION 'SD_CONTRACT_PROPOSE_CONDITIONS'
         EXPORTING
              KALSM                 = TVAK-KSKPF
              I_KOMK                = TKOMK
              I_KOMP                = TKOMP
              I_KOPF                = 'X'
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
* Auftragsnummer setzen
  CLEAR: TKOMG.
  TKOMG-VBELN = TKOMK-BELNR.
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
            CHANGE_IN_RECORD         = FK_CHANGE
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

  IF FK_CHANGE NE SPACE.
    R185D-DATALOSS = CHARX.
* If price agreements were changed, call pricing
    PERFORM PREISFINDUNG_GESAMT USING CHARC.
  ENDIF.

  H185F-FCODE = FCODE_ZURUECK.

ENDFORM.