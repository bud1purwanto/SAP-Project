*----------------------------------------------------------------------*
*       FORM M-SEGMENT_ZUORDNEN                                        *
*----------------------------------------------------------------------*
*       Das M-Segment wird dem F-Segment zugeordnet.                   *
*       Ist das M-Segment nicht zu verbuchen, wird RC = 8 gesetzt.     *
*----------------------------------------------------------------------*

* incomplete MM documents created for stock transport order "n588116
* with account assignment during one-step stock transfer    "n588116

FORM m-segment_zuordnen USING m-xumbw TYPE c.

* define local working areas                                "MAA2
  DATA : lv_flag_maa_active            TYPE  abap_bool.     "MAA2

ENHANCEMENT-POINT M-SEGMENT_ZUORDNEN_01 SPOTS ES_SAPMM07M STATIC.
  rc = 4.
ENHANCEMENT-SECTION     M-SEGMENT_ZUORDNEN_02 SPOTS ES_SAPMM07M.
  LOOP AT yfbuz WHERE zeile = ymbuz-zeile
                AND   xumbw = m-xumbw.
    IF yfbuz-buzid = m AND NOT xmseg-xauto = x.
      rc = 0.
      EXIT.
    ENDIF.
    IF yfbuz-buzid = u AND xmseg-xauto = x.
      rc = 0.
      EXIT.
    ENDIF.
  ENDLOOP.
END-ENHANCEMENT-SECTION.
  IF NOT rc = 0.
    CLEAR yfbuz.
  else.                                               "note 525347
    perform jv_m_seg_zuordnen using m-xumbw.          "note 525347
  ENDIF.
  check_secon.

* this CHECK command should check whether the internal      "n588116
* items for MM documents to be created will not change any  "n588116
* objects in the database                                   "n588116
* -> true  : ignore this item and delete it                 "n588116
* -> false : take this item                                 "n588116
* CHECK ( ( xmseg-mengu IS INITIAL AND NOT xmseg-wertu IS INITIAL
*       AND xmseg-vkwrt = 0 ) OR
*       ( xmseg-erfmg = 0 AND xmseg-menge = 0 AND NOT
*       ( xmseg-mengu IS INITIAL AND NOT xmseg-wertu IS INITIAL ) ) )
*       AND yfbuz-dmbtr IS INITIAL AND yfbuz-bualt IS INITIAL
*                                  AND xmseg-kzear = xvm07m-kzear_old
*                                  AND ( xmseg-elikz = xvm07m-elikz_old
*                                  OR ( zdm07m-elikz_input IS INITIAL
*                                       AND xmbwl IS INITIAL ) ).
* now this CHECK command is a readable form :               "n588116
ENHANCEMENT-SECTION M-SEGMENT_ZUORDNEN_05 SPOTS ES_SAPMM07M .
  CHECK                                                     "n588116
* 1. with account assignment, no update of quantities, ...  "n588116
  ( (     xmseg-mengu IS INITIAL  AND                       "n588116
      NOT xmseg-wertu IS INITIAL  AND                       "n588116
          xmseg-vkwrt = 0 )                                 "n588116
    OR                                                      "n588116
    ( xmseg-erfmg = 0 AND                                   "n588116
      xmseg-menge = 0 AND                                   "n588116
      NOT (     xmseg-mengu IS INITIAL AND                  "n588116
            NOT xmseg-wertu IS INITIAL ) ) )                "n588116
                                                            "n588116
* 2. no amount in local currency                            "n588116
   AND yfbuz-dmbtr IS INITIAL                               "n588116
                                                            "n588116
* 3. no amount in alternative currency                      "n588116
   AND yfbuz-bualt IS INITIAL                               "n588116
                                                            "n588116
* 4. no change of final issue indicator                     "n588116
   AND xmseg-kzear = xvm07m-kzear_old                       "n588116
                                                            "n588116
* 5. no change of inward delivery completed indicator       "n588116
   AND ( xmseg-elikz = xvm07m-elikz_old                     "n588116
       OR                                                   "n588116
       ( zdm07m-elikz_input IS INITIAL AND                  "n588116
         xmbwl IS INITIAL ) ).                              "n588116
END-ENHANCEMENT-SECTION.
                                                            "n588116
* allow partial GR for value article with price 0            "747291
  IF xmseg-kzbew = 'B'                                       "747291
     AND     xmseg-mengu IS INITIAL                          "747291
     AND NOT xmseg-wertu IS INITIAL                          "747291
     AND NOT xmseg-erfmg IS INITIAL.                         "747291
    EXIT.                                                    "747291
  ENDIF.                                                     "747291
                                                             "747291
* does this item belongs to a stock transport order with    "n588116
* account assignment  ?                                     "n588116
  if      xvm07m-pstyp = '7'       and                      "n588116
      not zdm07m-knttp is initial  and                      "n588116
      not xmseg-erfmg  is initial.                          "n588116
*   yes, take this item and leave this inhospitable place   "n588116
    exit.                                                   "n588116
  endif.                                                    "n588116
                                                            "n588116
* valuation only article with zero value and quantity       "1132081
* results in a dummy material document only for documentary "1132081
* reasons, read note 1132081 for the whole story            "1132081
  IF xmseg-erfmg IS INITIAL                                 "1132081
       AND     xmseg-menge IS INITIAL                       "1132081
       AND     xmseg-exvkw IS INITIAL                       "1132081
       AND     xmseg-vkwrt IS INITIAL                       "1132081
       AND     xmseg-kzbew = 'B'                            "1132081
       AND     xmseg-mengu IS INITIAL                       "1132081
       AND NOT xmseg-wertu IS INITIAL                       "1132081
       AND     vm07m-xvkbw = X.                             "1132081
           EXIT.                                            "1132081
  ENDIF.                                                    "1132081
                                                            "1132081
* in case this line is reached the item will be deleted     "n588116
* when it does not concern to subcontracting                "n588116

* --- begin ----------------------------------------------- MAA2
* check whether the business function multi account assignment
* is active
  CALL METHOD cl_ops_switch_check=>mm_sfws_maa
    RECEIVING
      rv_active = lv_flag_maa_active.

  IF      lv_flag_maa_active =  abap_true  AND
      NOT xmseg-xmacc        IS INITIAL    AND
      NOT xmseg-maa_urzei    IS INITIAL    AND
          xmseg-kzbew        =  'B'.
*   some XMSEG entries for valuated GR postings for MAA PO
*   item could contain ERFMG = 0 but a small quantity in
*   field dm07m-erfmg_abd
    IF  xmseg-erfmg     > 0  OR
        dm07m-erfmg_abd > 0.
      EXIT.        " MAA quantity ok -> leave
    ENDIF.
  ENDIF.
* --- end ------------------------------------------------- MAA2

  IF xmseg-kzbew = o.
    LOOP AT zeklb WHERE zeilo = xmseg-zeile
                  AND NOT erfmg = 0.
      EXIT.
    ENDLOOP.
    CHECK NOT sy-subrc IS INITIAL.
  ENDIF.

ENHANCEMENT-POINT EHP_MM07MFM0_M_SEGMENT_ZUOR_01 SPOTS ES_SAPMM07M.

ENHANCEMENT-POINT M-SEGMENT_ZUORDNEN_03 SPOTS ES_SAPMM07M.
  rc = 8.

ENHANCEMENT-POINT M-SEGMENT_ZUORDNEN_04 SPOTS ES_SAPMM07M.
ENDFORM.