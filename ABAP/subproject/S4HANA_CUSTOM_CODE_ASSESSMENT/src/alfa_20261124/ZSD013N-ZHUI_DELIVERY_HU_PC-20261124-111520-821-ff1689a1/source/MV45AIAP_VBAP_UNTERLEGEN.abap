*---------------------------------------------------------------------*
*       MODULE VBAP_UNTERLEGEN                                        *
*---------------------------------------------------------------------*
*       Vorschlagswerte den Eingabedaten unterlegen                   *
*---------------------------------------------------------------------*
module vbap_unterlegen.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  perform ende_ohne_pruefung using space
                             changing leave_without_check.
  check leave_without_check is initial.

  xvbap_loop_fcode = fcode.
  perform vbap_unterlegen(sapfv45p).

endmodule.                    "VBAP_UNTERLEGEN