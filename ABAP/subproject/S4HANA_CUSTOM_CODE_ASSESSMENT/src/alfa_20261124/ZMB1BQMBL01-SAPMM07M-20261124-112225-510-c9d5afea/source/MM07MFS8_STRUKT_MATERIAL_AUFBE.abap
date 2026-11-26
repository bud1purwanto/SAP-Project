*eject
*---------------------------------------------------------------------*
*       FORM STRUKT_MATERIAL_AUFBEREITEN                              *
*---------------------------------------------------------------------*
*       Das strukturierte Material wird aufbereitet.                  *
*---------------------------------------------------------------------*
FORM strukt_material_aufbereiten USING s-matbf LIKE mseg-matbf
                                       s-werks LIKE mseg-werks
                                       s-lgort LIKE mseg-lgort
                                       s-charg LIKE mseg-charg
                                       s-attyp LIKE vm07m-attyp
                                       s-bflme LIKE vm07m-bflme
                                       s-xchpf LIKE vm07m-xchpf
                                       s-sobkz LIKE mseg-sobkz
                                       s-lbbsa LIKE vm07m-lbbsa
                                       s-shkzg LIKE mseg-shkzg
                                       s-tabix LIKE sy-tabix
                                       s-azeil LIKE fuss-azeil
                                       s-xauto LIKE mseg-xauto.

  PERFORM strukt_material_vorbereiten USING s-matbf
                                            s-werks
                                            s-lgort
                                            s-charg
                                            s-attyp
                                            s-bflme
                                            s-xchpf
                                            s-sobkz
                                            s-lbbsa
                                            s-shkzg
                                            s-xauto
                                              rc
                                         mkpf-budat.
  CHECK rc IS INITIAL.
*                           * In cases of STRUCTURED ARTICLES   "389851
*                           * new lines will expand in yfuss;   "389851
*                           * the number of added lines is      "389851
*                           * represented by the offset of      "389851
*                           * s-azeil.                          "389851
*                           * Empties can possibly be found in  "389851
*                           * the following loop over zfuss.    "389851
*                           * Existing urzei for empties need   "389851
*                           * to recalculate. This has to be    "389851
*                           * done for mb_create because for    "389851
*                           * dialogs renumbering will done     "389851
*                           * automatically                     "389851
  DATA: URZEI_OFFSET LIKE MSEG-URZEI,                           "389851
        AZEIL_OLD    LIKE fuss-azeil.                           "389851
  AZEIL_OLD = s-azeil .                                         "389851

  REFRESH fuss.
  LOOP AT yfuss.
    fuss = yfuss.
    fuss-tabix = s-tabix.
    fuss-azeil = s-azeil = s-azeil + 1.
    APPEND fuss.
  ENDLOOP.

  URZEI_OFFSET = S-AZEIL - AZEIL_OLD.                           "389851

  LOOP AT zfuss.
    fuss = zfuss.

    IF NOT XMBWL IS INITIAL.                                    "389851
       IF    FUSS-XAUTO = L                                     "389851
          OR FUSS-XAUTO = F                                     "389851
          OR FUSS-XAUTO = W                                     "389851
          OR FUSS-XAUTO = M.                                    "389851
*                           * old urzei need a offset, created  "389851
*                           * by expanded structured articels   "389851
          FUSS-URZEI = FUSS-URZEI + URZEI_OFFSET.               "389851
       ENDIF.                                                   "389851
    ENDIF.                                                      "389851

    IF NOT fuss-xlaus IS INITIAL.
      LOOP AT ylgort WHERE zeile = zfuss-zeile
                     AND   xselp NE space.
        fuss = zfuss.
        MOVE-CORRESPONDING ylgort TO fuss.
        CLEAR fuss-xlaus.
        fuss-fcode = fcod-np.
        fuss-xselk = x.
        f_zeile = f_zeile + 1.
        s_zeile = s_zeile + 1.
        fuss-zeile = f_zeile.
        APPEND fuss.
      ENDLOOP.
    ELSE.
      APPEND fuss.
    ENDIF.
    FREE: ylgort.
  ENDLOOP.
  f_zeile = f_zeile + y_zeile.
  s_zeile = s_zeile + y_zeile.
  FREE: yfuss, zfuss.

ENDFORM.