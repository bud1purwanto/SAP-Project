*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CREATE_BADI_INSTANCE                    *
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*  FORM create_badi_instance
*---------------------------------------------------------------------*
*  This form can be used to create globally known BAdI instances. For
*  performance reasons such instances should only be created once per
*  transaction if possible
*  The data definition of the instance should be done in include
*  MV50A_BADI_DEF which is included in the common part of the delivery
*  processing
*---------------------------------------------------------------------*
form create_badi_instance.

* Form reworked completely with note 637289
* The following notes are included:
* 530754, 536540, 538613, 545270, 572145, 599553

*  if gi_exit is initial.
*    call method cl_exithandler=>get_instance
*         changing instance = gi_exit.
*  endif.

****** EH&S (Environment, Health & Safety)*************************
****** Definitions for dangerous goods
  if gi_badi_instance_ehs001 is initial.
    call function 'EHS002_BADI_EHS_DG_001_GET_OBJ'
      importing
        e_badi_object = gi_badi_instance_ehs001.
  endif.

* General delivery processing
  if gi_badi_delivery is initial.
    call method cl_exithandler=>get_instance
      exporting
        exit_name                     = 'LE_SHP_DELIVERY_PROC'
        null_instance_accepted        = 'X'
      changing
        instance                      = gi_badi_delivery
      exceptions
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        others                        = 9.
    if sy-subrc ne 0.
      message id sy-msgid type 'A' number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

* Interface for pricing in delivery processing
  if gi_badi_pricing is initial.
    call method cl_exithandler=>get_instance
      exporting
        exit_name                     = 'LE_SHP_PRICING'
        null_instance_accepted        = 'X'
      changing
        instance                      = gi_badi_pricing
      exceptions
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        others                        = 9.
    if sy-subrc ne 0.
      message id sy-msgid type 'A' number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

* Interface for country-specific fields in pricing
* no longer required: already migrated to new BAdI

endform.                    "create_badi_instance