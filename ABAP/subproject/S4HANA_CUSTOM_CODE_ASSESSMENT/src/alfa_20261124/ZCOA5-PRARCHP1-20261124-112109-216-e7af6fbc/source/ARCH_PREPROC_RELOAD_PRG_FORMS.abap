*&---------------------------------------------------------------------*
*&   Unterprogramme für die Standardincludes der Vor- Nachlauf- und    *
*&   Rückladeprogramme                                                 *
*&---------------------------------------------------------------------*

INCLUDE arch_prg_forms.
*----------------------------------------------------------------------*
*  Titel des Rahmens auf "Ablaufsteuerung" setzen.
*  Titel des Rahmens auf "Einschränkungen" setzen.
*----------------------------------------------------------------------*
FORM standard_opt_init.

* set title for processing options frame
  PERFORM processing_options_text_set.
* set title for 'further selection criteria' frame
*  PERFORM further_sel_criteria_text_set.

* set selection text for parameter P_PROT_O
*  perform selection_text_p_prot_o_set.

ENDFORM.                    " standard_opt_init