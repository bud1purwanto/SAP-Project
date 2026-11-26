***INCLUDE MV45AF0S_STATUS_LESEN_INIT .

*---------------------------------------------------------------------*
* FORM STATUS_LESEN_INIT                                              *
*---------------------------------------------------------------------*
* Status im Übersichtsbild: Pflege vorbereiten                        *
* Einlesen in XTVSTAT                                                 *
* Maximale Zahl von Zeilen zur Auftragsart ermitteln                  *
* Texte für die Überschriften versorgen                               *
*---------------------------------------------------------------------*
FORM status_lesen_init.

  DATA: BEGIN OF name,
    fest(7) VALUE 'STTXT-T',
    lfdst TYPE lfdst,
  END OF name,
  da_txt04 TYPE j_txt04.
  DATA: counter TYPE i.
  FIELD-SYMBOLS: <fs>.

* Sind die Werte schon versorgt?
  READ TABLE xtvstat WITH KEY auart = tvak-auart.
  IF sy-subrc NE 0.
* Nein, dann einlesen und einfügen
    SELECT * APPENDING TABLE xtvstat
             FROM tvstat
             WHERE auart = tvak-auart.
* Anzahl insgesamt anzuzeigender Status-Spalten
    SORT xtvstat.
  ENDIF.
* Überschrifttexte ermitteln
  CLEAR counter.
  LOOP AT xtvstat WHERE auart = tvak-auart.
    ADD 1 TO counter.
    MOVE xtvstat-lfdst TO name-lfdst.
    ASSIGN (name) TO <fs>.
    CALL FUNCTION 'STATUS_NUMBER_CONVERSION'
      EXPORTING
        language      = sy-langu
        status_number = xtvstat-status
        stsma         = xtvstat-stsma
      IMPORTING
        txt04         = da_txt04
      EXCEPTIONS
        OTHERS        = 1.
    MOVE da_txt04 TO <fs>.
  ENDLOOP.
  maxstats = counter.

ENDFORM.                    "STATUS_LESEN_INIT