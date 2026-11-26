***INCLUDE MV45AF0D_DATUM_PRUEFEN_WERK_FK .

*&---------------------------------------------------------------------*
*&      Form  DATUM_PRUEFEN_WERK_FK
*&---------------------------------------------------------------------*
*       Das übergebene Datum wird gegen den Fabrikkalender des Werks
*       geprüft, sofern dieser ermittelt werden kann oder bereits
*       bekannt ist.
*----------------------------------------------------------------------*
FORM DATUM_PRUEFEN_WERK_FK USING US_WERK LIKE T001W-WERKS
                                 US_DATUM LIKE VBEP-EDATU
                                 US_ERROR
                                 US_WERK_PRUEFEN
                           CHANGING CH_SUBRC LIKE SY-SUBRC.

  DATA: DA_SUBRC LIKE SY-SUBRC,
        DA_EXTDATUM(10) TYPE C.

  CLEAR CH_SUBRC.

  CHECK NOT US_WERK IS INITIAL AND
        NOT US_DATUM IS INITIAL.

* Werkskalender ermitteln
  IF US_WERK_PRUEFEN EQ CHARX.
    PERFORM T001W_SELECT USING US_WERK
                               CHARX
                               DA_SUBRC.
  ELSE.
    PERFORM T001W_SELECT USING US_WERK
                               SPACE
                               DA_SUBRC.
  ENDIF.

  CHECK NOT T001W-FABKL IS INITIAL.

  CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
       EXPORTING
            DATE                         = US_DATUM
            FACTORY_CALENDAR_ID          = T001W-FABKL
       EXCEPTIONS
            CALENDAR_BUFFER_NOT_LOADABLE = 1
            CORRECT_OPTION_INVALID       = 2
            DATE_AFTER_RANGE             = 3
            DATE_BEFORE_RANGE            = 4
            DATE_INVALID                 = 5
            FACTORY_CALENDAR_NOT_FOUND   = 6
            OTHERS                       = 7.

  IF SY-SUBRC NE 0.
    CH_SUBRC = SY-SUBRC.
    IF US_ERROR EQ CHARX.
      WRITE US_DATUM TO DA_EXTDATUM DD/MM/YYYY.
      CASE SY-SUBRC.
        WHEN 3.
          MESSAGE E210(V2) WITH DA_EXTDATUM T001W-FABKL T001W-WERKS.
        WHEN 4.
          MESSAGE E209(V2) WITH DA_EXTDATUM T001W-FABKL T001W-WERKS.
        WHEN 6.
          MESSAGE E208(V2) WITH T001W-FABKL T001W-WERKS.
      ENDCASE.
    ENDIF.
  ENDIF.

ENDFORM.                               " DATUM_PRUEFEN_WERK_FK