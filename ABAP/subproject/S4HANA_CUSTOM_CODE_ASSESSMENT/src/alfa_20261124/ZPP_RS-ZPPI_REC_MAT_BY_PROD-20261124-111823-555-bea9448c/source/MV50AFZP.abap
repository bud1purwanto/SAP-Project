                                                            "v_n_693000
*&--------------------------------------------------------------------*
*&  Include           MV50AFZP                                        *
*&--------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_KOMKD                             *
*---------------------------------------------------------------------*
*       This userexit can be used to modify change mode of pricing    *
*       screens in delivery processing.                               *
*       cf_pricing_no_change = ' ' - change mode                      *
*       cf_pricing_no_change = 'X' - display mode                     *
*                                                                     *
*       You can use for example delivery header status (table xvbuk)  *
*       to determine change mode.                                     *
*                                                                     *
*  !!!  Please change only parameter cf_pricing_no_change.            *
*  !!!  Please avoid to change any other variable, internal table, or *
*  !!!  header lines of internal tables.                              *
*                                                                     *
*---------------------------------------------------------------------*
FORM userexit_pricing_screen_input
                             CHANGING cf_pricing_no_change LIKE charx.

* example - switch on change mode for pricing screens
*           if goods issue is posted and no invoice is created.
*
*data: ls_xvbuk like line of xvbuk.
*
*  read table xvbuk into ls_xvbuk
*                   with key vbeln = likp-vbeln
*                   binary search.
*
*  IF xvbuk-wbstk EQ charc AND
*     xvbuk-fkstk EQ chara.
*    CLEAR cf_pricing_no_change.
*  ENDIF.

ENDFORM.                                                    "^_n_693000