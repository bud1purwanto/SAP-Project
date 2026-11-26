*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_PRDS                                        *
*----------------------------------------------------------------------*
form fcode_prds.

  data: lf_psid type ps_pspid.

  case taxi_screen_group.
    when c_taxi_scrgrp_item.
      lf_psid = gs_lips_main-pspnr.
    when c_taxi_scrgrp_batch.
      lf_psid = gs_lips_chsp-pspnr.
  endcase.

  call function 'CJPN_INTERN_TO_EXTERN_PDCONV'              "HP_366019
       exporting
            int_num = lf_psid
       importing
            ext_num = lf_psid.

  set parameter id 'PSP' field lf_psid.

  call transaction 'CJ03' and skip first screen.

endform.