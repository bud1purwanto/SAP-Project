*----------------------------------------------------------------------*
*   INCLUDE FV50UTYP
**----------------------------------------------------------------------
*

*--------tvuvs related:
* ECC 600 Replaced by DDIC definition SHP_TVUVS_WA

*---------ucadm: controls most of the uncompleteness calculation
types:
      begin of ucdl_ucadm_key_tbnam,
            tbnam like tvuvf-tbnam,
       end of ucdl_ucadm_key_tbnam.
types:
      begin of ucdl_ucadm_key.
        include type ucdl_ucadm_key_tbnam. types:
        parvw like vbuv-parvw,
        tdobject  like ttxit-tdobject,
        fehgr like tvuv-fehgr,
        tdid  like vbuv-tdid,
        fdnam like tvuvf-fdnam,
        pstyv like tvlp-pstyv,     "46A
      end of ucdl_ucadm_key.

types:
      begin of ucdl_ucadm .
        include type ucdl_ucadm_key. types:
        fcode like tvuvf-fcode. types:
        sortf like tvuvf-sortf.
        include type shp_tvuvs_wa. types:
        items,
        itdep,                 "type of item dependency of fcode
      end of ucdl_ucadm.

*-----
*-table storing current uncompleteness data, if in dialog

* ECC 600: Local types have been replaced by DDIC definitions in order
* to allow access from other software layers
*
*       Former Local Type     New DDIC Type
*
*       UCDL_PVBUV_KEY        SHP_PVBUV_KEY
*       UCDL_PVBUV            SHP_PVBUV
*       UCDL_T_PVBUV          SHP_PVBUV_T
*       UCDL_TVUVS_WA_2       SHP_TVUVS_WA_2
*       UCDL_TVUVS_WA         SHP_TVUVS_WA
*       UCDL_TVUVS_WA_1       -- (not needed)

*-----structure used as form routine parameter
*-----governing most of the working modes of the uc calculation
types:
      begin of ucdl_ucpar,
*--------------no uncompleteness dialog needed
               only_vbuv ,
*--------------Coll. proc. : create, save, exit - no change and recalc
               no_vbuv_delete ,
*--------------recalculate only touched items
               recalc ,
*--------------beginning of uncompleteness dialog:
*--------------special pvbuv handling: sort, and delete old items
               newcalc ,
*--------------only internal use as returncodes or local parameters:
               force_fcode like tvuvf-fcode,  "building ucadm
               new_ucadm_lines like sy-tfill,
               object_relevant ,
*--------------no current use
               fcode like tvuvf-fcode,  "recalc restriction
               check_for_deleted_items ,
               specific,
*--------------call from final check
               final_check,
      end of ucdl_ucpar.