                                                            "v_n_1657178
*&---------------------------------------------------------------------*
*&  Include           MV50AFZT
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM USEREXIT_TEXT_INPUT_CHANGE                               *
*---------------------------------------------------------------------*
*       With note 1565880 the texts are no longer changeable after    *
*       the delivery is GI posted. This userexit can be used to       *
*       make the texts changeable.                                    *
*                                                                     *
*       cf_display_flag = ' ' - change mode                           *
*       cf_display_flag = 'X' - display mode                          *
*                                                                     *
*       You can use for example delivery header status (table xvbuk)  *
*       to determine change mode.                                     *
*                                                                     *
*  !!!  Please change only parameter cf_display_flag.                 *
*  !!!  Please avoid to change any other variable, internal table, or *
*  !!!  header lines of internal tables.                              *
*                                                                     *
*---------------------------------------------------------------------*
FORM userexit_text_input_change CHANGING cf_display_flag LIKE charx.

* example - switch on change mode for texts as long as goods issue
*           and invoice are not completed.
*
*data: ls_xvbuk like line of xvbuk.
*
*  read table xvbuk into ls_xvbuk
*                   with key vbeln = likp-vbeln.
*
*  IF ls_xvbuk-wbstk NE charc AND
*     ls_xvbuk-fkstk NE charc.
*    CLEAR cf_display_flag.
*  ENDIF.

ENDFORM.                                                    "^_n_1657178