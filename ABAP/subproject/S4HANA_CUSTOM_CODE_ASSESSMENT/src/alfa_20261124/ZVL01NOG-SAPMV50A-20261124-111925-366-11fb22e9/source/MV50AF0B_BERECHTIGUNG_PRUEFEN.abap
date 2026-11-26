*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BERECHTIGUNG_PRUEFEN                              *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM BERECHTIGUNG_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Die Versandberechtigungen werden geprüft                      *
*           -Berechtigung auf Versandstelle                           *
*---------------------------------------------------------------------*
FORM berechtigung_pruefen USING bp_actvt TYPE c
                                bp_subrc LIKE sy-subrc.

  bp_subrc = 0.

ENHANCEMENT-POINT BERECHTIGUNG_PRUEFEN_01 SPOTS ES_SAPMV50A.
* Aktivität für Berechtigung setzen falls notwendig
  IF bp_actvt = space.
    CASE t180-trtyp.
      WHEN charh.
*      Anlegen
        bp_actvt = actvt_01.
      WHEN charv.
*      Ändern
        bp_actvt = actvt_02.
      WHEN chara.
*      Anzeigen
        bp_actvt = actvt_03.
    ENDCASE.
  ENDIF.

* Berechtigung für diese Aktion in dieser Versandstelle
  AUTHORITY-CHECK OBJECT 'V_LIKP_VST'
       ID 'VSTEL' FIELD likp-vstel
       ID 'ACTVT' FIELD bp_actvt.

* Keine Berechtigung
  IF sy-subrc NE 0.
    bp_subrc = sy-subrc.
    IF bp_actvt NE actvt_04.
      PERFORM lieferung_entsperren USING likp-vbeln.
    ENDIF.
    CASE bp_actvt.
      WHEN actvt_01.
        MESSAGE e080 WITH likp-vstel.
      WHEN actvt_02.
        perform message_handling(sapmv50a) using cvbap-posnr "v_n_865740
                                                 '081'
                                                 'E'
                                                 'VL'
                                                 likp-vstel
                                                 space
                                                 space
                                                 space.      "^_n_865740
      WHEN actvt_03.
        perform message_handling(sapmv50a) using cvbap-posnr "v_n_865740
                                                 '082'
                                                 'E'
                                                 'VL'
                                                 likp-vstel
                                                 space
                                                 space
                                                 space.      "^_n_865740
      WHEN actvt_04.
*       MESSAGE E087 WITH LIKP-VSTEL.
    ENDCASE.
  ENDIF.


ENDFORM.                    "BERECHTIGUNG_PRUEFEN