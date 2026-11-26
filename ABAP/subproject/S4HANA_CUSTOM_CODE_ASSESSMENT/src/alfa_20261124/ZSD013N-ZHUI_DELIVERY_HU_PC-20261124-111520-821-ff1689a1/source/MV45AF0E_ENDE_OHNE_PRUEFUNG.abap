*----------------------------------------------------------------------*
*   INCLUDE MV45AF0E_ENDE_OHNE_PRUEFUNG                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ENDE_OHNE_PRUEFUNG
*&---------------------------------------------------------------------*
*       Bei entsprechendem Fcode wird im Dynpro die Funktion sofort
*       ausgeführt - in Formroutinen wird geprüft, ob die nachfolgenden
*       Verarbeitungsroutinen noch durchlaufen werden sollen und es
*       das Ergebnis der Prüfung wird nach außen gegeben
*----------------------------------------------------------------------*
FORM ENDE_OHNE_PRUEFUNG USING US_PROCESS_FCODE TYPE C
                        CHANGING CH_LEAVE TYPE C.

  DATA: DA_DYNP_KOPF(4) TYPE C.
  IF FCODE EQ FCODE_ENDE_OHNE_PRUEFUNG.
    IF CH_LEAVE IS INITIAL.
      IF VBAK-VBTYP = VBTYP_GRUKO.
        DA_DYNP_KOPF = '4022'.
      ELSE.
        DA_DYNP_KOPF = DYNP_PARTNER_KOPF.
      ENDIF.
      PERFORM DYNP_VALUES_READ USING 'SAPMV45A'
                                DA_DYNP_KOPF
                                'KUAGV-KUNNR'
                       CHANGING KUAGV-KUNNR
                                SY-SUBRC.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
                INPUT  = kuagv-kunnr
           IMPORTING
                OUTPUT = kuagv-kunnr.



      PERFORM DYNP_VALUES_READ USING 'SAPMV45A'
                                     DYNP_PARTNER_KOPF
                                     'KUWEV-KUNNR'
                            CHANGING KUWEV-KUNNR
                                     SY-SUBRC.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
                INPUT  = kuwev-kunnr
           IMPORTING
                OUTPUT = kuwev-kunnr.

      CH_LEAVE = CHARX.
    ENDIF.
    IF NOT US_PROCESS_FCODE IS INITIAL.
      PERFORM FUNKTION_AUSFUEHREN.
    ENDIF.
  ENDIF.

ENDFORM.                               " ENDE_OHNE_PRUEFUNG
