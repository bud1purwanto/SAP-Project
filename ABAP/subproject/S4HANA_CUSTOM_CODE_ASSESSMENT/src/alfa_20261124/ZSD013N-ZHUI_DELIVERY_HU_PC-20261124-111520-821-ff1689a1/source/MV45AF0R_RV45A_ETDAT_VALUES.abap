*----------------------------------------------------------------------*
***INCLUDE MV45AF0R_RV45A_ETDAT_VALUES .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  RV45A_ETDAT_VALUES
*&---------------------------------------------------------------------*
*       F4 für Wunschlieferdatum unter Beachtung des Datumformats
*----------------------------------------------------------------------*
*      -->P_PRGBZ   Datumformat
*      -->P_ETDAT   Lieferdatum
*----------------------------------------------------------------------*
FORM RV45A_ETDAT_VALUES USING   P_PRGBZ
                                P_ETDAT.

  TABLES:  TPRG.
  DATA:    STEPLINE LIKE SY-STEPL,
           RDDAT LIKE RV45A-KEDATU.

* Vor dem expliziten Anstoß des Feldtransportes muß für den Fall von
* Steploops auf diesem Wege die aktuelle Zeile besorgt werden.
* aktuell gültige Zeile berücksichtigt wird.
  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = STEPLINE
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC NE 0.
    MESSAGE S845(06).
    EXIT.
  ENDIF.

* Struktur zum Auslesen von Dynprofeldern nach einer Benutzereingabe
* aber noch vor dem PAI: Liste aus Tupeln der Form
* (Feldname, Inhalt, Listzeile) (letzteres bei Steploop relevant)
  DATA: BEGIN OF DYNPFIELDS OCCURS 2.
          INCLUDE STRUCTURE DYNPREAD.
  DATA: END OF DYNPFIELDS.

  DATA: DYNPRO_PROGRAM  LIKE SY-REPID. "Programmpool und Nummer in dem
  DATA: DYNPRO_NUMBER   LIKE SY-DYNNR. "das aktuelle Dynpro liegt.
  DYNPRO_PROGRAM  = SY-REPID.          "believe it or not -
  DYNPRO_NUMBER   = SY-DYNNR.     "these assignments are necessary!!

* Partnerrolle und Partner-ID werden dynamisch mit den übergebenen
* Feldnamen assoziiert.
  FIELD-SYMBOLS: <ETDAT>    LIKE RV45A-ETDAT,
                 <PRGBZ>    LIKE RV45A-PRGBZ.
  ASSIGN (P_ETDAT) TO <ETDAT>.
  ASSIGN (P_PRGBZ) TO <PRGBZ>.

* zu lesenden Felder (für Listen auch die aktuelle Zeile) vormerken.
  MOVE P_PRGBZ    TO DYNPFIELDS-FIELDNAME.
  IF NOT STEPLINE IS INITIAL.
    MOVE STEPLINE   TO DYNPFIELDS-STEPL.
  ENDIF.
  APPEND DYNPFIELDS.
  MOVE P_ETDAT    TO DYNPFIELDS-FIELDNAME.
  APPEND DYNPFIELDS.

* Feldinhalte vor dem automatischen Feldtransport beim PAI
* explizit auslesen
  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            DYNAME                   = DYNPRO_PROGRAM
            DYNUMB                   = DYNPRO_NUMBER
*         TRANSLATE_TO_UPPER       = ' '
*         REQUEST                  = ' '
            PERFORM_INPUT_CONVERSION = 'X'
       TABLES
            DYNPFIELDS               = DYNPFIELDS
       EXCEPTIONS
            INVALID_ABAPWORKAREA     = 1
            INVALID_DYNPROFIELD      = 2
            INVALID_DYNPRONAME       = 3
            INVALID_DYNPRONUMMER     = 4
            INVALID_REQUEST          = 5
            NO_FIELDDESCRIPTION      = 6
            INVALID_PARAMETER        = 7
            UNDEFIND_ERROR           = 8
            OTHERS                   = 9.
  IF SY-SUBRC NE 0.
    MESSAGE S844(06).
    EXIT.
  ENDIF.

READ TABLE DYNPFIELDS INDEX 1.
IF SY-SUBRC EQ 0.
   <PRGBZ> = DYNPFIELDS-FIELDVALUE.
ENDIF.
IF <PRGBZ> EQ SPACE.
   MESSAGE S844(06).
   EXIT.
ENDIF.

*- Interne Darstellung vom Datumstyp besorgen -------------------------*
SELECT SINGLE * FROM TPRG WHERE SPRAS EQ SY-LANGU
                            AND PRGBZ EQ <PRGBZ>.
IF SY-SUBRC NE 0.
   MESSAGE S346(V1) WITH <PRGBZ>.
   EXIT.
ENDIF.

*- F4-Hilfe aufrufen --------------------------------------------------*
CALL FUNCTION 'F4_DATE'
      EXPORTING
          DATE_FOR_FIRST_MONTH = SY-DATLO
      IMPORTING
          SELECT_DATE = RDDAT.
IF SY-SUBRC NE 0.
   MESSAGE S845(06).
   EXIT.
ENDIF.

*- Datum in externe Darstellung konvertieren --------------------------*
IF NOT RDDAT IS INITIAL.
   CALL FUNCTION 'PERIOD_AND_DATE_CONVERT_OUTPUT'
        EXPORTING
             INTERNAL_DATE = RDDAT
             INTERNAL_PERIOD = TPRG-PRGRS
        IMPORTING
             EXTERNAL_DATE = <ETDAT>
             EXTERNAL_PERIOD = <PRGBZ>.
ENDIF.

ENDFORM.                               " RV45A_ETDAT_VALUES