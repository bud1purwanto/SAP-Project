*----------------------------------------------------------------------*
***INCLUDE MM07MFE1 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  external_component_get
*&---------------------------------------------------------------------*
*  Get external-entered components:
*  Imported via function MB_CREATE_GOODS_MOVEMENT (BAPI_GOODSMVT_CREATE)
*----------------------------------------------------------------------*
FORM external_component_get.

  DATA: lt_xmdvw     TYPE STANDARD TABLE OF ty_s_xmdvw,
        ls_xmdvw     TYPE ty_s_xmdvw,
        ls_gocomp    LIKE LINE OF gt_gocomp,                  "1356935
        l_counter    TYPE sy-tabix,
        rc           LIKE sy-subrc.                           "1356935

  field-symbols: <xmdvw>     LIKE xmdvw,
                 <gt_gocomp> LIKE gt_gocomp.                  "1356935

  CLEAR rc.                                                   "1356935

* In cancel mode, no action required because no changes possible in MIGO
* All data have to be read from the original document.
  IF xmbwl = x AND xcanc <> x.
    PERFORM external_component_check.
ENHANCEMENT-POINT EXTERNAL_COMPONENT_GET_01 SPOTS ES_SAPMM07M.
    LOOP AT xmdvw ASSIGNING <xmdvw>.
      l_counter = 1.
    IF <xmdvw>-bwtar IS NOT INITIAL.                          "1356935\/
     LOOP AT gt_gocomp ASSIGNING <gt_gocomp> WHERE
                    parent =  omseg-line_id
                AND matnr  = <xmdvw>-matnr
                AND werks  = <xmdvw>-werks
                AND bwtar  = <xmdvw>-bwtar
                AND shkzg  = <xmdvw>-shkzg.
     IF l_counter = 1.
       MOVE-CORRESPONDING <gt_gocomp> TO <xmdvw>.
*      in case of goods issue from special stock, the lt-gocomp
*      could have a storage location. Due to source below with xlort,
*      we have to move lgort to lgpro of xmdvw.
       <xmdvw>-lgpro = <gt_gocomp>-lgort.
*      Copy LINE_ID from MIGO. The other data are derived
*      always in this routine. PARENT and DEPTH from MIGO are
*      ignored, but should always yield the same result.
       <xmdvw>-line_id = <gt_gocomp>-global_counter.
     ELSE.
*      More than one line for a component (batch split, ...)
       ls_xmdvw = <xmdvw>.
       MOVE-CORRESPONDING <gt_gocomp> TO ls_xmdvw.
*      in case of goods issue from special stock, the lt-gocomp
*      could have a storage location. Due to source below with xlort,
*      we have to move lgort to lgpro of xmdvw.
       ls_xmdvw-lgpro   = <gt_gocomp>-lgort.
       ls_xmdvw-line_id = <gt_gocomp>-global_counter.
       APPEND ls_xmdvw TO lt_xmdvw.
     ENDIF.
     l_counter = l_counter + 1.
     ENDLOOP.
*    rc = 0 when there are more bwtar in gt_gocomp than in xmdvw,
*    line needs to be added with zero quantity
*    rc <> 0 line has not been selected in MIGO. erfmg must be set
*    to zero, so the line is deleted at the end of this form.
     rc = sy-subrc.
*    gt_gocomp has to be checked for new bwtar
     LOOP AT gt_gocomp ASSIGNING <gt_gocomp> WHERE
                     parent =  omseg-line_id
                 AND matnr  = <xmdvw>-matnr
                 AND werks  = <xmdvw>-werks
                 AND shkzg  = <xmdvw>-shkzg.
*      Check if valation type is still to come
       READ TABLE xmdvw WITH KEY matnr = <gt_gocomp>-matnr
                                 werks = <gt_gocomp>-werks
                                 bwtar = <gt_gocomp>-bwtar
                                 shkzg = <gt_gocomp>-shkzg
             TRANSPORTING NO FIELDS.
       IF sy-subrc IS INITIAL.
         CONTINUE.
       ENDIF.
       ls_xmdvw = <xmdvw>.
       IF rc NE '0'.
         <xmdvw>-erfmg = '0'.
       ENDIF.
       MOVE-CORRESPONDING <gt_gocomp> TO ls_xmdvw.
       ls_xmdvw-lgpro   = <gt_gocomp>-lgort.
       ls_xmdvw-line_id = <gt_gocomp>-global_counter.
       ls_xmdvw-wamng = '0'.
       ls_xmdvw-wawrt = '0'.
*      check if item has already been insert in lt_xmdvw
       READ TABLE lt_xmdvw WITH KEY line_id = ls_xmdvw-line_id
            TRANSPORTING NO FIELDS.
       IF NOT sy-subrc IS INITIAL.
         APPEND ls_xmdvw TO lt_xmdvw.
       ENDIF.
       l_counter = l_counter + 1.
     ENDLOOP.
    ELSE.                                                     "1356935/\
      LOOP AT gt_gocomp ASSIGNING <gt_gocomp> WHERE
                     parent =  omseg-line_id
                 AND matnr  = <xmdvw>-matnr
                 AND werks  = <xmdvw>-werks
                 AND shkzg  = <xmdvw>-shkzg.                  "1356935

        IF l_counter = 1.
          MOVE-CORRESPONDING <gt_gocomp> TO <xmdvw>.
*         in case of goods issue from special stock, the lt-gocomp
*         could have a storage location. Due to source below with xlort,
*         we have to move lgort to lgpro of xmdvw.
          <xmdvw>-lgpro = <gt_gocomp>-lgort.                "316760
*         Copy LINE_ID from MIGO. The other data are derived
*         always in this routine. PARENT and DEPTH from MIGO are
*         ignored, but should always yield the same result.
          <xmdvw>-line_id = <gt_gocomp>-global_counter.
        ELSE.
*         More than one line for a component (batch split, ...)
          ls_xmdvw = <xmdvw>.
          MOVE-CORRESPONDING <gt_gocomp> TO ls_xmdvw.
*         in case of goods issue from special stock, the lt-gocomp
*         could have a storage location. Due to source below with xlort,
*         we have to move lgort to lgpro of xmdvw.
          ls_xmdvw-lgpro   = <gt_gocomp>-lgort.             "339351
          ls_xmdvw-line_id = <gt_gocomp>-global_counter.    "339351
          APPEND ls_xmdvw TO lt_xmdvw.
        ENDIF.
        l_counter = l_counter + 1.
      ENDLOOP.
    ENDIF.                                                    "1356935
*     No external data for the component (-> set quantity to 0)
*     Later all XMDVW-lines with a quantity of 0 will be deleted.
      IF l_counter = 1.
        clear <xmdvw>-erfmg.
ENHANCEMENT-POINT EXTERNAL_COMPONENT_GET_02 SPOTS ES_SAPMM07M.
      ENDIF.
    ENDLOOP.
*   Append new components (from quantity split) to xmdvw.
    LOOP AT lt_xmdvw ASSIGNING <xmdvw>.
      APPEND <xmdvw> TO xmdvw.
    ENDLOOP.
*   Delete all components with quantity = 0
ENHANCEMENT-SECTION     EXTERNAL_COMPONENT_GET_03 SPOTS ES_SAPMM07M.
    DELETE xmdvw WHERE erfmg = 0.
END-ENHANCEMENT-SECTION.
*   Subsequent adjustment: There must be at least one correct component
    IF xmdvw[] IS INITIAL AND omseg-kzbew = o.
      message e386.
    ENDIF.
  ENDIF.

ENDFORM.                    " external_component_get
*&---------------------------------------------------------------------*
*&      Form  external_component_check
*&---------------------------------------------------------------------*
*       Check external components:
*       The key fields for a component are MATNR WERKS and SHKZG. There
*       has to be a component in the purchase order with the same key
*       fields as the external information.
*----------------------------------------------------------------------*
FORM external_component_check.
  field-symbols: <gt_gocomp> LIKE gt_gocomp,                  "1356935
                 <xmdvw>     LIKE xmdvw.                      "1645358
  DATA: sh_po TYPE c. "shkzg from xmdvw/purchase order        "1645358

  LOOP AT gt_gocomp ASSIGNING <gt_gocomp> WHERE
                  parent =  omseg-line_id.

    IF <gt_gocomp>-shkzg IS INITIAL.                          "1645358
*   shkzg via MVT was not provided by i.e. BAPI               "1645358
      LOOP AT xmdvw ASSIGNING <xmdvw>                         "1645358
                  WHERE WERKS = <gt_gocomp>-werks             "1645358
                    AND MATNR = <gt_gocomp>-matnr.            "1645358
        IF sh_po IS INITIAL.                                  "1645358
          <gt_gocomp>-shkzg = <xmdvw>-shkzg.                  "1645358
          sh_po = 'X'.                                        "1645358
        ELSEIF <gt_gocomp>-shkzg NE <xmdvw>-shkzg.            "1645358
*     MVT missing in calling application and component exists "1645358
*     at least twice in the xmdvw with different shzkg, thus  "1645358
*     MVT has to be provided                                  "1645358
          MESSAGE e873 WITH '___'.                            "1645358
        ENDIF.                                                "1645358
      ENDLOOP.                                                "1645358
    ENDIF.

* SHKZG from MIGO has to be changed in case of reversal movement."1356935
* same is true for calls by BAPI, unless shkzg derived from xmdvw"1645358
* Only exception: Subsequent Adjustment (no underconsumption)    "1356935

* omseg-erfmg not filled in case of Subsequent Adjustment
* gt_comp-erfmg is negative in case of underconsumption
    IF omseg-shkzg = 'H'.                  "102 or 121
      IF <gt_gocomp>-shkzg = 'S' AND       "102
           NOT omseg-erfmg IS INITIAL AND
                     sh_po IS INITIAL.                        "1645358
        <gt_gocomp>-shkzg = 'H'.
      ELSEIF <gt_gocomp>-shkzg = 'H' AND   "102
         NOT       omseg-erfmg IS INITIAL AND
                         sh_po IS INITIAL.                    "1645358
        <gt_gocomp>-shkzg = 'S'.
      ELSEIF <gt_gocomp>-shkzg = 'S' AND <gt_gocomp>-erfmg < '0'.
        <gt_gocomp>-shkzg = 'H'.
      ELSEIF <gt_gocomp>-shkzg = 'H' AND <gt_gocomp>-erfmg < '0'.
        <gt_gocomp>-shkzg = 'S'.
      ENDIF.
    ENDIF.
*   No read possible, because there are too much key-fields in XMDVW
    LOOP AT xmdvw WHERE WERKS = <gt_gocomp>-werks
                    AND MATNR = <gt_gocomp>-matnr
                    AND SHKZG = <gt_gocomp>-shkzg.            "1645358
      EXIT.
    ENDLOOP.
    IF SY-SUBRC <> 0.
      message e387 with omseg-ebeln omseg-ebelp <gt_gocomp>-matnr
                        <gt_gocomp>-werks.
    ENDIF.
    clear: sh_po.                                             "1645358
  ENDLOOP.

ENDFORM.                    " external_component_checkmp