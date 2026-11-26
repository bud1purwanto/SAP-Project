*----------------------------------------------------------------------*
*   INCLUDE MV45AI0I_IDOC_INPUT_OPEN                                   *
*----------------------------------------------------------------------*

MODULE IDOC_INPUT_OPEN.

  IF T180-TRTYP EQ CHARV AND
     TVAK-VBTYP CA VBTYP_LP.
*- Beim Ändern eines Lieferplanes ist die Idocnummer in der Struktur --*
*- RV45Z --------------------------------------------------------------*
    PERFORM IDOC_INPUT_OPEN USING RV45Z-DOCNUM.
  ELSE.
    PERFORM IDOC_INPUT_OPEN USING RV45A-DOCNUM.
  ENDIF.
ENDMODULE.