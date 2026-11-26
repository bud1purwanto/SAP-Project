*eject
*---------------------------------------------------------------------*
*       FORM TVTA_SELECT                                              *
*---------------------------------------------------------------------*
*       Verkaufsbereiche lesen                                        *
*---------------------------------------------------------------------*
FORM tvta_select USING us_vkorg
                       us_vtweg
                       us_spart.

* customer requirements don't have a sales area
  IF vbak-vbtyp EQ vbtyp_pbed.
    clear tvta.
  ELSE.
    CHECK: us_vkorg NE tvta-vkorg OR
           us_vtweg NE tvta-vtweg OR
           us_spart NE tvta-spart.

    SELECT SINGLE * FROM tvta WHERE vkorg = us_vkorg
                              AND   vtweg = us_vtweg
                              AND   spart = us_spart.
    IF sy-subrc NE 0.
      CLEAR tvta.
* Hilfsvariable vbapin-werks wird zur neuen Werksermittlung benötigt.
      VBAPIN-WERKS = VBAP-WERKS.

      MESSAGE e316 WITH us_vkorg us_vtweg us_spart.
    ENDIF.
  ENDIF.

ENDFORM.