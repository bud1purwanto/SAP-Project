*----------------------------------------------------------------------*
*   INCLUDE KKA07T01                                                   *
*----------------------------------------------------------------------*
* Historie:
* P30K049339/3.0D: Include angelegt für Umstellung auf Parallelisierung
* P30K081591/3.0E: Umstellung auf Parallelisierung fortgesetzt

TYPE-POOLS: KKPA.       "Type-Pool allgemein für Parallelverarbeitung
TYPE-POOLS: KKAP.       "Type-Pool individuell für WIP

* Konstanten
* Die folgenden Konstanten bestimmen massgeblich die Groeße der Pakete
CONSTANTS:
* Mindestgröße eines Pakets (mit Ausnahme des letzten Pakets)
      CON_PACKAGE_MIN  TYPE I VALUE  20, "Mindestgröße eines Pakets
* Maximalgröße eines Pakets
      CON_PACKAGE_MAX  TYPE I VALUE 200, "Maximalgröße eines Pakets
* Aufteilungsfaktor bzw. Wiederaufsetzfaktor bestimmt, wie oft
* (unter der Ann. gleicher Paketgrößen) ein Workprozeß verwendet wird
      CON_PAR_DIVIDER  TYPE I VALUE   5. "Aufteilungsfaktor

DATA:
   BEGIN OF GD_EOT,
     FORM TYPE KKPA_T_PARA_IMP-EOT_FORM,
     PROG TYPE KKPA_T_PARA_IMP-EOT_PROG,
   END OF GD_EOT.

DATA: GD_OBJ_DONE      TYPE I.    "Index des letzten bearb. Auftrags