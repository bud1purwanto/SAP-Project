*----------------------------------------------------------------------*
*   INCLUDE LMIGOBN1                                                   *
*----------------------------------------------------------------------*
* METHOD NAME_AND_PHONE_GET
*----------------------------------------------------------------------*
* Reads complete name and telnr for a SAP user
* importing i_usnam
* exporting e_exnam
*           e_telnr
* Entries are buffered in private table PT_NAME_BUFFER
*----------------------------------------------------------------------*
METHOD name_and_phone_get.
  DATA: ls_usr03       TYPE usr03,
        ls_address     TYPE addr3_val,                           "448648
        ls_name_in     TYPE soud3,
        ls_name_out    TYPE soud3,
        ls_name_buffer TYPE ty_s_name_buffer.
  CLEAR: e_exnam, e_telnr.
  CHECK NOT i_usnam IS INITIAL.

* Try to find entry in buffer table-----------------------------------*
  READ TABLE pt_name_buffer INTO ls_name_buffer
                            WITH TABLE KEY usnam = i_usnam.
  IF sy-subrc = 0.
    e_exnam = ls_name_buffer-exnam.
    e_telnr = ls_name_buffer-telnr.
    EXIT.
  ENDIF.

* Entry not found in buffer => read from database --------------------*
  ls_name_buffer-usnam = i_usnam.
* Read complete name from SAP Office.
* The name is not read from user data because SAP Office gives the
* complete name in one field. In user data you have to mix first and
* last name which is not always correct
  ls_name_in-sapnam = i_usnam.

  CALL FUNCTION 'SO_NAME_CONVERT'
       EXPORTING
            name_in  = ls_name_in
       IMPORTING
            name_out = ls_name_out
       EXCEPTIONS
            OTHERS   = 1.
  IF sy-subrc <> 0 OR ls_name_out-adrname IS INITIAL.
    e_exnam              = i_usnam.
    ls_name_buffer-exnam = i_usnam.
  ELSE.
    e_exnam              = ls_name_out-adrname.
    ls_name_buffer-exnam = ls_name_out-adrname.
  ENDIF.
* Read telephone number from user data
  CALL FUNCTION 'SUSR_USER_ADDRESS_READ'
       EXPORTING
            user_name  = i_usnam
       IMPORTING
            user_usr03 = ls_usr03
            user_address = ls_address                            "448648
     EXCEPTIONS
          OTHERS     = 1.
  IF sy-subrc = 0.
    concatenate ls_address-tel_number ls_address-tel_extens      "448648
      into e_telnr.
    ls_name_buffer-telnr = e_telnr.                              "448648
  ENDIF.

* Finally insert new LS_NAME entry in buffer table PT_NAME-------------*
  INSERT ls_name_buffer INTO TABLE pt_name_buffer.
ENDMETHOD.                             "NAME_AND_PHONE_GET

*----------------------------------------------------------------------*
* METHOD NAME_AND_PHONE_BUYER_GET
*----------------------------------------------------------------------*
* Reads name and telephone of purchasing group in T024
* importing i_ekgrp
* exporting e_eknam
*           e_ektel
* Entries are buffered in private table PT_024_BUFFER.
*----------------------------------------------------------------------*
METHOD name_and_phone_buyer_get.
  DATA: ls_024_buffer TYPE t024.
  CLEAR: e_eknam, e_ektel.
  CHECK NOT i_ekgrp IS INITIAL.

* Try to find entry in buffer table------------------------------------*
  READ TABLE pt_024_buffer INTO ls_024_buffer
                           WITH TABLE KEY ekgrp = i_ekgrp.
  IF sy-subrc = 0.
    e_eknam = ls_024_buffer-eknam.
    e_ektel = ls_024_buffer-ektel.
    EXIT.
  ENDIF.

* Entry not found in buffer => read from database ---------------------*
  ls_024_buffer-ekgrp = i_ekgrp.
  SELECT SINGLE * FROM t024 INTO ls_024_buffer WHERE ekgrp = i_ekgrp.
  IF sy-subrc = 0.
    e_eknam   = ls_024_buffer-eknam.
    e_ektel   = ls_024_buffer-ektel.
  ENDIF.

* Finally insert new LS_024 entry in buffer table PT_024_BUFFER
  INSERT ls_024_buffer INTO TABLE pt_024_buffer.
ENDMETHOD.                             "NAME_AND_PHONE_BUYER_GET