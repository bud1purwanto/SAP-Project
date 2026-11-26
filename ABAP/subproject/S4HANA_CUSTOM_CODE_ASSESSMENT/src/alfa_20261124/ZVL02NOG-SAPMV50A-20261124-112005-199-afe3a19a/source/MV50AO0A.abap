************************************************************************
*                                                                      *
* PBO Module Lieferabwicklung                                          *
*     Module alphabetisch geordnet; hier mit "A" beginnend             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE ANLIEFERZEIT_ANZ                                       *
*---------------------------------------------------------------------*
*       Anzeigen der Anlieferzeiten gemäß Liefertermin                *
*---------------------------------------------------------------------*
module anlieferzeit_anz output.

  perform anlieferzeit_anzeigen.

endmodule.                    "ANLIEFERZEIT_ANZ OUTPUT
*eject

*---------------------------------------------------------------------*
*       MODULE AUFT_PARM_LOESCHEN                                     *
*---------------------------------------------------------------------*
*       Auftragsnummer + Position loeschen                            *
*---------------------------------------------------------------------*
module auft_parm_loeschen output.

  lv50c-vbeln = space.
  lv50c-abpos = space.
  lv50c-bipos = space.
  if lv50c-datbi = '00000000'.
*   WRITE SY-DATUM TO LV50C-DATBI DD/MM/YYYY.
    lv50c-datbi = sy-datlo.
  endif.
endmodule.                    "AUFT_PARM_LOESCHEN OUTPUT
*eject
*&---------------------------------------------------------------------*
*&      Module  ALW_ANZEIGEN  OUTPUT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
module alw_name_anzeigen output.

  perform alw_name_anzeigen.

endmodule.                             " ALW_NAME_ANZEIGEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  APPOINTMENT_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module appointment_check input.

ENHANCEMENT-SECTION     MV50AO0A_01 SPOTS ES_SAPMV50A.
  perform appointment_check using likp-lgnum
                                  likp-lgtor
                                  rv50a-lfdat_la
                                  rv50a-lfuhr_la.
END-ENHANCEMENT-SECTION.

endmodule.                 " APPOINTMENT_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  assign_icon  OUTPUT
*&---------------------------------------------------------------------*
*       Assigns icon with tooltip text to table fields with icons
*----------------------------------------------------------------------*
module assign_icon output.

  perform assign_icon using    xlips
                               tvpodvb
                      changing rv50a.

endmodule.                 " assign_icon  OUTPUT