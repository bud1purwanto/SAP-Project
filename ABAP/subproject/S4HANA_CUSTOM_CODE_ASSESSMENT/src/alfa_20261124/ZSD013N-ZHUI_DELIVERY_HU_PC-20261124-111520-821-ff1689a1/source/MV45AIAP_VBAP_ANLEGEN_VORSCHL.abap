*---------------------------------------------------------------------*
*       MODULE VBAP_ANLEGEN_VORSCHL                                   *
*---------------------------------------------------------------------*
*       Fcode VBAP_ANLEGEN wird vorgeschlagen, wenn in die letzte     *
*       Zeile eine Position eingegeben und kein Fcode eingegeben wurde*
*---------------------------------------------------------------------*
MODULE VBAP_ANLEGEN_VORSCHL.

  data: da_lines type i,
        diff type i.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  IF VBAP-POSNR > 0 AND
     ( *VBAP-POSNR IS INITIAL OR
     ( NOT NEW_ITEM_TO_SCROLL IS INITIAL AND
       STRUKTUR_ANGELEGT IS INITIAL ) ) AND
     SY-LOOPC = SY-STEPL AND
     FCODE = FCODE_GLEICHE_SEITE AND
     ( NOT XVBAP_UMFANG_OPV IS INITIAL OR
*      Produktvorschlag ist aktiv (--> DPP_ACTIVE = 'X')
*      jedoch ausgeblendet (--> XVBAP_UMFANG_OPV = 'X')
       DPP_ACTIVE IS INITIAL AND
       XVBAP_UMFANG_OPV IS INITIAL ).
*      kein Produktvorschlag
    FCODE = FCODE_XVBAP_ANLEGEN.
  ENDIF.

* set fcode when no free lines left after BOM explosion
* not in EDI case
* not when product proposal is active
  if struktur_angelegt = charx and
     ( *vbap-posnr is initial or
       not new_item_to_scroll is initial ) and
     sy-binpt is initial and
     ( not xvbap_umfang_opv is initial or
       dpp_active is initial and
       xvbap_umfang_opv is initial ).
    describe table ivbap lines da_lines.
    if not IVBAP_TABIX_ZEILE_1 is initial.
      diff = da_lines - IVBAP_TABIX_ZEILE_1 + 1.
    else.
      diff = da_lines.
    endif.
    if diff >= sy-loopc.
      FCODE = FCODE_XVBAP_ANLEGEN.
    endif.
  endif.

  CLEAR NEW_ITEM_TO_SCROLL.

ENDMODULE.