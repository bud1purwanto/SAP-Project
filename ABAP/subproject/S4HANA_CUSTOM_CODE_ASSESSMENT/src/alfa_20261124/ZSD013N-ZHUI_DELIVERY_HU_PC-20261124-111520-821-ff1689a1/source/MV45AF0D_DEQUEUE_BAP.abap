*---------------------------------------------------------------------*
*       FORM MV45AF0D_DEQUEUE_BAP                                     *
*---------------------------------------------------------------------*
*       Dequeue BANF AUFK PLAF                                        *
*---------------------------------------------------------------------*
form dequeue_bap.
* this form runs only in BAPI
     check call_bapi = charx.
* it only runs , when bap are enqueued
     check g_dequeue_bap = charx.
     loop at xvbep.
* unlock purchase requisition
          if not xvbep-banfn is initial.
             call function 'DEQUEUE_EMEBANE'
                  exporting
                     banfn    = xvbep-banfn.
          endif.
* unlock assembly/service and planning orders
          if not xvbep-wmeng is initial.
             if not xvbep-aufnr is initial.
                call function 'DEQUEUE_ESORDER'
                     exporting
                        aufnr    = xvbep-aufnr.
             endif.
             if not xvbep-plnum is initial.
                call function 'DEQUEUE_EMPLAFE'
                     exporting
                        plnum    = xvbep-plnum.
             endif.
          endif.
     endloop.
     clear g_dequeue_bap.
endform.