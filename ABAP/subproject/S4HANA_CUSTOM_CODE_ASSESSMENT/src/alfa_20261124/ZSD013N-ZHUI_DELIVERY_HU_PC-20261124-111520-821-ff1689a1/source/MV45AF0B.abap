************************************************************************
*                                                                      *
* Unterroutinen fuer die Kundenauftragsabwicklung                      *
*     Routine alphabetisch geordnet; hier mit "B" beginnend            *
*                                                                      *
************************************************************************

  INCLUDE MV45AF0B_BAPIDATEN_ERMITTELN.
  INCLUDE MV45AF0B_BAPIDATEN_FUELLEN.
  INCLUDE MV45AF0B_BEDARF_FUELLEN .
  INCLUDE MV45AF0B_BELEG_AUS_CONTAINER .
  INCLUDE MV45AF0B_BELEG_BEARBEITEN_ENDE .
  INCLUDE MV45AF0B_BELEG_ENTSPERREN .
  INCLUDE MV45AF0B_BELEG_ENTSPERREN_BTCH .
  INCLUDE MV45AF0B_BELEG_INITIALISIEREN .
  INCLUDE MV45AF0B_BELEG_KOPIEREN .
  INCLUDE MV45AF0B_BELEG_LESEN .
  INCLUDE MV45AF0B_BELEG_LOESCHEN .
  INCLUDE MV45AF0B_BELEG_PRUEFEN .
  INCLUDE MV45AF0B_BELEG_SICHERN .
  INCLUDE MV45AF0B_BELEG_SICHERN_VORBERE .
  INCLUDE MV45AF0B_BELEG_SPERREN .
  INCLUDE MV45AF0B_BELEG_SPERREN_BATCH .
  INCLUDE MV45AF0B_BERECHTIGUNG_PRUEFEN .
  INCLUDE MV45AF0B_BERECHTIGUNG_TRANS .
  INCLUDE MV45AF0B_BLAETTERN .
  INCLUDE MV45AF0B_BELEG_POS_KOPIEREN_AU .
  INCLUDE MV45AF0B_BELEG_KOPF_KOPIEREN_A .
  INCLUDE MV45AF0B_BOYKOTT_KOPF .
  INCLUDE MV45AF0B_BUTTON_AUSWAHL .
  INCLUDE MV45AF0B_BEST_SET_CURSOR.
  INCLUDE MV45AFOB_LORD_HEAD_PBO.

  include mv45af0b_lord_doc_read.
  include mv45af0b_lord_doc_create.
  include mv45af0b_lord_doc_save.

  include mv45af0b_beleg_lesen_logic.
  include mv45af0b_beleg_init_logic.
  include mv45af0b_beleg_rename_logic.
  include mv45af0b_beleg_loeschen_logic.