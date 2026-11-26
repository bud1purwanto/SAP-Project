*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_FV50XFIN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_check_consolidator_portal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XLIKP  text
*      -->P_XLIPS  text
*      <--P_EV_BELEG_SICHERN_ABBRECHEN  text
*----------------------------------------------------------------------*
FORM spe_check_consolidator_portal  TABLES   xlikp STRUCTURE likpvb
                                             xlips STRUCTURE lipsvb.

*if returns delivery is for consolidator portal,
*LIPS-SPE_FOLLOW_UP must not be 1 or 2
*if it is, write log and cancel save
  IF xlikp-lgnum NE space AND
     xlikp-vlstk EQ space.
    LOOP AT xlips TRANSPORTING NO FIELDS
          WHERE vbeln = xlikp-vbeln         AND
                        komkz = space       AND
                        nopck NE space      AND
                        spe_follow_up CA '12' .
    ENDLOOP.
*SPE_FOLLOW_UP has incorrect value, cancel saving & write log
    IF sy-subrc EQ 0.
*Default follow-up activity of delivery &1 not supported for consolidator
      PERFORM finchdel_handling(sapfv50p)
              USING xlikp-vbeln '98' "VBELN PRUEFUNG
                    'E' '/SPE/RET' '133'   "MSGTY MSGID MSGNO
                    xlikp-vbeln space space  space "MSGV1 MSGV2 MSGV3 MSGV4
                    gt_finchdel.
      RETURN.
    ENDIF.
  ENDIF.


ENDFORM.                    " spe_check_consolidator_portal