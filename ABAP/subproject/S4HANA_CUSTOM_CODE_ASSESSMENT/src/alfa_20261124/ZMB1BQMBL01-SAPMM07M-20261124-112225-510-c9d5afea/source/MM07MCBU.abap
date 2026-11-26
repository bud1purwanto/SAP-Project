*-----------------------------------------------------------------------
*        COMMON DATA
*-----------------------------------------------------------------------

DATA: BEGIN OF COMMON PART mm07mcbu.

*------- Materialbeleg
DATA: BEGIN OF xmkpf OCCURS 0.
        INCLUDE STRUCTURE mkpf.
DATA: END OF xmkpf.
DATA: BEGIN OF xmseg OCCURS 0.
        INCLUDE STRUCTURE mseg.
DATA: END OF xmseg.
DATA: BEGIN OF xvm07m OCCURS 0.
        INCLUDE STRUCTURE vm07m.
DATA: END OF xvm07m.

*-------- Schnittstelle Rechnungswesen         -----------------------*
DATA: rw_posnr LIKE accit-posnr.
DATA: rw_awtyp LIKE acchd-awtyp VALUE 'MKPF '.
DATA: BEGIN OF xacchd OCCURS 0.
        INCLUDE STRUCTURE acchd.
DATA: END OF xacchd.

DATA: BEGIN OF xaccit OCCURS 0.
        INCLUDE STRUCTURE accit.
DATA: END OF xaccit.

* global table type definition for JFMIP - MAA-DEV          "MAA EhP4
types : stab_xaccit          type  standard table of accit. "MAA EhP4

DATA: gs_accit_ext TYPE accit_extension,                    "593240
      gt_accit_ext TYPE STANDARD TABLE OF accit_extension.  "593240

* global table type definition for JFMIP - MAA-DEV          "MAA EhP4
types : stab_accit_ext       TYPE STANDARD TABLE OF         "MAA EhP4
                                  accit_extension.          "MAA EhP4

TYPES : stab_zdm07m          TYPE  STANDARD TABLE OF dm07m.

DATA: BEGIN OF xacccr OCCURS 0.
        INCLUDE STRUCTURE acccr.
DATA: END OF xacccr.

* global table type definition for JFMIP - MAA-DEV          "MAA EhP4
types : stab_xacccr          type  standard table of acccr. "MAA EhP4


DATA: BEGIN OF yacccr OCCURS 0.
        INCLUDE STRUCTURE acccr.
DATA    xsubs TYPE zcxcm-xsubs.                             " 635226
DATA: END OF yacccr.

*-------- Tabelle der vorläufigen Belegnummern -----------------------*
DATA: BEGIN OF lfbnr OCCURS 0,
        zeile LIKE mseg-zeile,
      END OF lfbnr.

*------- Dispositionsdaten -------------------------------------------*
DATA: BEGIN OF xmdcp OCCURS 0.
        INCLUDE STRUCTURE mdcp.
DATA: END OF xmdcp.

*------- Verbrauchsfortschreibung im Materialstamm -------------------*
DATA: BEGIN OF xvstat OCCURS 0.
        INCLUDE STRUCTURE vstat.
DATA: END OF xvstat.

*------- Kommunikationssätze LVS--------------------------------------*
DATA: BEGIN OF xlk01 OCCURS 0.
        INCLUDE STRUCTURE lk01.
DATA: END OF xlk01.
DATA: BEGIN OF xlk02 OCCURS 0.
        INCLUDE STRUCTURE lk02.
DATA: END OF xlk02.
DATA: BEGIN OF xltbub OCCURS 0.
        INCLUDE STRUCTURE ltbub.
DATA: END OF xltbub.
DATA: BEGIN OF xldile OCCURS 0.
        INCLUDE STRUCTURE ldile.
DATA: END OF xldile.

*------- Bestellentwicklung ------------------------------------------*
DATA: BEGIN OF wekbe OCCURS 0.
        INCLUDE STRUCTURE ekbe.
DATA: END OF wekbe.
DATA: BEGIN OF xekbe OCCURS 0.
        INCLUDE STRUCTURE ekbe.
DATA: END OF xekbe.
DATA: BEGIN OF xekbz OCCURS 0.
        INCLUDE STRUCTURE ekbz.
DATA: END OF xekbz.
DATA: BEGIN OF it_sum_xekbe OCCURS 0,                       "MAA2
                MANDT TYPE EKBE-MANDT,
                EBELN TYPE EKBE-EBELN,
                EBELP TYPE EKBE-EBELP,
                ZEKKN TYPE EKBE-ZEKKN,
                VGABE TYPE EKBE-VGABE,
                GJAHR TYPE EKBE-GJAHR,
                BELNR TYPE EKBE-BELNR,
                BUZEI TYPE EKBE-BUZEI,
                MENGE TYPE EKBE-MENGE,
                BPMNG TYPE EKBE-BPMNG,
                DMBTR TYPE EKBE-DMBTR,
                WRBTR TYPE EKBE-WRBTR,
                AREWR TYPE EKBE-AREWR,
                WESBS TYPE EKBE-WESBS,
                BPWES TYPE EKBE-BPWES,
                REEWR TYPE EKBE-REEWR,
                REFWR TYPE EKBE-REFWR,
                LSMNG TYPE EKBE-LSMNG,
                LSMEH TYPE EKBE-LSMEH,
                BAMNG TYPE EKBE-BAMNG,
                AREWB TYPE EKBE-AREWB,
                REWRB TYPE EKBE-REWRB,
                MENGE_POP TYPE EKBE-MENGE_POP,
                BPMNG_POP TYPE EKBE-BPMNG_POP,
                DMBTR_POP TYPE EKBE-DMBTR_POP,
                WRBTR_POP TYPE EKBE-WRBTR_POP,
                WESBB TYPE EKBE-WESBB,
                BPWEB TYPE EKBE-BPWEB,
                AREWR_POP TYPE EKBE-AREWR_POP,
                KUDIF TYPE EKBE-KUDIF,
                RETAMT_FC TYPE EKBE-RETAMT_FC,
                RETAMT_LC TYPE EKBE-RETAMT_LC,
                RETAMTP_FC TYPE EKBE-RETAMTP_FC,
                RETAMTP_LC TYPE EKBE-RETAMTP_LC.
DATA: END OF it_sum_xekbe.

* MAA EhP4 -Start ------------------------------------------"MAA EhP4
DATA: BEGIN OF xekbe_ma OCCURS 0.
        INCLUDE STRUCTURE ekbe_ma_s.
DATA: END OF xekbe_ma.

DATA: BEGIN OF xekbz_ma OCCURS 0.
        INCLUDE STRUCTURE ekbz_ma.
DATA: END OF xekbz_ma.
* MAA EhP4 -End --------------------------------------------"MAA EhP4

*----------Subcontracting------------------------------------
* Begin SC EhP4
DATA: BEGIN OF xekbe_sc OCCURS 0.
        INCLUDE STRUCTURE ekbe_sc.
DATA: END OF xekbe_sc.
* End SC EhP4
*-------   Auftragsentwicklung  Beginn -----------------------
DATA: BEGIN OF xaufbe OCCURS 0.
        INCLUDE STRUCTURE cki_aufbe.
DATA: END OF xaufbe.
DATA: BEGIN OF xaufbe_cr OCCURS 0.
        INCLUDE STRUCTURE cki_aufbe_cr.
DATA: END OF xaufbe_cr.
DATA: BEGIN OF yaufbe_cr OCCURS 0.
        INCLUDE STRUCTURE cki_aufbe_cr.
DATA: END OF yaufbe_cr.
DATA: BEGIN OF zaufbe_cr OCCURS 0.
        INCLUDE STRUCTURE cki_aufbe_cr.
DATA: END OF zaufbe_cr.
*-------   Auftragsentwicklung  Ende  ------------------------

DATA: BEGIN OF wekbe_cr OCCURS 0.
        INCLUDE STRUCTURE cki_ekbecr.
DATA: END OF wekbe_cr.
DATA: BEGIN OF xekbe_cr OCCURS 0.
        INCLUDE STRUCTURE cki_ekbecr.
DATA: END OF xekbe_cr.
DATA: BEGIN OF yekbe_cr OCCURS 0.
        INCLUDE STRUCTURE cki_ekbecr.
DATA: END OF yekbe_cr.

* MAA EhP4 -Start                                           "MAA EhP4
* global table type definition for JFMIP - MAA-DEV
types : stab_yekbe_cr        type  standard table of cki_ekbecr.
* MAA EhP4 -End                                             "MAA EhP4

DATA: BEGIN OF xekbz_cr OCCURS 0.
        INCLUDE STRUCTURE cki_ekbzcr.
DATA: END OF xekbz_cr.

*------ Aufteiler -----------------------------------------------------*
DATA: BEGIN OF xauwei OCCURS 0.
        INCLUDE STRUCTURE rauwei.
DATA: END OF xauwei.

DATA: BEGIN OF xpxvaf OCCURS 0.
        INCLUDE STRUCTURE pxvaf.
DATA: END OF xpxvaf.

DATA: BEGIN OF ypxvaf OCCURS 0.
        INCLUDE STRUCTURE pxvaf.
DATA: END OF ypxvaf.

*------ Aufträge ------------------------------------------------------*
DATA: BEGIN OF xfabe OCCURS 0.
        INCLUDE STRUCTURE fabe.
DATA: END OF xfabe.

DATA: BEGIN OF zfabe OCCURS 0.
        INCLUDE STRUCTURE fabe.
DATA: END OF zfabe.

*------- LIFO-Einzelposten -------------------------------------------*
DATA: BEGIN OF xlifo OCCURS 0.
        INCLUDE STRUCTURE slifo.
DATA: END OF xlifo.

*------- Primärbedarfsabbeu ------------------------------------------*
DATA: BEGIN OF xpbat OCCURS 0.
        INCLUDE STRUCTURE pbat.
DATA: END OF xpbat.

*------- Konsignationsentwicklung ------------------------------------*
DATA: BEGIN OF xrkwa OCCURS 0.
        INCLUDE STRUCTURE rkwa.
DATA: END OF xrkwa.

*------- Obewentwicklung ---------------------------------------------*
DATA: BEGIN OF xrowa OCCURS 0.                                     "kaz
        INCLUDE STRUCTURE rowa.                                     "kaz
DATA: END OF xrowa.                                                 "kaz

*------- Fremdbearbeitungsabwicklung----------------------------------*
DATA: BEGIN OF xexop OCCURS 0.
        INCLUDE STRUCTURE exop.
DATA: END OF xexop.

DATA: xdialog_buchen.

ENHANCEMENT-POINT MM07MCBU_01 SPOTS ES_MM07MCBU STATIC INCLUDE BOUND.
DATA: END OF COMMON PART.

*------- BADIs --------------------------------------------------------*
CLASS: cl_ex_mb_document_badi DEFINITION LOAD.
DATA:  mb_document_badi  TYPE REF TO if_ex_mb_document_badi.
CLASS: cl_ex_mb_doc_badi_internal DEFINITION LOAD.
DATA:  mb_doc_badi_internal TYPE REF TO if_ex_mb_doc_badi_internal.
DATA:  lo_mb_doc_raise_a2a TYPE REF TO mb_doc_raise_a2a.

*----------------------------------------------------------------------*
*------ particular definitions and tables for MAA only -----"MAA EhP4
*----------------------------------------------------------------------*

* working area for saving data fields  from DM07M           " MAA2
DATA : gs_dm07m_save              TYPE  dm07m,              " MAA2
       gv_flag_dm07m_saved        TYPE  abap_bool.          " MAA2

* for the error handling during MAA processing              " MAA2
DATA : gv_flag_error         TYPE  abap_bool,               " MAA2
       gt_message_log        TYPE  bapirettab.              " MAA2
*----------------------------------------------------------------------*