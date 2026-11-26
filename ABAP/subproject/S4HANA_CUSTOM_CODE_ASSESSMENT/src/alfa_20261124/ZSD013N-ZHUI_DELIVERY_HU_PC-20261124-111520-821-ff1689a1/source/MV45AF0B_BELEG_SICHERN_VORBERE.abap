*---------------------------------------------------------------------*
*       FORM BELEG_SICHERN_VORBEREITEN                                *
*---------------------------------------------------------------------*
*       Nummernvergabe für manuelle Partner                           *
*       Die Einzel- und Summenbedarfssätze werden aus der Verfügbar-  *
*       keitsprüfung/Bedarfsübergabe abgerufen                        *
*---------------------------------------------------------------------*
FORM BELEG_SICHERN_VORBEREITEN.

DATA: DA_TRTYP TYPE TRTYP.

MOVE T180-TRTYP TO DA_TRTYP.
* Adressnummernvergabe und ZAV-Verbuchung
  CALL FUNCTION 'SD_PARTNER_ADDRESSES_TO_DB'
       EXPORTING
            FIF_VBELN                      = VBAK-VBELN
            FIF_TRTYP                      = da_trtyp
       TABLES
            FET_XVBPA                      = XVBPA
            FET_XVBADR                     = XVBADR
       EXCEPTIONS
            NUMBER_COULD_NOT_BE_DETERMINED = 1
            CAM_SAVING_ERROR               = 2
            OTHERS                         = 3.

* XVBPA globalisieren
  perform bapidaten_fuellen_xvbpa.

* Positionen aus Produktvorschlag (ohne Menge) nicht sichern
  PERFORM PRODUKTVORSCHLAG_SICHERN_VOR(SAPFV45P).

* Product Selection in der Lieferung nicht wiederholen
  PERFORM PRODUCT_SELECTION_RESET(SAPFV45P).

* Sourcing in der Lieferung nicht wiederholen
  PERFORM SOURCING_RESET(SAPFV45P).

* Kalkulationsverbuchung vorbereiten
  PERFORM KALKULATION_SICHERN_VOR(SAPFV45P).

* Dokumentzuordnung mit der entgültigen Belegnummer versehen.
  PERFORM DOKUMENTE_UMBENENNEN.

* Abrufdaten aus Funktionsgruppe V45L übernehmen
  CALL FUNCTION 'SD_XVBLB_YVBLB_GET_FOR_UPDATE'
       TABLES
            FXVBLB = XVBLB
            FYVBLB = YVBLB
       EXCEPTIONS
            OTHERS = 0.

* Korrekturfortschrittszahlen aus Funktionsgruppe V45L übernehmen
  CALL FUNCTION 'SD_XVBKFZ_YVBKFZ_GET_FOR_UPD'
       TABLES
            FXVBKFZ = XVBKFZ
            FYVBKFZ = YVBKFZ
       EXCEPTIONS
            OTHERS = 0.

ENDFORM.