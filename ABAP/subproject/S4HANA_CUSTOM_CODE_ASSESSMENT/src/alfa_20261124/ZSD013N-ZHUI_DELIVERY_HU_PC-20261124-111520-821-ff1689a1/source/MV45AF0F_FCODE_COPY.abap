*---------------------------------------------------------------------*
*       FORM FCODE_COPY                                               *
*---------------------------------------------------------------------*
*       Aufrufen des Kopierpopups                                     *
*---------------------------------------------------------------------*
FORM fcode_copy.

* je nach VBTYP unterschiedlichen Reiter vorschlagen
  IF tvak-vbtyp CA vbtyp_agan.
    fcode = fcode_kopieren_anfrage.
  ELSEIF tvak-vbtyp CA vbtyp_auftr.
    fcode = fcode_kopieren_angebot.
  ELSEIF tvak-vbtyp CA vbtyp_anfo.
    fcode = fcode_kopieren_faktura.
  ELSEIF tvak-vbtyp CA vbtyp_kont.
    fcode = fcode_kopieren_kontrakt.
  ELSEIF tvak-vbtyp CA vbtyp_reto.
    fcode = fcode_kopieren_auftrag.
  ELSEIF tvak-vbtyp CA vbtyp_kl.
    fcode = fcode_kopieren_auftrag.
  ELSE.
    fcode = fcode_kopieren_auftrag.
  ENDIF.
* Stärkerer Vorschlag: Wieder so, wie im Kopf kopiert wurde
  IF vbak-vgtyp CA vbtyp_anfr.
    fcode = fcode_kopieren_anfrage.
  ELSEIF vbak-vgtyp CA vbtyp_ange.
    fcode = fcode_kopieren_angebot.
  ELSEIF vbak-vgtyp CA vbtyp_auft.
    fcode = fcode_kopieren_auftrag.
  ELSEIF vbak-vgtyp CA vbtyp_lp.
    fcode = fcode_kopieren_lieferplan.
  ELSEIF vbak-vgtyp CA vbtyp_kont.
    fcode = fcode_kopieren_kontrakt.
  ELSEIF vbak-vgtyp CA vbtyp_fakt.
    fcode = fcode_kopieren_faktura.
  ENDIF.

* Bester Vorschlag: Bezug obligatorisch

  CASE tvak-bezob.
    WHEN chara. fcode = fcode_kopieren_anfrage.
    WHEN charb. fcode = fcode_kopieren_angebot.
    WHEN charc. fcode = fcode_kopieren_auftrag.
    WHEN chare. fcode = fcode_kopieren_lieferplan.
    WHEN charg. fcode = fcode_kopieren_kontrakt.
    WHEN charm. fcode = fcode_kopieren_faktura.
  ENDCASE.

* in case of cancellation we need to know origin in
* order to decide about initialize document or not
  DATA: lv_bildgruppe LIKE  t185-bldgr.
  DATA: lv_fcode_abbi TYPE c.

  CALL FUNCTION 'LOCATION_EXTRACT'
    IMPORTING
      bildgruppe = lv_bildgruppe.

  IF lv_bildgruppe = 'A0'.
    lv_fcode_abbi = 'X'.
    EXPORT lv_fcode_abbi TO MEMORY ID 'FCODE_ABBI'.
  ELSE.
    FREE MEMORY ID 'FCODE_ABBI'.
  ENDIF.

  PERFORM fcode_bearbeiten.

ENDFORM.                    "FCODE_COPY