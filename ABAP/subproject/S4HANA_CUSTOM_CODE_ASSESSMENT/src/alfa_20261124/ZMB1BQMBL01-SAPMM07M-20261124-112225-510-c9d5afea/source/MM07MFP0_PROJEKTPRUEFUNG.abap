*&---------------------------------------------------------------------*
*&      Form  PROJEKTPRUEFUNG
*&---------------------------------------------------------------------*
*  Projekt prüfen
*----------------------------------------------------------------------*
FORM PROJEKTPRUEFUNG USING   P_MSEG STRUCTURE MSEG
                             P_MKPF STRUCTURE MKPF
                             L_PSPNR LIKE MSEG-PS_PSP_PNR
                             L_KZBWS LIKE MSEG-KZBWS.
  DATA: I_COBL LIKE COBL.
  DATA: E_COBL LIKE COBL.

  i_cobl-vorgn   = rw_vorgang.                              "HW 420778
  i_cobl-awtyp   = rw_awtyp.                                "HW 1125184

  MOVE-CORRESPONDING P_MSEG TO I_COBL.
  MOVE-CORRESPONDING P_MKPF TO I_COBL.
  I_COBL-PS_PSP_PNR = L_PSPNR.
  CALL FUNCTION 'K_COBL_CHECK'
       EXPORTING
            I_COBL = I_COBL
       IMPORTING
            E_COBL = E_COBL
       EXCEPTIONS
            OTHERS = 0.
  L_KZBWS = E_COBL-KZBWS.

ENDFORM.