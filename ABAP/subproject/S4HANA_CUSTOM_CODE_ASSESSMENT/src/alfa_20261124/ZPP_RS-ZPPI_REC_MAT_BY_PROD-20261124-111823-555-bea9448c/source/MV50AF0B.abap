************************************************************************
*                                                                      *
* Unterroutinen RV-Versand alphabetisch sortiert:                      *
* -----------------------------------------------                      *
* Buchstabe B:                                                         *
*                                                                      *
************************************************************************
include mv50af0b_beleg_bestellung_erga."enzen
include mv50af0b_beleg_initialisieren.
include mv50af0b_beleg_init_on_commit.
include mv50af0b_beleg_lesen.
include MV50AF0B_beleg_lesen_archiv.
include mv50af0b_beleg_lesen_buffered.
include mv50af0b_beleg_lesen_direkt.
include mv50af0b_beleg_lesen_simple.                           "n_527241
include mv50af0b_beleg_loeschen.
include mv50af0b_berechtigung_pruefen.
include mv50af0b_bestellung_ekes_fuell."en
include mv50af0b_best_ekes_aus_lips.
include mv50af0b_bestellung_ekbe_fuell."en
include mv50af0b_bestellung_sperren.
include mv50af0b_best_ekbe_aus_lips.
include mv50af0b_blaettern.
include mv50af0b_return_ekes_fuellen.
include mv50af0b_build_address_short_f."orm

*---------------------------------------------------------------------*
*  FORM DUMMY
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
form dummy.
endform.                    "DUMMY
*eject