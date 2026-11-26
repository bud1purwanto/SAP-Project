*&---------------------------------------------------------------------*
*&  Include           /SPE/MM07M_DOCFLOWUPDATE                         *
*&---------------------------------------------------------------------*

FORM spe_additional_doc_flow_update
      CHANGING lv_plmin   LIKE xvbfa-plmin
               lv_vbtyp_n LIKE xvbfa-vbtyp_n
               lv_vbtyp_v LIKE xvbfa-vbtyp_v.

  DATA: lv_bustr TYPE t156-bustr.

* get corresponding posting string reference(BUSTR) for movement type
  SELECT SINGLE bustr FROM t156 INTO lv_bustr WHERE bwart = xvbfa-bwart.

  CALL FUNCTION '/SPE/GOODSMVT_DOCFLOW_UPDATE'
    EXCEPTIONS
      NO_DOCFLOW_UPDATE       = 1
      OTHERS                  = 2.

  IF sy-subrc EQ 0 OR
* Note: The following IF's should now be superfluous with the global indicator
*       checked in the above function module.
*       However for security it is still left for now.
*       If no implictions are found, the IF's below and the SELECT on T156
*       should be removed again to improve transparency in the future.

* check if additional delivery document flow has to be updated
     lv_bustr EQ '311' OR lv_bustr EQ '411' OR lv_bustr EQ '321' OR
     lv_bustr EQ '323' OR lv_bustr EQ '325' OR lv_bustr EQ '343' OR
     lv_bustr EQ '349' OR lv_bustr EQ '309' OR lv_bustr EQ '551' OR
     lv_bustr EQ '553' OR lv_bustr EQ '555'.

*   posting is neither positive nor negative
    lv_plmin = ' '.
*   the document category of subsequent document is 'Goods movement'
    lv_vbtyp_n = 'p'.

*   determine document category of preceding SD document
    SELECT SINGLE vbtyp FROM vbuk CLIENT SPECIFIED INTO lv_vbtyp_v
    WHERE mandt = sy-mandt AND vbeln = xvbfa-vbelv.

  ENDIF.

ENDFORM.                    "SPE_additional_doc_flow_update