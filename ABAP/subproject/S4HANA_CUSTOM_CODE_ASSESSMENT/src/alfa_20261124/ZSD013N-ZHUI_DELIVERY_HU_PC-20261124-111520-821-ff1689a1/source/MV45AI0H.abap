*-------------------------------------------------------------------
***INCLUDE MV45AI0H .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Module  HIGHEST_RELEASE_CHANGE INPUT
*&---------------------------------------------------------------------*
*       Höchste Freigabe-FZ wird manuell geändert                      *
*----------------------------------------------------------------------*
MODULE HIGHEST_RELEASE_CHANGE INPUT.

  DATA: DA_HIFFZ(19) TYPE C,
        DA_HIMFZ(19) TYPE C,
        DA_HILFZ(19) TYPE C.

  IF VBLB-HIFFZ NE *VBLB-HIFFZ.
    WRITE *VBLB-HIFFZ TO DA_HIFFZ UNIT VBAP-VRKME LEFT-JUSTIFIED.
    MESSAGE I623 WITH TEXT-228 DA_HIFFZ.
* Änderung der höchsten Fertigungsfreigabe-FZ  - siehe Langtext
  ENDIF.

  IF VBLB-HIMFZ NE *VBLB-HIMFZ.
    WRITE *VBLB-HIMFZ TO DA_HIMFZ UNIT VBAP-VRKME LEFT-JUSTIFIED.
    MESSAGE I623 WITH TEXT-227 DA_HIMFZ.
* Änderung der höchsten Materialfreigabe-FZ  - siehe Langtext
  ENDIF.

  IF VBLB-HILFZ NE *VBLB-HILFZ.
    WRITE *VBLB-HILFZ TO DA_HILFZ UNIT VBAP-VRKME LEFT-JUSTIFIED.
    MESSAGE I623 WITH TEXT-229 DA_HILFZ.
* Änderung der höchsten Lieferfreigabe-FZ  - siehe Langtext
  ENDIF.

ENDMODULE.                             " HIGHEST_RELEASE_CHANGE INPUT