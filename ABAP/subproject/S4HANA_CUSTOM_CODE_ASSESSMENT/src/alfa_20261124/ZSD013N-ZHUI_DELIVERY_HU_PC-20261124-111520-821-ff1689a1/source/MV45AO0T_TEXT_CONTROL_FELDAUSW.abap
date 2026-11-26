*----------------------------------------------------------------------*
*   INCLUDE MV45AO0T_TEXT_CONTROL_FELDAUSW                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  TEXT_CONTROL_FELDAUSWAHL  OUTPUT
*&---------------------------------------------------------------------*
*       Dieser Modul steuert die Eingabebereitschaft der Elemente      *
*       des Dynpro SAPMV45A 4950, mit Ausnahme der Eingabebereitschaft *
*       des Texteditors selbst. Diese wird bereits im Modul            *
*       Text_Control_Vorbereiten festgelegt.                           *
*       Der vorliegende Modul stößt auch den DESTROY_CONTROL an, wenn  *
*       der Texteditor nicht mehr verfügbar ist.
*----------------------------------------------------------------------*
MODULE TEXT_CONTROL_FELDAUSWAHL OUTPUT.

  PERFORM TEXT_CONTROL_FELDAUSWAHL.

ENDMODULE.                 " TEXT_CONTROL_FELDAUSWAHL  OUTPUT