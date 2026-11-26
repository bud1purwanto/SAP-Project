***INCLUDE MV45AFZB .

************************************************************************
*                                                                      *
* This include is reserved for user modifications                      *
*                                                                      *
* Forms for sales document processing                                  *
*                                                                      *
* The name of modification modules should begin with 'ZZ'.             *
*                                                                      *
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_CHECK_XVBAP_FOR_DELET
*&---------------------------------------------------------------------*
*                                                                     *
*       Additional examination can be entered in this form, before    *
*       the position is released for deletion.                        *
*                                                                     *
*       US_ERROR  - Flag that controls displaying messages            *
*       US_EXIT   - If this flag is set, an item is not allowed       *
*                   to be deleted                                     *
*                                                                     *
*       This form is called from form XVBAP_LOESCHEN_PRUEFEN.         *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CHECK_XVBAP_FOR_DELET USING US_ERROR
                                          US_EXIT.

* Example

* IF US_ERROR NE SPACE.
*   MESSAGE ......
* ENDIF.

* IF .......
*   US_EXIT = CHARX.
* ENDIF.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_CHECK_XVBEP_FOR_DELET
*&---------------------------------------------------------------------*
*                                                                     *
*       Additional examination can be entered in this form, before    *
*       the schedule line is released for deletion.                   *
*                                                                     *
*       US_EXIT   - If this flag is set, an item is not allowed       *
*                   to be deleted                                     *
*                                                                     *
*       This form is called from form XVBEP_LOESCHEN_PRUEFEN          *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CHECK_XVBEP_FOR_DELET USING US_EXIT.

* Example

* IF .......
*   US_EXIT = CHARX.
* ENDIF.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_CHECK_VBAK
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to add additional logic for         *
*       checking the header for completeness and consistency.         *
*                                                                     *
*       US_DIALOG  -  Indicator, that can be used to suppress         *
*                     dialogs in certain routines, e.g. in a          *
*                     copy routine.                                   *
*                                                                     *
*       This form is called from form VBAK_PRUEFEN.                   *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CHECK_VBAK USING US_DIALOG.


ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_CHECK_VBAP
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to add addtional logic for          *
*       checking the position for completeness and consistency.       *
*                                                                     *
*       US_DIALOG  -  Indicator, that can be used to suppress         *
*                     dialogs in certain routines, e.g. in            *
*                     copy mode.                                      *
*                                                                     *
*       This form is called from form VBAP_PRUEFEN_ENDE.              *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CHECK_VBAP USING US_DIALOG.


ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_CHECK_VBKD
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to add additional logic for         *
*       checking the sales details for completeness and consistency.  *
*                                                                     *
*       US_DIALOG  -  Indicator, that can be used to suppress         *
*                     dialogs in certain routines, e.g. in a          *
*                     copy routine.                                   *
*                                                                     *
*       This form is called from form VBKD_PRUEFEN.                   *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CHECK_VBKD USING US_DIALOG.


ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_CHECK_VBEP
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to add additional logic for         *
*       checking the schedule lines for completeness and consistency. *
*                                                                     *
*       US_DIALOG  -  Indicator, that can be used to suppress         *
*                     dialogs in certain routines, e.g. in a          *
*                     copy routine.                                   *
*                                                                     *
*       This form is called from form VBEP_PRUEFEN.                   *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CHECK_VBEP USING US_DIALOG.


ENDFORM.
*eject

*---------------------------------------------------------------------*
*      Form  USEREXIT_CHECK_VBSN
*---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to add additional logic for         *
*       checking the serial numbers for completeness and consistency. *
*                                                                     *
*       US_DIALOG  -  Indicator, that can be used to suppress         *
*                     dialogs in certain routines, e.g. in a          *
*                     copy routine.                                   *
*                                                                     *
*       This form is called from form VBSN_PRUEFEN.                   *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CHECK_VBSN USING US_DIALOG.


ENDFORM.
*eject

*---------------------------------------------------------------------*
*      Form  USEREXIT_CHECK_XVBSN_FOR_DELET
*---------------------------------------------------------------------*
*                                                                     *
*       Additional examination can be entered in this form, before    *
*       the serial number is released for deletion.                   *
*                                                                     *
*       US_EXIT   - If this flag is set, an item is not allowed       *
*                   to be deleted                                     *
*                                                                     *
*       This form is called from form XVBSN_LOESCHEN_PRUEFEN          *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CHECK_XVBSN_FOR_DELET USING US_EXIT.

* Example

* IF .......
*   US_EXIT = CHARX.
* ENDIF.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_FILL_VBAP_FROM_HVBAP
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to fill addtional data into VBAP    *
*       from the main item (HVBAP), i.e. this Userexit is called      *
*       when an item is entered with reference to a main item.        *
*                                                                     *
*       This form is called from form VBAP_FUELLEN_HVBAP.             *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_FILL_VBAP_FROM_HVBAP.

* VBAP-zzfield = HVBAP-zzfield2.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_MOVE_FIELD_TO_TVCOM_H
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to fill addtional data into TVCOM   *
*                                                                     *
*       E.g. the fields of the following workareas can be moved to    *
*            table TVCOM: VBAK                                        *
*                         VBKD                                        *
*                         ...                                         *
*                                                                     *
*       This form is called from form VBAK_FUELLEN.                   *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_TVCOM_H.

* Examples:
* TVCOM-zzfield = VBAK-zzfield2.
* TVCOM-zzfield = VBKD-zzfield2.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_MOVE_FIELD_TO_TVCOM_I
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to fill additional data into TVCOM  *
*                                                                     *
*       E.g. the fields of the following workareas can be moved to    *
*            table TVCOM: VBAP                                        *
*                         VBKD                                        *
*                         ...                                         *
*                                                                     *
*       This form is called from form VBAP_FUELLEN.                   *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_TVCOM_I.

* Examples:
* TVCOM-zzfield = VBAP-zzfield2.
* TVCOM-zzfield = VBKD-zzfield2.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_MOVE_FIELD_TO_COBL
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to fill addtional data into         *
*       table account assignment COBL.                                *
*                                                                     *
*       US_VBAK  - Workarea VBAK                                      *
*       US_VBAP  - Workarea VBAP                                      *
*       CH_COBL  - Workarea COBL                                      *
*                                                                     *
*       This form is called from form COBL_FUELLEN.                   *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_COBL USING US_VBAK STRUCTURE VBAK
                                       US_VBAP STRUCTURE VBAP
                              CHANGING CH_COBL STRUCTURE COBL.

* Examples
* CH_COBL-zzfield = US_VBAK-zzfield2.
* CH_COBL-zzfield = US_VBAP-zzfield2.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_COBL_RECEIVE_VBAK
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to move data from table COBL        *
*       to table VBAK.                                                *
*                                                                     *
*       This form is called from form COBL_RECEIVE_VBAK.              *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_COBL_RECEIVE_VBAK.

* VBAK-zzfield = COBL-zzfield2.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_COBL_RECEIVE_VBAP
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to move data from table COBL        *
*       to table VBAP.                                                *
*                                                                     *
*       This form is called from form COBL_RECEIVE_VBAP.              *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_COBL_RECEIVE_VBAP.

* VBAP-zzfield = COBL-zzfield2.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_COBL_SEND_ITEM
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to move data to the communication-  *
*       table INT_COBLF that is used in the function COBL_SEND_PBO.   *
*                                                                     *
*       This form is called from form COBL_SEND_PBO_VBAP.             *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_COBL_SEND_ITEM.

*  This example shows how to select fields that are shown in the
*  account assignment block

*  INT_COBLF-FDNAM = zzfield1.
*  INT_COBLF-OUTPUT = '1'.
*  IF T180-TRTYP NE CHARA AND
*     VBAP-KZVBR NE KZVBR_P.
*    INT_COBLF-INPUT    = '1'.
*    INT_COBLF-REQUIRED = '1'.
*  ENDIF.
*  INT_COBLF-ACTIVE = '1'.
*  APPEND INT_COBLF.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_COBL_SEND_HEADER
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to move data to the communication-  *
*       table INT_COBLF that is used in the function COBL_SEND_PBO.   *
*                                                                     *
*       This form is called from form COBL_SEND_PBO_VBAK.             *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_COBL_SEND_HEADER.

*  This example shows how to select fields that are shown in the
*  account assignment block

*  INT_COBLF-FDNAM = zzfield1.
*  INT_COBLF-OUTPUT = '1'.
*  IF T180-TRTYP NE CHARA AND
*     VBAP-KZVBR NE KZVBR_P.
*    INT_COBLF-INPUT    = '1'.
*    INT_COBLF-REQUIRED = '1'.
*  ENDIF.
*  INT_COBLF-ACTIVE = '1'.
*  APPEND INT_COBLF.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_SOURCE_DETERMINATION
*&---------------------------------------------------------------------*
*       This Userexit is used to add additional logic for finding      *
*       the source of the plant or the item category.                  *
*                                                                      *
*       This form is called from form VBAP_FUELLEN                     *
*                                                                      *
*----------------------------------------------------------------------*
FORM USEREXIT_SOURCE_DETERMINATION.

* set source
* VBAP-WERKS          = zzfield1.

* set item category
* VBAP-PSTYV          = zzfield2.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_MOVE_FIELD_TO_ME_REQ
*&---------------------------------------------------------------------*
*       This Userexit can be used to move additional data to the       *
*       requisition-table EBAN or to the account-assignment-table      *
*       for requisitions EBKN.                                         *
*                                                                      *
*       This form is called from form EBAN_FUELLEN                     *
*                                     BESCHAFFUNG_FUELLEN              *
*                                                                      *
*----------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_ME_REQ.

* Example
* EBAN-LIFNR = zzfield1.
* EBKN-KOSTL = zzfield2.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_GET_FIELD_TO_SDCOM
*&---------------------------------------------------------------------*
*       This userexit can be used to get additional fields from the    *
*       communication structure between sales order and variant        *
*       configuration.                                                 *
*                                                                      *
*       Fields included in structure SDCOM can be used for further     *
*       processing in the sales order.                                 *
*                                                                      *
*       This form is called from CONFIGURATION_PROCESSING              *
*                                                                      *
*----------------------------------------------------------------------*
FORM USEREXIT_GET_FIELD_FROM_SDCOM USING SDCOM STRUCTURE SDCOM.

* Example

*  US_zzfield = SDCOM-zzfield.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_MOVE_WORKAREA_TO_SDWA
*&---------------------------------------------------------------------*
*       This userexit can be used to move additional work areas to     *
*       the communication table between sales order and variant        *
*       configuration.                                                 *
*                                                                      *
*       Work areas included in table SDWA can be used read only !      *
*       The cannot be changed during the configuration process and     *
*       are not passed back to the sales order.                        *
*                                                                      *
*       This form is called from CONFIGURATION_PROCESSING              *
*                                                                      *
*----------------------------------------------------------------------*
FORM USEREXIT_MOVE_WORKAREA_TO_SDWA.

* Example

* sdwa-tname = 'ZZZZZZZZZZ'.
* sdwa-table = ZZZZZZZZZZ.   append sdwa.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_MOVE_FIELD_TO_VBAKKOM
*&---------------------------------------------------------------------*
*       This userexit can be used to move additional fields into the   *
*       sales document header workarea VBAK                            *
*                                                                      *
*       This form is called at the end of form VBAK_FUELLEN_VBAKKOM.   *
*                                                                      *
*----------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_VBAKKOM.

*  VBAK-zzfield = US_VBAKKOM-zzfield2.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_MOVE_FIELD_TO_VBAPKOM
*&---------------------------------------------------------------------*
*       This userexit can be used to move additional fields into the   *
*       sales document line workarea VBAP                              *
*                                                                      *
*       This form is called at the end of form VBAP_FUELLEN_VBAPKOM.   *
*                                                                      *
*----------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_VBAPKOM.

*  VBAP-zzfield = US_VBAPKOM-zzfield2.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_MOVE_FIELD_TO_VBEPKOM
*&---------------------------------------------------------------------*
*       This userexit can be used to move additional fields into the   *
*       sales document schedule line workarea VBEP                     *
*                                                                      *
*       SVBEP-TABIX = 0:  Create schedule line                         *
*       SVBEP-TABIX > 0:  Change schedule line                         *
*                                                                      *
*       This form is called at the end of form VBEP_FUELLEN_VBEPKOM.   *
*                                                                      *
*----------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_VBEPKOM.

*  VBEP-zzfield = US_VBEPKOM-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_VBSN                              *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the sales  *
*       document workarea VBSN.                                       *
*                                                                     *
*       SVBAK-TABIX = 0:  Create data                                 *
*       SVBAK-TABIX > 0:  Change data                                 *
*                                                                     *
*       This form is called at the end of form VBSN_FUELLEN.          *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_VBSN.

*  vbsn-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_KOMKH                             *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the        *
*       communication workarea for the batch determination.           *
*                                                                     *
*       This form is called from form KOMKH_KOMPH_FUELLEN.            *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_KOMKH.

*  KOMKH-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*---------------------------------------------------------------------*
*       FORM USEREXIT_MOVE_FIELD_TO_KOMPH                             *
*---------------------------------------------------------------------*
*       This userexit can be used to move some fields into the        *
*       communication workarea for the batch determination            *
*                                                                     *
*       This form is called from form KOMKH_KOMPH_FUELLEN.            *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_MOVE_FIELD_TO_KOMPH.

*  KOMPH-zzfield = xxxx-zzfield2.

ENDFORM.
*eject

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_CUST_MATERIAL_READ
*&---------------------------------------------------------------------*
*       This userexit can be used to read a different customer-       *
*       material-record.                                              *
*                                                                     *
*       US_KUNNR  - customer number that can be set in order to read  *
*                   a different customer-material-record.             *
*                                                                     *
*       This form is called from form RV_CUSTOMER_MATERIAL_READ.      *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CUST_MATERIAL_READ USING US_KUNNR.

* US_KUNNR = xxxx-zzfield1.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_NEW_PRICING_VBAP
*&---------------------------------------------------------------------*
*       This userexit can be used to perform new pricing, dependant   *
*       on the change of datafields.                                  *
*       This routine is not called, when the material number has been *
*       changed.                                                      *
*       Available data-fields:                                        *
*         vbak - header data                                          *
*         vbap - item data     (changed)                              *
*         *vbap - item data (old, before the change)                  *
*                                                                     *
*       Parameter new_pricing controls the new pricing in the calling *
*       form. It can be filled according the the allowed values       *
*       of domain KNPRS (Pricing type), for example:                  *
*       ' ' = no new pricing                                          *
*       B   = Carry out new pricing                                   *
*       C   = Copy manual pricing elements and redetermine the others
*---------------------------------------------------------------------*
FORM USEREXIT_NEW_PRICING_VBAP CHANGING NEW_PRICING.

* Example: new pricing, when field 'Route' is changed
* if vbap-route ne *vbap-route.
*   new_pricing = 'B'.
* endif.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  USEREXIT_NEW_PRICING_VBKD
*&---------------------------------------------------------------------*
*       This userexit can be used to perform new pricing, dependant   *
*       on the change of datafields                                   *
*                                                                     *
*       Available data-fields:                                        *
*         vbak - header data                                          *
*         vbkd - business data (changed)                              *
*         *vbkd - business data (old, before the change)              *
*                                                                     *
*       Field vbkd-posnr is the item-number of the business data.     *
*       If the field is initial, then vbkd contains the business      *
*       header data.                                                  *
*                                                                     *
*       Parameter new_pricing controls the new pricing in the calling *
*       form. It can be filled according the the allowed values       *
*       of domain KNPRS (Pricing type), for example:                  *
*       ' ' = no new pricing                                          *
*       B   = Carry out new pricing                                   *
*       C   = Copy manual pricing elements and redetermine the others
*---------------------------------------------------------------------*
FORM USEREXIT_NEW_PRICING_VBKD CHANGING NEW_PRICING.

* Example: new pricing, when Price list type is changed
* if vbkd-pltyp ne *vbkd-pltyp.
*   new_pricing = 'B'.
* endif.

ENDFORM.