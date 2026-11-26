*&---------------------------------------------------------------------*
*&      Form  vas_bestellpos_uebernehmen
*&---------------------------------------------------------------------*
*       text: record one subitem of a value added service in mseg_vas
*             and update main position
*----------------------------------------------------------------------*
FORM vas_bestellpos_uebernehmen CHANGING fuss_vas LIKE fuss.

  DATA: hfuss LIKE fuss,
        hmara LIKE mara,
        rc TYPE c VALUE space.

  DATA: changes_confirmed TYPE c VALUE 'X'.      "kh
  DATA: h_mblmg LIKE dm07m-mblmg,                "kh
        h_mblbm LIKE dm07m-mblbm,                "kh
        h_bpmng LIKE mseg-bpmng.                 "kh

* leave when called by MB_CREATE
  CHECK xmbwl IS INITIAL.                        " note 401256

* check subitem
  CHECK NOT (
*             xebefu-attyp = attyp-sam  or
*             xebefu-attyp = attyp-var  or
*             xebefu-attyp = attyp-vks  or  xebefu-attyp = attyp-lot  or
*             xebefu-attyp = attyp-dis  or
              xebefu-upvor = uptyp_lg
            ).
  IF NOT ( fuss_vas-ebeln  EQ  xebefu-ebeln  AND
           fuss_vas-ebelp  EQ  xebefu-uebpo ).
* update main position in fuss
    MOVE fuss TO hfuss.
    READ TABLE fuss WITH KEY ebeln = xebefu-ebeln
                             ebelp = xebefu-uebpo.
    IF sy-subrc IS INITIAL.
      CHECK NOT (
*                 fuss-attyp = attyp-sam  or
*                 fuss-attyp = attyp-var  or
*                 fuss-attyp = attyp-vks  or
*                 fuss-attyp = attyp-lot  or
*                 fuss-attyp = attyp-dis  or
                  fuss-upvor = uptyp_lg
                ).
      fuss-xvash = x.
      MODIFY fuss INDEX sy-tabix.
      IF sy-subrc IS INITIAL.
* memorize main position; update just necessary once
        MOVE fuss TO fuss_vas.
      ENDIF.
    ENDIF.
    MOVE hfuss TO fuss.
* worked on the main item without success -> forget about the subitem
    IF NOT sy-subrc IS INITIAL.
      rc = x.
    ENDIF.
  ENDIF.

  IF rc IS INITIAL.
* insert new subitem into vsa_mseg
    CLEAR vas_mseg.
    MOVE-CORRESPONDING xebefu TO vas_mseg.
    MOVE xebefu-bstme TO vas_mseg-erfme.
    MOVE xebefu-bsmng TO vas_mseg-bstmg.
    IF NOT ( x_avis IS INITIAL  AND  x_grobwe IS INITIAL ).
* take qty from shipping notification or rough goods receipt
      MOVE xebefu-lamng TO vas_mseg-erfmg.
    ELSEIF xebefu-bsmng NE xebefu-erfmg.

*     insertion by kh: compute quantity proposal
*                      ass seen in bestellung_uebernehmen_01
*                      missing fields are taken from main item
*                      or header data
      IF changes_confirmed EQ 'X'
      AND xebefu-erfmg IS INITIAL         "see bestellung_uebernehmen_01
      AND xebefu-noqty IS INITIAL.        "see bestellung_uebernehmen_01
*        in case of stock transfer orders WAMNG is 0 always
*        therefore fill it from glmng --> see in function module
         IF  xebefu-bsakz    EQ 'T'                              "sdp462
         AND xebefu-etens   IS INITIAL
         AND fuss_vas-retpo IS INITIAL
         AND xebefu-wamng   IS INITIAL
         AND fuss_vas-wamng EQ fuss_vas-glmng.
            MOVE xebefu-glmng TO xebefu-wamng.
         ENDIF.
         CALL FUNCTION 'MB_PROPOSE_RECEIPT_QUANTITY'
             EXPORTING
                 shkzg   = fuss_vas-shkzg
                 retpo   = fuss_vas-retpo
                 kzwes   = fuss_vas-kzwes
                 wesbs   = xebefu-wesbs
                 bpwes   = xebefu-bpwes
                 lfbnr   = fuss_vas-lfbnr
                 vlief   = h_liefk
                 lamng   = xebefu-lamng
                 lwmng   = xebefu-lwmng
                 lwsbs   = xebefu-lwsbs
                 etens   = xebefu-etens
                 bsakz   = xebefu-bsakz                          "sdp462
                 wemng   = xebefu-wemng
                 wamng   = xebefu-wamng
                 xselp   = fcausw-xselp
                 bsmng   = xebefu-bsmng
                 bpwem   = xebefu-bpwem
                 webre   = xebefu-webre
                 wesbb   = xebefu-wesbb
                 bpweb   = xebefu-bpweb
                 lwsbb   = xebefu-lwsbb
             IMPORTING
                 mblmg   = h_mblmg
                 mblbm   = h_mblbm
                 erfmg   = vas_mseg-erfmg
                 bpmng   = h_bpmng.
      ELSE.
*     end insertion by kh
         MOVE xebefu-bsmng TO vas_mseg-erfmg.
      ENDIF.
    ENDIF.
* get basis unit of measure and convert qty to basis uom
    PERFORM vas_basisme_umrechnen USING vas_mseg-erfmg
                                        vas_mseg-erfme
                                        xebefu-umren
                                        xebefu-umrez.
    APPEND vas_mseg.
  ENDIF.

ENDFORM.                    " vas_bestellpos_uebernehmen