*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_MAINTAIN_AEDAT                                    *
*----------------------------------------------------------------------*
* Changing date and name of the person who changed the delivery are
* maintained here (instead everywhere where the dataloss flag is set)
*
FORM maintain_aedat.

  DATA: lf_timestamp TYPE tzntstmps.
  FIELD-SYMBOLS: <ls_xlips> TYPE lipsvb,
                 <ls_xlikp> TYPE likpvb.

  GET TIME STAMP FIELD lf_timestamp.

  LOOP AT xlikp ASSIGNING <ls_xlikp>.
    IF <ls_xlikp>-updkz NA 'ID'.
      LOOP AT xlips ASSIGNING <ls_xlips>
                    WHERE vbeln EQ <ls_xlikp>-vbeln
                      AND updkz EQ updkz_update.
        <ls_xlips>-aedat = sy-datum.
*       SPE OUTB for the requirem. update a timestamp is required this
*       timestamp is filled with the date of the item creation/change
        <ls_xlips>-spe_process_date = lf_timestamp.
      ENDLOOP.

*       At least one item or the header have been updated...
      IF sy-subrc EQ 0 OR <ls_xlikp>-updkz EQ updkz_update.
        <ls_xlikp>-aedat = sy-datum.
        <ls_xlikp>-aenam = sy-uname.
*       If not we have new items and a new header: no change dates
      ELSE.
        CLEAR <ls_xlikp>-aedat.
        CLEAR <ls_xlikp>-aenam.
      ENDIF.
*   SPE OUTB for the requirem. update a timestamp is required this
*   timestamp is filled with the date of the item creation/change
    ELSEIF <ls_xlikp>-updkz EQ updkz_new.
      LOOP AT xlips ASSIGNING <ls_xlips>
                  WHERE vbeln EQ <ls_xlikp>-vbeln
                    AND updkz CA 'UI'.
        <ls_xlips>-spe_process_date = lf_timestamp.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

  READ TABLE xlikp INDEX 1.
  MOVE-CORRESPONDING xlikp TO likp.

ENDFORM.                    "MAINTAIN_AEDAT