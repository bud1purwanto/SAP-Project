*---------------------------------------------------------------------*
*       FORM FCODE_IAAN                                               *
*---------------------------------------------------------------------*
*       Anlegen Auftraggeber                                          *
*---------------------------------------------------------------------*
FORM FCODE_IAAN.

  CONSTANTS: DA_TCODE LIKE SY-TCODE VALUE 'VD01'.
  DATA: DA_KTOKD LIKE RF02D-KTOKD,
        DA_AUTHORITY_SUBRC LIKE SY-SUBRC,
        DA_KUNNR LIKE KUAGV-KUNNR.
  DATA: BDCDATA TYPE TABLE OF BDCDATA.
  DATA: DA_OPT LIKE CTU_PARAMS.

* Aktuellen Wert vom Dynpro holen (ggf. noch kein Feldtransport)
ENHANCEMENT-SECTION     FCODE_IAAN_10 SPOTS ES_SAPMV45A.

  PERFORM DYNP_VALUES_READ USING SY-REPID
                                 DYNP_PARTNER_KOPF
                                 'KUAGV-KUNNR'
                        CHANGING KUAGV-KUNNR
                                 SY-SUBRC.
END-ENHANCEMENT-SECTION.

  IF VBAK-KUNNR NE KUAGV-KUNNR.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = KUAGV-KUNNR
      IMPORTING
        OUTPUT = KUAGV-KUNNR.
  ENDIF.

* Redetermine TVTA in case it was initialized
  IF TVTA IS INITIAL.
    IF NOT VBAK-VKORG IS INITIAL AND
       NOT VBAK-VTWEG IS INITIAL AND
       NOT VBAK-SPART IS INITIAL.

      PERFORM TVTA_SELECT USING VBAK-VKORG
                                VBAK-VTWEG
                                VBAK-SPART.
    ENDIF.
  ENDIF.

  SET PARAMETER ID 'KUN' FIELD KUAGV-KUNNR.
  SET PARAMETER ID 'VKO' FIELD TVTA-VKORG.
  SET PARAMETER ID 'VTW' FIELD TVTA-VTWKU.
  SET PARAMETER ID 'SPA' FIELD TVTA-SPAKU.
  GET PARAMETER ID 'KGD' FIELD DA_KTOKD.
  IF DA_KTOKD IS INITIAL.
    SET PARAMETER ID 'KGD' FIELD '0001'.
  ENDIF.

* Berechtigung pruefen
  PERFORM CHECK_AUTHORITY_TRANS USING DA_TCODE
                             CHANGING DA_AUTHORITY_SUBRC.

  IF DA_AUTHORITY_SUBRC EQ 0.
* Transaktionsaufruf nicht über Folgebildsteuerung, da:
* - Rückgabe der Kundennummer nicht möglich
* - Dateneingabe bei Exit-Fcode verloren gehen

    DA_OPT-DISMODE = 'A'.
    DA_OPT-UPDMODE = 'S'.
    DA_OPT-NOBINPT = 'X'.
    CALL TRANSACTION DA_TCODE USING BDCDATA OPTIONS FROM DA_OPT.

    CALL FUNCTION 'KNVV_REFRESH_BUFFER'
      .

    GET PARAMETER ID 'KUN' FIELD DA_KUNNR.
    IF NOT DA_KUNNR IS INITIAL AND
       DA_KUNNR NE KUAGV-KUNNR AND
       DA_KUNNR NE 'INTERN'.
      KUAGV-KUNNR = DA_KUNNR.

* Neuen Wert auf Dynpro zurückstellen (für Feldtransport bereitstellen)
ENHANCEMENT-SECTION     FCODE_IAAN_11 SPOTS ES_SAPMV45A.

      PERFORM DYNP_VALUES_UPDATE USING SY-REPID
                                       DYNP_PARTNER_KOPF
                                       'KUAGV-KUNNR'
                                       KUAGV-KUNNR
                              CHANGING SY-SUBRC.
END-ENHANCEMENT-SECTION.

    ENDIF.
  ELSE.
    MESSAGE I001(V10) WITH DA_TCODE.
  ENDIF.


ENDFORM.                    "FCODE_IAAN