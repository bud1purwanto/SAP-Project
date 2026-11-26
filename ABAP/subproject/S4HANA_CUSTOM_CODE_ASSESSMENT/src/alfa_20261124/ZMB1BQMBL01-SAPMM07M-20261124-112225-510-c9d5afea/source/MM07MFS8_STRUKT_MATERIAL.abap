*---------------------------------------------------------------------*
*       FORM STRUKT_MATERIAL                                          *
*---------------------------------------------------------------------*
*       Die Zerlegung strukturierten Materials wird vorbereitet.      *
*---------------------------------------------------------------------*
FORM strukt_material USING s-aktyp LIKE aktyp
                           s-tabix LIKE sy-tabix
                           s-azeil LIKE fuss-azeil.

  CHECK NOT ovm07m-kzwes = s AND NOT ovm07m-xstor = zwei AND
     ( ( aktyp = h AND s-aktyp = h ) OR ( aktyp = k AND s-aktyp = k ) )
     AND mseg-kzvbr IS INITIAL AND inventur IS INITIAL.
  a_zeile = omseg-zeile.
  PERFORM strukt_material_aufbereiten USING omseg-matbf
                                            omseg-werks
                                            omseg-lgort
                                            omseg-charg
                                           ovm07m-attyp
                                           ovm07m-bflme
                                           ovm07m-xchpf
                                            omseg-sobkz
                                           ovm07m-lbbsa
                                            omseg-shkzg
                                                s-tabix
                                                s-azeil
                                                  s.
  IF NOT odm07m-kzuml IS INITIAL.
    DATA: shkzg LIKE mseg-shkzg.
    IF omseg-shkzg = s.
      shkzg = h.
    ELSEIF omseg-shkzg = h.
      shkzg = s.
    ENDIF.
    PERFORM strukt_material_aufbereiten USING omseg-ummab
                                              omseg-umwrk
                                              omseg-umlgo
                                              omseg-umcha
                                             odm07m-umatt
                                             odm07m-umbflme
                                             odm07m-umxch
                                              omseg-umsok
                                             odm07m-umlbb
                                                    shkzg
                                                  s-tabix
                                                  s-azeil
                                                    u.
  ENDIF.

ENDFORM.