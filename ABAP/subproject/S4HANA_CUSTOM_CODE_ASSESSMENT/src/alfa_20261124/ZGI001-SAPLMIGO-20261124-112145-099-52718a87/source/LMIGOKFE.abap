*----------------------------------------------------------------------*
*                     <lg>                                             *
*   INCLUDE LMIGOKFE: tied empties handling                            *
*----------------------------------------------------------------------*

************************************************************************
*                               <LG>
* copy specific data of full product to tied empty;
* get sure that no individual data of the tied empty gets overwritten by
* full product data;
*
* input:
*     is_goitem_full : corresponding full product to the actual tied
*                      empty
*
* changing:
*     cs_goitem_empty : actual tied empty which has to be adjusted
************************************************************************
METHOD full_product_data_copy.

* structures of individual and optional data of tied empty
  DATA: ls_empty_individual  TYPE ty_s_empties_individual,
        ls_empty_opt         TYPE ty_s_empties_optional.

* save individual and optional data of empty
  MOVE-CORRESPONDING cs_goitem_empty TO ls_empty_individual.
  MOVE-CORRESPONDING cs_goitem_empty TO ls_empty_opt.
  MOVE-CORRESPONDING cs_goitem_empty TO ls_empty_opt-aab.
* take over all data of full product
  MOVE is_goitem_full  TO cs_goitem_empty.
* take over individual data
  MOVE-CORRESPONDING ls_empty_individual TO cs_goitem_empty.
* optional data (account assignment data, ..)
* if data of empty is filled -> take it over
* else take over data of full product
  DEFINE empty_optional.
    if not ls_empty_opt-&1 is initial.
      move ls_empty_opt-&1 to cs_goitem_empty-&1.
    endif.
  END-OF-DEFINITION.
*
  empty_optional grund.
  empty_optional grtxt.
  empty_optional konto.
* account assignment block
  DEFINE empty_optional_account_block.
    if not ls_empty_opt-aab-&1 is initial.
      move ls_empty_opt-aab-&1 to cs_goitem_empty-&1.
    endif.
  END-OF-DEFINITION.
*
  empty_optional_account_block kostl.
  empty_optional_account_block aufnr.
  empty_optional_account_block ps_psp_pnr.
  empty_optional_account_block kdauf.
  empty_optional_account_block kdpos.
  empty_optional_account_block kdein.
  empty_optional_account_block nplnr.
  empty_optional_account_block vornr.
  empty_optional_account_block fipos.
  empty_optional_account_block anln1.
  empty_optional_account_block anln2.
  empty_optional_account_block paobjnr.
  empty_optional_account_block imkey.
  empty_optional_account_block geber.
*  empty_optional_account_block budget_pd.
  empty_optional_account_block fistl.
  empty_optional_account_block fkber.
  empty_optional_account_block lstar.
  empty_optional_account_block prznr.
  empty_optional_account_block kstrg.
  empty_optional_account_block gsber.
  empty_optional_account_block prctr.
  empty_optional_account_block bukrs.
  empty_optional_account_block aufps.
  empty_optional_account_block aufpl.
  empty_optional_account_block aplzl.

ENDMETHOD.