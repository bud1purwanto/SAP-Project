*---------------------------------------------------------------------*
*       FORM XVBPA_AUFBAUEN_ADDR1                                     *
*---------------------------------------------------------------------*
* Die Belegadressen und die Belegpartnertabelle werden aus Kommunika- *
* tionsfeldern angelegt.                                              *
* Der Aufruf erfolgt aus den FBs SD_SALES_HEADER_MAINTAIN und         *
* SD_SALES_ITEM_MAINTAIN.                                             *
* Als Eingabe werden die kopf- oder die positionsbezogenen Daten      *
* erwartet.                                                           *
*---------------------------------------------------------------------*
form xvbpa_aufbauen_addr1 tables us_tvbpa2kom  structure vbpa2kom
                                 us_tbapiaddr1 structure bapiaddr1
                                 ch_tsadrvb    structure sadrvb
                                 us_tvbpa3kom  structure vbpa3kom.

data: t_vbpavb   like vbpavb occurs 0 with header line,
      da_vbpakom like vbpakom,
      da_vbpa3kom like vbpa3kom.
data: t_error_table   type addr_error occurs 0,
      da_error_line   like addr_error.

* Vorerst können Partner nicht geändert werden
*    CHECK T180-TRTYP = CHARH.
* 1. check / modify the tax juridiction code
     loop at us_tbapiaddr1 where taxjurcode is initial.

          if not us_tbapiaddr1-postl_cod1 is initial and
             not us_tbapiaddr1-country    is initial and
             not us_tbapiaddr1-region     is initial.

             da_vbpakom-txjcd = us_tbapiaddr1-taxjurcode.
             da_vbpakom-land1 = us_tbapiaddr1-country.
             da_vbpakom-regio = us_tbapiaddr1-region.
             da_vbpakom-pstlz = us_tbapiaddr1-postl_cod1.
             da_vbpakom-ort01 = us_tbapiaddr1-city.
             da_vbpakom-ort02 = us_tbapiaddr1-district.

             perform xvbpa_determine_txjcd
                     using    da_vbpakom
                     changing us_tbapiaddr1-taxjurcode
                              da_vbpakom-ort01
                              da_vbpakom-ort02.

             if not us_tbapiaddr1-taxjurcode is initial.
                if us_tbapiaddr1-city     <> da_vbpakom-ort01.
                   us_tbapiaddr1-city     =  da_vbpakom-ort01.
                endif.

                if us_tbapiaddr1-district <> da_vbpakom-ort02.
                   us_tbapiaddr1-district =  da_vbpakom-ort02.
                endif.
                Modify us_tbapiaddr1.
             endif.
          endif.
     endloop.
* 2. call sd_partner_bapi_address_create
     call function 'SD_PARTNER_BAPI_ADDRESS_CREATE'
          exporting
             fif_address_check    = space
          tables
             frt_vbpa2kom         = us_tvbpa2kom
             frt_type_1_addresses = us_tbapiaddr1
             fet_vbadr            = ch_tsadrvb
             fet_error_table      = t_error_table
          exceptions
             broken_adrnr_link    = 1
             no_handle_available  = 2
             address_insert_error = 3.
     if sy-subrc <> 0.
        loop at t_error_table into da_error_line.
             perform message_vbfs_aufbauen(sapfv45l)
                     using da_error_line-msg_id
                           da_error_line-msg_number
                           'W'
                           da_error_line-msg_var1
                           da_error_line-msg_var2
                           da_error_line-msg_var3
                           da_error_line-msg_var4.
        endloop.
     endif.
* create xvbadr in MV45A
     xvbadr[] = ch_tsadrvb[].
* 3. build the xvbpa.
     loop at us_tvbpa2kom.
          clear t_vbpavb.
          read table us_tvbpa3kom with key posnr = us_tvbpa2kom-posnr
                                           parvw = us_tvbpa2kom-bparvw
                                           into da_vbpa3kom.
          If sy-subrc <> 0.
            clear da_vbpa3kom.
          endif.
          call function 'SD_VBPA_RECORD_FILL'
               exporting
                  fis_vbpa2kom = us_tvbpa2kom
                  fis_vbpa3kom = da_vbpa3kom
               importing
                  fes_vbpavb   = t_vbpavb
               exceptions
                  incorrect_input_parameter = 1
                  others                    = 2.

           if sy-subrc = 0.
              clear xvbpa.
              move-corresponding t_vbpavb to xvbpa.
              xvbpa-mandt = vbak-mandt.
              xvbpa-vbeln = vbak-vbeln.
              xvbpa-updkz = updkz_new.
              append xvbpa.
           else.
             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
           endif.
     endloop.

endform.