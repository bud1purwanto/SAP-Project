*---------------------------------------------------------------------*
*       FORM FCODE_SICH                                               *
*---------------------------------------------------------------------*
*       Sichern des Gesamtbeleges                                     *
*---------------------------------------------------------------------*
FORM fcode_sich.

* Sicherung
  IF synchronous EQ charx.
* create from container can require synchronous update
    PERFORM beleg_sichern USING charx
                                sy-subrc.
  ELSE.
    PERFORM beleg_sichern USING space
                                sy-subrc.
  ENDIF.

  CHECK sy-subrc = 0.
* Beim Aufruf aus der VA05 wird hier der Rücksprung durchgeführt
  IF sy-calld NE space.
    LEAVE.
  ENDIF.
* Sichern im Verändern springt zum ersten Bild der jeweiligen Tr.
* ebenso wenn Referenz erforderlich war.
ENHANCEMENT-SECTION     FCODE_SICH_01 SPOTS ES_SAPMV45A.
  IF t180-trtyp EQ charv OR
    tvak-bezob NE space.
*   FCODE = 'SIC1'.
*   PERFORM FCODE_BEARBEITEN.
  ELSE.
    PERFORM fcode_def1.
  ENDIF.
END-ENHANCEMENT-SECTION.
* Wenn gleich bei der Eingabe gesichert wird, sitzt sy-datar noch und
* setzt im Fcode-Modul das RV45A-Dataloss.
  CLEAR r185d-dataloss.

ENDFORM.                    "FCODE_SICH