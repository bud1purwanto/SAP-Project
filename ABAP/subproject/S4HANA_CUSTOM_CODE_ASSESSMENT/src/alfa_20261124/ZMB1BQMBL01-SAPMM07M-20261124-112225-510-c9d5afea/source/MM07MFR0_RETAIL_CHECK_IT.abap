*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_CHECK_IT
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 356129
*----------------------------------------------------------------------*
*       Form  retail_struct_check_it
*----------------------------------------------------------------------*
*  The hunt for Retail-structures in the remaining GR-lines is open:
*  reading IT_RSTRUCT you can find materials with Retail-structures
*  in IT_XYMSEG. If header found all components of RSTRUCT must
*  be found in IT_XYMSEG. If not there must be an inconsistency and
*  the user need to get a message to proof the situation
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_CHECK_IT  USING KZ_YMSEG TYPE C.

  DATA: l_deactive TYPE char1.
  GET PARAMETER ID 'M7358_DISABLE' FIELD l_deactive.

  if l_deactive is initial.

    loop at yvm07m transporting no fields where line_count <> space.
      exit.
    endloop.
    check sy-subrc is initial.
*   initial check if there's a line_count at all or no check necessary

    data: l_ymseg type table of mseg.
    append lines of ymseg to l_ymseg.

    data: ref_mseg type ref to data.
    create data ref_mseg type mseg.
    get reference of l_ymseg into ref_mseg.

    data: l_yvm07m type table of vm07m.
    append lines of yvm07m to l_yvm07m.

    data: ref_vm07m type ref to data.
    create data ref_vm07m type vm07m.
    get reference of l_yvm07m into ref_vm07m.

    perform check_line_count using     space      0         1
                                       ref_mseg   ref_vm07m.

  else.

   DATA: WA_RSTRUCT   TYPE T_RSTRUCT.
   DATA: WA_XYMSEG    TYPE T_XYMSEG.
   DATA: HEADER       LIKE MSEG-ZEILE.
   DATA: LINE         LIKE MSEG-ZEILE.
   DATA: ARTICLE      LIKE MSEG-MATNR.
   DATA: XAUTO_COMP   LIKE MSEG-XAUTO.
   DATA: LINE_XYMSEG  LIKE SY-TABIX.
   DATA: PRE_COND_OK  TYPE C.

* *************************** testing preconditions
   PRE_COND_OK = SPACE.
   PERFORM RETAIL_STRUCT_PRECONDITIONS USING PRE_COND_OK.
   CHECK PRE_COND_OK = X.

*                           * acutal version works only for YMseg-Test
   CHECK KZ_YMSEG = X.
* ***************************

*                           * no sence to make Checks without any
*                           * Retail-structures
   READ TABLE IT_RSTRUCT INTO WA_RSTRUCT INDEX 1.
   CHECK SY-SUBRC IS INITIAL.
*                           * make a partial copy of YMESG or XMSEG
   IF NOT KZ_YMSEG IS INITIAL.
      PERFORM RETAIL_STRUCT_GET_YMSEG.
   ELSE.
      PERFORM RETAIL_STRUCT_COPY_XMSEG.
   ENDIF.

*                          * only headers need to be checked
   LOOP AT IT_RSTRUCT INTO WA_RSTRUCT
                           WHERE MATNRVOR IS INITIAL.
      LOOP AT IT_XYMSEG INTO WA_XYMSEG
                           WHERE MATNR = WA_RSTRUCT-MATNR
                             AND BSTME = WA_RSTRUCT-BSTME
                             AND ERFME = WA_RSTRUCT-ERFME
                             AND XAUTO = WA_RSTRUCT-XAUTO.    " 454005
*                           * actual line LINE_XYMSEG
         LINE_XYMSEG = SY-TABIX.
*                            * start of the check-sequence
*
*                            * don't check the second line of the head
*                            * when the components get exploded
*                            * in the 2-step-scenario
         IF     WA_XYMSEG-ATTYP BETWEEN '10' AND '12'         " 454005
            AND WA_XYMSEG-SHKZG <>      WA_RSTRUCT-SHKZG      " 454005
            AND WA_XYMSEG-MATNR =       WA_RSTRUCT-MATNR.     " 454005
           CONTINUE.                                          " 454005
         ENDIF.                                               " 454005
*                            * ---------------------------------
*                            * full items and empties
*                            * ---------------------------------
         IF     WA_RSTRUCT-UPVOR = UPTYP_LG.
*                            * full item:
            HEADER         = WA_XYMSEG-ZEILE.
            ARTICLE        = WA_XYMSEG-MATNR.
            LINE           = WA_XYMSEG-ZEILE.
            XAUTO_COMP     = L.          " no transfer
            WA_XYMSEG-KZOK = X.
            MODIFY IT_XYMSEG INDEX LINE_XYMSEG FROM WA_XYMSEG.
*                            * all empties have to be found
            PERFORM RETAIL_STRUCT_CHECK_COMPONENTS USING WA_RSTRUCT
                                                         KZ_YMSEG
                                                         HEADER
                                                         ARTICLE
                                                         LINE
                                                         LINE_XYMSEG
                                                               "391224
                                                         WA_XYMSEG-ERFMG
                                                         XAUTO_COMP.

*                            * ---------------------------------
*                            * generic articles
*                            * ---------------------------------
         ELSEIF WA_RSTRUCT-UPVOR = UPTYP_VAR.
*                            * generic article head
            HEADER         = WA_XYMSEG-ZEILE.
            ARTICLE        = WA_XYMSEG-MATNR.
            LINE           = WA_XYMSEG-ZEILE.
            XAUTO_COMP     = SPACE.
            WA_XYMSEG-KZOK = X.
            MODIFY IT_XYMSEG INDEX LINE_XYMSEG FROM WA_XYMSEG.
*                            * all components have to be found
            perform RETAIL_STRUCT_CHECK_COMPONENTS USING WA_RSTRUCT
                                                         KZ_YMSEG
                                                         HEADER
                                                         ARTICLE
                                                         LINE
                                                         LINE_XYMSEG
                                                               "391224
                                                         WA_XYMSEG-ERFMG
                                                         XAUTO_COMP.

*                            * ---------------------------------
*                            * structured articles
*                            * ---------------------------------
         ELSEIF ( WA_RSTRUCT-ATTYP = ATTYP-VKS
              OR  WA_RSTRUCT-ATTYP = ATTYP-LOT
              OR  WA_RSTRUCT-ATTYP = ATTYP-DIS )
              AND WA_RSTRUCT-XAUTO IS INITIAL.
*                            * structured article head
            HEADER         = WA_XYMSEG-ZEILE.
            ARTICLE        = WA_XYMSEG-MATNR.
            LINE           = WA_XYMSEG-ZEILE.
            XAUTO_COMP     = S.          " no transfer
            WA_XYMSEG-KZOK = X.
            MODIFY IT_XYMSEG INDEX LINE_XYMSEG FROM WA_XYMSEG.
*                            * all components have to be found
            PERFORM RETAIL_STRUCT_CHECK_COMPONENTS USING WA_RSTRUCT
                                                         KZ_YMSEG
                                                         HEADER
                                                         ARTICLE
                                                         LINE
                                                         LINE_XYMSEG
                                                               "391224
                                                         WA_XYMSEG-ERFMG
                                                         XAUTO_COMP.

         ENDIF.
      ENDLOOP. "IT_XYMSEG
   ENDLOOP. "IT_RSTRUCT

*                           * Postcondition:
*                           * if there are any unmarked items, there
*                           * must be an inconsistency
   LOOP AT IT_XYMSEG INTO WA_XYMSEG
           WHERE KZOK = SPACE.

*                           * actual line LINE_XYMSEG
      LINE_XYMSEG    = SY-TABIX.
      HEADER         = WA_XYMSEG-ZEILE.
      ARTICLE        = WA_XYMSEG-MATNR.
      LINE           = WA_XYMSEG-ZEILE.
      XAUTO_COMP     = WA_XYMSEG-xauto.

*                           * XAUTO = SPACE  .. header ?       " 391224
*                           * header of what (L, S or Blank)   " 391224
      IF XAUTO_COMP  = SPACE.                                  " 391224
         READ TABLE IT_RSTRUCT INTO WA_RSTRUCT                 " 391224
              WITH KEY MATNR = WA_XYMSEG-MATNR                 " 391224
                       BSTME = WA_XYMSEG-BSTME                 " 391224
                       ERFME = WA_XYMSEG-ERFME                 " 391224
                       XAUTO = SPACE.                          " 391224
         IF SY-SUBRC IS INITIAL.                               " 391224
            IF WA_RSTRUCT-UPVOR = UPTYP_LG                     " 391224
               AND WA_RSTRUCT-MATNRVOR IS INITIAL.             " 391224
               XAUTO_COMP     = L.                             " 391224
            ELSEIF ( WA_RSTRUCT-ATTYP = ATTYP-VKS              " 391224
                 OR  WA_RSTRUCT-ATTYP = ATTYP-LOT              " 391224
                 OR  WA_RSTRUCT-ATTYP = ATTYP-DIS )            " 391224
                 AND WA_RSTRUCT-MATNRVOR IS INITIAL.           " 391224
               XAUTO_COMP     = S.                             " 391224
            ENDIF.                                             " 391224
         ENDIF.                                                " 391224
      ENDIF.                                                   " 391224
*                           * no message in the case of generic
*                           * components, because they can be created
*                           * by using the matrix-box
      IF NOT XAUTO_COMP  = SPACE.
        PERFORM RETAIL_STRUCT_MESSAGE_BOX USING LINE_XYMSEG
                                                HEADER
                                                ARTICLE
                                                LINE
                                                XAUTO_COMP
                                                KZ_YMSEG.
      ENDIF.
   ENDLOOP. "IT_XYMSEG

   IF XMBWL IS INITIAL.                                        " 385732
*                           * last chance to stop the user     " 385732
      LOOP AT IT_XYMSEG INTO WA_XYMSEG                         " 385732
              WHERE KZOK = SPACE.                              " 385732
*                           * actual line LINE_XYMSEG          " 385732
         LINE_XYMSEG    = SY-TABIX.                            " 385732
         HEADER         = WA_XYMSEG-ZEILE.                     " 385732
         ARTICLE        = WA_XYMSEG-MATNR.                     " 385732
         LINE           = WA_XYMSEG-ZEILE.                     " 385732
         XAUTO_COMP     = WA_XYMSEG-xauto.                     " 385732
*                           * XAUTO = SPACE  .. header ?       " 391224
*                           * header of what (L, S or Blank)   " 391224
         IF XAUTO_COMP  = SPACE.                               " 391224
            READ TABLE IT_RSTRUCT INTO WA_RSTRUCT              " 391224
                 WITH KEY MATNR = WA_XYMSEG-MATNR              " 391224
                          BSTME = WA_XYMSEG-BSTME              " 391224
                          ERFME = WA_XYMSEG-ERFME              " 391224
                          XAUTO = SPACE.                       " 391224
            IF SY-SUBRC IS INITIAL.                            " 391224
               IF WA_RSTRUCT-UPVOR = UPTYP_LG                  " 391224
                  AND WA_RSTRUCT-MATNRVOR IS INITIAL.          " 391224
                  XAUTO_COMP     = L.                          " 391224
               ELSEIF ( WA_RSTRUCT-ATTYP = ATTYP-VKS           " 391224
                    OR  WA_RSTRUCT-ATTYP = ATTYP-LOT           " 391224
                    OR  WA_RSTRUCT-ATTYP = ATTYP-DIS )         " 391224
                    AND WA_RSTRUCT-MATNRVOR IS INITIAL.        " 391224
                  XAUTO_COMP     = S.                          " 391224
               ENDIF.                                          " 391224
            ENDIF.                                             " 391224
         ENDIF.                                                " 391224
*                           * no message in the case of generic" 385732
*                           * components                       " 385732
         IF NOT XAUTO_COMP  = SPACE.                           " 385732
*                 * fault in the structure for material        " 385732
            MESSAGE E370 WITH ARTICLE.                         " 385732
         ENDIF.                                                " 385732
      ENDLOOP. "IT_XYMSEG                                      " 385732
   ENDIF.                                                      " 385732

  endif.

ENDFORM.                    "RETAIL_STRUCT_CHECK_IT
* *************************************************** END   Note 356129
*&---------------------------------------------------------------------*
*&      Form  check_line_count
*&---------------------------------------------------------------------*
*       checks if every main position has still it's sub items
*        (comparison with vm07m-line_count which has been filled during
*         processing for full products, heads of structured articles
*         and generic articles)
*       i_recursion = 'X' means we're checking sub components
*       -> initial call on top level with blank parent_id
*       -> loop over all main items
*       no check on lost transfer lines as these get generated right
*        afterwards (xauto = X) except for xauto = u (structured
*        article) as those get generated seperately and are already
*        known here
*----------------------------------------------------------------------*
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_REF_MSEG  text
*      -->P_REF_VM07M  text
*      <--P_DUMMY  text
*----------------------------------------------------------------------*
form check_line_count using    i_recursion   type char1
                               i_line_id     type mb_line_id
                               i_mseg_zeile  type mseg-zeile
                               ir_mseg       type ref to data
                               ir_vm07m      type ref to data.

  types: tt_mseg type table of mseg.

  field-symbols: <fs_mseg> type tt_mseg.
  assign ir_mseg->* to <fs_mseg>.
  field-symbols <wa_mseg> type mseg.

  types: tt_vm07m type table of vm07m.

  field-symbols: <fs_vm07m> type tt_vm07m.
  assign ir_vm07m->* to <fs_vm07m>.
  field-symbols <wa_vm07m> type vm07m.

  data: l_child_count type MB_LINE_DEPTH.
  data: child_detected(1).

  loop at <fs_mseg> assigning <wa_mseg> where parent_id = i_line_id.
*   loop over all children

    if not i_recursion is initial.
*     deeper than the top level

      child_detected = 'X'.

      read table <fs_vm07m>                                     "602466
                 with key zeilv = i_mseg_zeile                  "602466
                 assigning <wa_vm07m>.                          "602466
*     corresponding vm07m of the head                           "602466

      if <wa_mseg>-kzbew = 'B'.
*       has only the 101 with parent of the 647-head, not the sub items

        if <wa_vm07m>-kzbwa = kzbwa-05 or
           <wa_vm07m>-kzbwa = kzbwa-04.
*         don't count the 101-line in a 1-step-s.t.o.
          clear child_detected.
        endif. "kzbwa

      endif. "kzbew

      if not child_detected is initial and                      "602466
         not ( <wa_vm07m>-attyp = '01' and                      "602466
                <wa_mseg>-erfmg = 0 ).                          "602466
*        this is necessary because sometimes variants with zero quant.
*         appear in mat.doc.s and sometimes they don't (ELIKZ..)"602466
*        as we neglect those for line_count we ought to do the same here
        add 1 to l_child_count.
      endif.
    endif.

    perform check_line_count using 'X'
                                   <wa_mseg>-line_id
                                   <wa_mseg>-zeile
                                   ir_mseg
                                   ir_vm07m.

  endloop. "<fs_mseg>

  if not i_recursion is initial.
*   deeper than the top level

*   get the line_count for the current mseg-line
    read table <fs_vm07m>
               with key zeilv = i_mseg_zeile
               assigning <wa_vm07m>.

*   compare number of sub components
    if     <wa_vm07m>-line_count <> l_child_count and
       not <wa_vm07m>-xstor       = 3             and
*      still some errors in MBSU, so we neglect it so far
       not <wa_vm07m>-line_count is initial.
*     the second is the restriction to retail cause line_count gets
*     only filled for retail articles
      message e358.
    endif.

  endif. "i_recursion

endform.                    " check_line_count
*&---------------------------------------------------------------------*
*&      Form  get_line_count_old_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VM07M_LINE_COUNT  text
*----------------------------------------------------------------------*
form get_line_count_old_doc changing p_line_count.

  clear p_line_count.

  loop at xmseg transporting no fields
      where parent_id = xmseg-line_id and
                xauto <> 'X'.
*   search all childs for that item
*   (not the generated lines, only relevant for str. art.)
    add 1 to p_line_count.
  endloop.

endform.                    " get_line_count_old_doc
*&---------------------------------------------------------------------*
*&      Form  read_item_position
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ITEM_POSITION  text
*----------------------------------------------------------------------*
FORM read_item_position  using p_lfbja                "Note 805560
                               p_lfbnr
                               p_lfpos
                               p_trtyp
                         CHANGING P_ITEM_POSITION.


  data: wa_mseg like mseg.
  statics: it_mseg like mseg occurs 0.
* if we have already read the document, we do not read it again
  read table it_mseg into wa_mseg with key mblnr = p_lfbnr
                                           mjahr = p_lfbja.
  if sy-subrc <> 0.

    CALL FUNCTION 'MB_READ_MATERIAL_POSITION'
      EXPORTING
        MBLNR           = p_lfbnr
        MJAHR           = p_lfbja
        TRTYP           = p_trtyp
*   ZEILB           =
*   ZEILE           =
      TABLES
        SEQTAB          = it_mseg
*   MBLPO_TAB       =
              .

  endif.
* if the line being processed contains tied empties, get the urzei
  read table it_mseg into wa_mseg with key mblnr = p_lfbnr
                                           mjahr = p_lfbja
                                           zeile = p_lfpos.

  if sy-subrc = 0.
    p_item_position = wa_mseg-urzei.
  endif.

ENDFORM.                    " read_item_position