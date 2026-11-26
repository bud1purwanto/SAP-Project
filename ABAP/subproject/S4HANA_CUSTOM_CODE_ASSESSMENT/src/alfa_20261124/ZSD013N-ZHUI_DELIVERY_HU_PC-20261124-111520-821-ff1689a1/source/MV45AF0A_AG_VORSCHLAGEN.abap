*eject
*----------------------------------------------------------------------*
*          FORM AG_PRUEFEN                                             *
*----------------------------------------------------------------------*
* Der Auftraggeber wird vorgeschlagen                                  *
*----------------------------------------------------------------------*
FORM AG_VORSCHLAGEN.

  CHECK KUAGV-KUNNR IS INITIAL.
* Auftraggeber erlaubt ?
  PERFORM TPAER_SELECT USING TVAK-PARGR
                             'AG'
                             SPACE
                             SY-SUBRC.
  CHECK SY-SUBRC = 0.

* Auftraggeber

  GET PARAMETER ID 'VAU' FIELD KUAGV-KUNNR.
  SET LOCALE LANGUAGE SY-LANGU.
  TRANSLATE KUAGV-KUNNR TO UPPER CASE.
  IF KUAGV-KUNNR CO '0123456789'.
    UNPACK KUAGV-KUNNR TO KUAGV-KUNNR.
  ENDIF.

  CALL CUSTOMER-FUNCTION '002'
       EXPORTING
            I_TVAK = TVAK
            I_TVTA = TVTA
            I_VKGRP = DEFAULT_VKGRP
            I_VKBUR = DEFAULT_VKBUR
       IMPORTING
            E_KUNNR = KUAGV-KUNNR.
  CHECK NOT KUAGV-KUNNR IS INITIAL.
  CLEAR VTCOMAG.
  VTCOMAG-KUNNR = KUAGV-KUNNR.

  CALL FUNCTION 'VIEW_KUAG2'
       EXPORTING
            COMWA = VTCOMAG
       IMPORTING
            AGWA  = KUAGV
       EXCEPTIONS
            ERROR_MESSAGE = 1.

  PERFORM KUAGV-TXTPA_ERMITTELN.

ENDFORM.