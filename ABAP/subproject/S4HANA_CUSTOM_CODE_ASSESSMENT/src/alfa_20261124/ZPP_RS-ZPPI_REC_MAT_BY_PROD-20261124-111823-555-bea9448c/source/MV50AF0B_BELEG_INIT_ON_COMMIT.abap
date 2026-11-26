*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BELEG_INIT_ON_COMMIT                              *
*----------------------------------------------------------------------*
*   This routine is called via external perform from SAPLV50S to allow
*   the initialization routines to be executed ON COMMIT.
*----------------------------------------------------------------------*
FORM BELEG_INIT_ON_COMMIT.

  PERFORM TEXT_MEMORY_INIT ON COMMIT.
  PERFORM BELEG_DATEN_INIT ON COMMIT.

ENDFORM.