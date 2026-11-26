***INCLUDE MV45AFZH.

************************************************************************
*                                                                      *
* This include is reserved for user modifications                      *
* Forms for sales document processing                                  *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       FORM AUTHORIZATION_VALUE_SPLIT                                *
*---------------------------------------------------------------------*
*       This userexit can be used to split up the total authorization
*       value of sales order items with regard to invoices that will be
*       created from these items in the future.
*
*       Order items/schedule lines are stored in the table
*       OPEN_VALUES. A grouping term, which can be set freely, must
*       be entered in the field OPEN_VALUE-ZUKRI. The authorization is
*       carried out separately for each grouping term!
*
*       The program includes 2 examples. Please apply your own coding
*       if necessary:
*
*       1) an invoice simulation is used to find out in which order
*          items/schedule lines will be invoiced in ONE billing
*          document. The field OPEN_VALUES-ZUKRI contains the document
*          number of the virtual invoice document (DA_XVBRP-VBELN).
*          Please see application help: Sales and Distribution ->
*          Billing -> The General Billing Interface, especially order
*          type, order item category and invoice type. Please be aware
*          that this simulation may temporarily affect system
*          performance. This example employs order txpe TA, item
*          category DLN and Invoice type FX. Please make sure that
*          customizing for document copying is in order.
*       2) specific fields of the order item will trigger
*          separate invoice documents.
*          The field OPEN_VALUES contains the shipping point
*          of the order item (VBAP-VSTEL); Please change or fill
*          additional fields.
*---------------------------------------------------------------------
*  importing parameters
*    all general data of order module pool can be used
*  exporting table
*    OPEN_VALUES-ZUKRI must be set with a grouping term which can be
*                      used freely
*  controlling parameter
*    DA_EXAMPLE        must be set with the number of the example
*                      = 1, if you want to have invoice simulation
*                      = 2, if you want to have special fields
*---------------------------------------------------------------------
FORM AUTHORIZATION_VALUE_SPLIT TABLES OPEN_VALUES STRUCTURE BEZS132.

  DATA: DA_EXAMPLE(2) TYPE N VALUE 0.
  DATA: DA_AUART LIKE VBAK-AUART VALUE 'TA'.
  DATA: DA_FKART LIKE VBRK-FKART VALUE 'FX'.
  DATA: DA_PSTYV LIKE VBAP-PSTYV VALUE 'DLN'.
  DATA: DA_SUBRC LIKE SY-SUBRC.

  IF DA_EXAMPLE EQ 1.
*   first example: invoice simulation
    PERFORM AUTHORIZATION_VALUE_SPLIT1 TABLES OPEN_VALUES
                                       USING DA_AUART
                                             DA_FKART
                                             DA_PSTYV
                                    CHANGING DA_SUBRC.
    IF DA_SUBRC NE 0.
*     message Innn "error in invoice simulation, no split of
*                   authorization value possible"
    ENDIF.

  ELSEIF DA_EXAMPLE EQ 2.
*   second example, for example shipping point
    PERFORM AUTHORIZATION_VALUE_SPLIT2 TABLES OPEN_VALUES.

  ENDIF.
ENDFORM.
*eject