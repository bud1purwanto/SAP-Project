***INCLUDE V50J_CONST.
*---------------------------------------------------------------------*
*     Direktwerte fuer Gefahgut-Verarbeitung in WS-SHP                *
*     zusätzlich zum RVDIREKT                                         *
*---------------------------------------------------------------------*

CONSTANTS:
* Funktions-Codes
  FCODE_GEFAHRGUTPRUEFUNG        LIKE T185F-FCODE VALUE 'KGGP',
  FCODE_TEMPLATE_PROCESSING      LIKE T185F-FCODE VALUE 'DGMD_T',

*  Vergleichsoperatoren
  GC_GG_UNCHECKED VALUE IS INITIAL,
  GC_GG_INAKTIV   VALUE 'A',
  GC_GG_AKTIV     VALUE 'B',
  TRUE     VALUE 'X',
  FALSE    VALUE IS INITIAL.