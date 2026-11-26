*----------------------------------------------------------------------*
*   INCLUDE MV45AF0I_IDOC_INPUT_OPEN                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  IDOC_INPUT_OPEN
*&---------------------------------------------------------------------*
*      -->US_RV45A_DOCNUM  Idocnummer                                  *
*----------------------------------------------------------------------*
FORM IDOC_INPUT_OPEN USING US_DOCNUM.

  CHECK US_DOCNUM NE SPACE.
  MOVE US_DOCNUM TO IDOC_NUMBER.
  CALL FUNCTION 'IDOC_INPUT_OPEN'
       EXPORTING
            DOCUMENT_NUMBER         = IDOC_NUMBER
       IMPORTING
            IDOC_CONTROL            = IDOC_EDIDC
       TABLES
            SERIALIZATION_INFO      = SERIALIZATION_INFO
       EXCEPTIONS
            DOCUMENT_FOREIGN_LOCK   = 01
            DOCUMENT_NOT_EXIST      = 02
            DOCUMENT_NUMBER_INVALID = 03
            END_OF_DOCUMENT         = 04.

  IF SY-SUBRC NE 0.
    MESSAGE E223(VG) WITH IDOC_NUMBER.
*    IDoc & kann nicht geöffnet werden
  ENDIF.

*- Serialisierung prüfen - keine Überholvorgänge erlaubt --------------*
  READ TABLE SERIALIZATION_INFO INDEX 1.
  IF SY-SUBRC EQ 0 AND
     SERIALIZATION_INFO-SERFLAG NE SPACE.
    MESSAGE E224(VG).
*    Diese Änderung wurde von einer anderen Änderung überholt
  ENDIF.
* Posguid aus dem Memory SDEDIPOSGUID holen
  CONSTANTS: DA_IDOC_SDEDIPOSGUID(12) VALUE 'SDEDIPOSGUID'.
  IMPORT XPOSGUID FROM MEMORY ID DA_IDOC_SDEDIPOSGUID.
    IF NOT XPOSGUID[] IS INITIAL.
      SORT XPOSGUID BY POSEX.
      ATP_WORKMODE = CHARA.
* ALE-TPO: no group check in delivery system
      CLEAR ATP_GRUPPENAUFRUF.
      FREE MEMORY ID DA_IDOC_SDEDIPOSGUID.
    ENDIF.

ENDFORM.                               " IDOC_INPUT_OPEN