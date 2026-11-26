*----------------------------------------------------------------------*
*   INCLUDE LMIGOEN5                                                   *
*   Environment: Targets
*----------------------------------------------------------------------*

METHOD reservation_show.
  CALL METHOD setget_save( 'RES RPO' ).
  SET PARAMETER ID 'RES' FIELD i_rsnum.
  SET PARAMETER ID 'RPO' FIELD space.
  CALL METHOD migo_call_transaction( i_tcode = 'MB23' ).
  CALL METHOD setget_restore.
ENDMETHOD.

METHOD order_show.
* Find the correct transaction to display order                  "323459
  CALL FUNCTION 'CO_SF_CALL_ORDER_CATEGORY'                      "323459
       EXPORTING                                                 "323459
            aufnr              = i_aufnr                         "323459
            aktyp              = a                               "323459
       EXCEPTIONS                                                "323459
            order_not_found    = 1                               "323459
            category_not_found = 2                               "323459
            OTHERS             = 3.                              "323459
  IF NOT sy-subrc IS INITIAL.                                    "323459
    MESSAGE s017(co) WITH i_aufnr.                               "323459
  ENDIF.                                                         "323459
ENDMETHOD.