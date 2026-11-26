*----------------------------------------------------------------------*
***INCLUDE FV50XF0B_WF_IBDLV_FROM_OBDLV .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  WF_IBDLV_FROM_OBDLV
*&---------------------------------------------------------------------*
*       Workflow event for the creation of an inbound delivery
*----------------------------------------------------------------------*
FORM WF_IBDLV_FROM_OBDLV.
  DATA:     LF_EVENT_OBJECT_TYPE LIKE SWETYPECOU-OBJTYPE,
            LF_EVENT_OBJECT_KEY  LIKE SWEINSTCOU-OBJKEY,
            LF_EVENT_ID LIKE SWETYPECOU-EVENT,
            LF_IBDLV TYPE XFELD.                               "n_939761

  DATA: BEGIN OF T_CONTAINER OCCURS 0.
          INCLUDE STRUCTURE SWCONT.
  DATA: END OF T_CONTAINER.
  DATA:  OBJ TYPE SWC_OBJECT,
         OBJS TYPE SWC_OBJECT OCCURS 0.
  DATA:  LF_DELIV_NUM_PARAM LIKE BDWFRETVAR-WF_PARAM
                            VALUE 'DeliveryNumber'.

* CHECK IF DELIVERY HAS A FOLLOW DELIVERY TYPE
  CHECK NOT ( XLIKP-FOLAR IS INITIAL ).
* check delivery type is outbound delivery
  CHECK XLIKP-VBTYP CA VBTYP_LIEF.
* check goods movement is completed.
  CHECK XVBUK-WBSTK EQ CHARC.
* Check whether PGI is processed
  CHECK V50AGL-WARENAUSGANG EQ CHARX.                         "n_1025811

* CHECK THAT INBOUND DELIVERY IS ONLY CREATE ONCE
  READ TABLE XVBFA WITH KEY VBELV   = XLIKP-VBELN
                            VBTYP_N = VBTYP_LIAV.
* CHECK WHETHER INBOUND DELIVERY STILL EXISTS
  IF SY-SUBRC EQ 0.                                          "v_n_939761
    CLEAR LF_IBDLV.
    LOOP AT XVBFA WHERE VBELV   = XLIKP-VBELN
                  AND   VBTYP_N = VBTYP_LIAV.
      CALL FUNCTION 'SD_VBUK_SINGLE_READ'
        EXPORTING
          I_VBELN                  = XVBFA-VBELN
        EXCEPTIONS
          OTHERS                   = 1.
      IF SY-SUBRC = 0.
        LF_IBDLV = CHARX.
        EXIT.
      ENDIF.
    ENDLOOP.
*   IS THERE AT LEAST ONE OPEN INBOUND DELIVERY ON DATABASE?
    CHECK LF_IBDLV IS INITIAL.
  ENDIF.                                                     "^_n_939761

   LF_EVENT_OBJECT_KEY  = XLIKP-VBELN.
   LF_EVENT_ID          = 'CREATE_IBDLV'.

* Ermitteln des Businessobjekts aus dem Vertriebsbelegtyp
  PERFORM TVLK_SELECT(SAPMV50A) USING XLIKP-LFART
                                      SPACE
                                      SY-SUBRC.
  CALL FUNCTION 'SD_OBJECT_TYPE_DETERMINE'
       EXPORTING
            I_DOCUMENT_TYPE        = XLIKP-VBTYP
            I_TVLK                 = TVLK
       IMPORTING
            E_BUSINESS_OBJECT      = LF_EVENT_OBJECT_TYPE
       EXCEPTIONS
            OTHERS                 = 0.

*   Event's container filled............................................

  CALL FUNCTION 'SWE_EVENT_CREATE'
       EXPORTING
            OBJTYPE         = LF_EVENT_OBJECT_TYPE
            OBJKEY          = LF_EVENT_OBJECT_KEY
            EVENT           = LF_EVENT_ID
*      tables
*           event_container = t_container
       EXCEPTIONS
            OBJTYPE_NOT_FOUND       = 1
            OTHERS                  = 2.

ENDFORM.                    " WF_IBDLV_FROM_OBDLV