************************************************************************
*                                                                      *
* PBO Module zur Ablaufsteuerung - Kundenauftragsabwicklung            *
*     Module alphabetisch geordnet; hier Tabelle VBAP.                 *
*                                                                      *
************************************************************************

  INCLUDE mv45aoap_xvbap_aufsetzen .
  INCLUDE mv45aoap_vbap_bearbeiten_vor .
  INCLUDE mv45aoap_vbap_daten_beschaffen .
  INCLUDE mv45aoap_xvbap_exit_from_loop .
  INCLUDE mv45aoap_xvbap_lesen .
  INCLUDE mv45aoap_xvbap_lesen_sb .
  INCLUDE mv45aoap_xvbap_lesen_gruppe .
  INCLUDE mv45aoap_xvbex_dunkel .
  INCLUDE mv45aoap_xvbex_lesen .
* Payment Service Provider
  INCLUDE mv45aoap_xvbap_exit_loop_paysp.