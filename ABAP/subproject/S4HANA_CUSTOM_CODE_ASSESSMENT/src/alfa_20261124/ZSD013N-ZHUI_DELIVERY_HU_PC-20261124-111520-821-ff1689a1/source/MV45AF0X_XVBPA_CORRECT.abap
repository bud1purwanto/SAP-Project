*---------------------------------------------------------------------*
*       FORM XVBPA_CORRECT                                            *
*---------------------------------------------------------------------*
* In BAPI create case , the table XVBPA must be checked. It can happen*
* that an item XVBPA entry was created without the corresponding      *
* item XVBAP, in case of an error. Then the xvbpa entry must be       *
* deleted.                                                            *
* Please see note 626563.                                             *
*---------------------------------------------------------------------*
form xvbpa_correct.
     loop at xvbpa where posnr ne posnr_low and
                         updkz eq chari.
          read table xvbap with key posnr = xvbpa-posnr.
          if sy-subrc ne 0.
             delete xvbpa where posnr = xvbpa-posnr.
          endif.
     endloop.
endform.