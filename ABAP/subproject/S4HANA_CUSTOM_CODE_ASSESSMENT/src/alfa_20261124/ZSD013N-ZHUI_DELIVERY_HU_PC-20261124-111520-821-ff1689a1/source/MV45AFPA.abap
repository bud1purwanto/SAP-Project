************************************************************************
*                                                                      *
* Unterroutinen fuer die Kundenauftragsabwicklung                      *
*     Routinen für die Partnerverarbeitung                             *
*                                                                      *
************************************************************************
  include mv45afpa_xvbpa_aufbauen_addr1.
  INCLUDE MV45AFPA_XVBPA_AUFBAUEN_VBPAKO .
  include mv45afpa_xvbpa_determine_txjcd.
  include mv45afpa_xvbpa_partner_check.
  INCLUDE MV45AFPA_XVBPA_PRUEFEN .

*eject
*----------------------------------------------------------------------*
* FORM XVBPA_BESORGEN                                                  *
*----------------------------------------------------------------------*
* This routine will be called from fm SD_SALESDOCUMENT_CHANGE, there   *
* the internal partnertable is needed.                                 *
*----------------------------------------------------------------------*
form xvbpa_besorgen tables txvbpa structure vbpavb.

     txvbpa[] = xvbpa[].

endform.