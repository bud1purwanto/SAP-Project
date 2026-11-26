*----------------------------------------------------------------------*
*   INCLUDE LMIGOIF1                                                   *
*----------------------------------------------------------------------*

INTERFACE lif_migo_frame.
  TYPES:
*   Single OK-code
    ty_okcode TYPE syucomm,
*   Table to register OK-codes
    ty_t_okcodes TYPE STANDARD TABLE OF ty_okcode
                                     WITH NON-UNIQUE DEFAULT KEY,
*   Message type, data type
    ty_message_id   TYPE char40,
    ty_message_data TYPE char25,
*   Class name type
    ty_class_id TYPE migo_class_id,
*   Table to register messages
    ty_t_message_ids TYPE STANDARD TABLE OF ty_message_id
                                         WITH NON-UNIQUE DEFAULT KEY,
*   A message
    BEGIN OF ty_s_message,
      data1      TYPE ty_message_data,
      data2      TYPE ty_message_data,
      dref       TYPE REF TO data,
      oref       TYPE REF TO object,
    END OF ty_s_message,

*   Table of answers to a message
    BEGIN OF ty_s_answers,
      recipient TYPE REF TO lif_migo_frame.
      INCLUDE   TYPE ty_s_message.
    TYPES: END OF ty_s_answers,
    ty_t_answers TYPE STANDARD TABLE OF ty_s_answers
                 WITH NON-UNIQUE KEY recipient.

  DATA:
*   Identifier for the implementing class (useful for TRACE)
    class_id TYPE ty_class_id.
  METHODS:
*   Handler for the OK-code
    okcode_handler IMPORTING i_okcode TYPE ty_okcode,
*   Handler for incoming messages
    message_handler IMPORTING i_message_id  TYPE ty_message_id
                              i_iref_sender TYPE REF TO lif_migo_frame
                              is_message    TYPE ty_s_message
                    EXPORTING es_answer     TYPE ty_s_message.
ENDINTERFACE.