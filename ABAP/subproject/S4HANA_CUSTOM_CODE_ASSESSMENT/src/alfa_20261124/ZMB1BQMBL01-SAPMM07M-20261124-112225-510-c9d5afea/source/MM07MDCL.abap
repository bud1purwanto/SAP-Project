*----------------------------------------------------------------------*
*   INCLUDE MM07MDCL                                                   *
*----------------------------------------------------------------------*
*   DATA-Definitionen Klassifizierung
*----------------------------------------------------------------------*

DATA: cl_artxt               LIKE rmclf-artxt,
      cl_batch               TYPE c,
      cl_batch_new           TYPE c,
      cl_class               LIKE klah-class,
      cl_class_org           LIKE klah-class,
      cl_klart               LIKE rmclf-klart,
      cl_no_display          TYPE c,
      cl_cuobj               LIKE inob-cuobj,
      cl_object              LIKE rmclf-objek,
      cl_object_m            LIKE rmclf-objek,
      cl_refobj              LIKE rmclf-objek,
      cl_okcode              LIKE sy-ucomm,
      cl_status              TYPE c,
      cl_table               LIKE tclt-obtab,
      cl_ptable              LIKE tclt-obtab,
      cl_ptable_m            LIKE tclt-obtab,
      cl_umshk               LIKE mseg-shkzg,
      cl_kzcla               TYPE kzcla,
      cl_exist               TYPE c,
      cl_update              TYPE c,
      cl_exist_org           TYPE c,
      cl_org_batch           LIKE mcha-charg,
      cl_tar_batch           LIKE mcha-charg,
      cl_modif               TYPE c,
      cl_modif_before_clas   TYPE c,
      cl_cfc_done            TYPE c,
      cl_confirm_class       TYPE c,
      cl_other_object        TYPE c,
      cl_batch_classified    TYPE c,
      cl_prekey(14)          TYPE c VALUE '&MSEG_________',
      cl_mseg                LIKE tclt-obtab VALUE 'MSEG      ',
      k_table_mcha           LIKE tclt-obtab VALUE 'MCHA      ',
      k_table_mch1           LIKE tclt-obtab VALUE 'MCH1      ',
      k_table_mara           LIKE tclt-obtab VALUE 'MARA      '.

DATA: BEGIN OF cl_objecttab OCCURS 0.
        INCLUDE STRUCTURE cltable.
DATA: END OF cl_objecttab.

DATA: BEGIN OF cl_objecttab1 OCCURS 0.
        INCLUDE STRUCTURE cltable.
DATA: END OF cl_objecttab1.

DATA: BEGIN OF cl_api_kssk OCCURS 0.
        INCLUDE STRUCTURE api_kssk.
DATA: END OF cl_api_kssk.

DATA: BEGIN OF cl_api_char OCCURS 0.
        INCLUDE STRUCTURE api_char.
DATA: END OF cl_api_char.

DATA: BEGIN OF cl_api_ochar OCCURS 0.
        INCLUDE STRUCTURE api_ochar.
DATA: END OF cl_api_ochar.

DATA: BEGIN OF cl_api_ch_att OCCURS 0.
        INCLUDE STRUCTURE api_ch_att.
DATA: END OF cl_api_ch_att.

DATA: BEGIN OF cl_api_val_i OCCURS 0.
        INCLUDE STRUCTURE api_val_i.
DATA: END OF cl_api_val_i.

DATA: BEGIN OF cl_api_val_s OCCURS 0.
        INCLUDE STRUCTURE api_val_i.
DATA: END OF cl_api_val_s.

DATA: BEGIN OF cl_api_val_e OCCURS 0.
        INCLUDE STRUCTURE api_val_i.
DATA: END OF cl_api_val_e.

DATA: BEGIN OF cl_api_val_o OCCURS 0.
        INCLUDE STRUCTURE api_val_i.
DATA: END OF cl_api_val_o.

DATA: BEGIN OF cl_api_val_d OCCURS 0.
        INCLUDE STRUCTURE api_val_i.
DATA: END OF cl_api_val_d.

DATA: BEGIN OF cl_api_value OCCURS 0.
        INCLUDE STRUCTURE api_value.
DATA: END OF cl_api_value.

DATA: BEGIN OF cl_qmsp OCCURS 0,
        matnr LIKE mara-matnr,
        atinn LIKE cabn-atinn,
        ok    TYPE c.
DATA: END OF cl_qmsp.

DATA: BEGIN OF cl_qmsp_key,
        matnr LIKE mara-matnr,
        atinn LIKE cabn-atinn,
      END OF cl_qmsp_key.

DATA: BEGIN OF cl_mcha.
        INCLUDE STRUCTURE mcha.
DATA: END OF cl_mcha.

DATA: BEGIN OF cl_mch1.
        INCLUDE STRUCTURE mch1.
DATA: END OF cl_mch1.

DATA: BEGIN OF cl_mara.
        INCLUDE STRUCTURE mara.
DATA: END OF cl_mara.

DATA: BEGIN OF cl_makt.
        INCLUDE STRUCTURE makt.
DATA: END OF cl_makt.

*---- Schlüssel für Tabelle MCHB
DATA: BEGIN OF mchb_key,
        mandt LIKE mchb-mandt,
        matnr LIKE mchb-matnr,
        werks LIKE mchb-werks,
        lgort LIKE mchb-lgort,
        charg LIKE mchb-charg,
      END OF mchb_key.

*---- Schlüssel für Tabelle MCHA
DATA: BEGIN OF mcha_key,
        mandt LIKE mcha-mandt,
        matnr LIKE mcha-matnr,
        werks LIKE mcha-werks,
        charg LIKE mcha-charg,
      END OF mcha_key.

*---- Schlüssel für Tabelle MCH1
DATA: BEGIN OF mch1_key,
        mandt LIKE mch1-mandt,
        matnr LIKE mch1-matnr,
        charg LIKE mch1-charg,
    END OF mch1_key.

*---- Schlüssel für Klassifizierungsobjekt MCHA
DATA: BEGIN OF cl_mcha_key,
        matnr LIKE mcha-matnr,
        werks LIKE mcha-werks,
        charg LIKE mcha-charg,
      END OF cl_mcha_key.

*---- Schlüssel für Klassifizierungsobjekt MCH1
DATA: BEGIN OF cl_mch1_key,
        matnr LIKE mch1-matnr,
        charg LIKE mch1-charg,
      END OF cl_mch1_key.

*---- Interne Tabelle der bereits klassifizierten Chargen/Objekte
DATA: BEGIN OF xinob OCCURS 0,
        cuobj LIKE inob-cuobj,
        objek LIKE inob-objek.
DATA: END OF xinob.

DATA: BEGIN OF ex_batch_data,
        lvorm LIKE mch1-lvorm,
        ersda LIKE mch1-ersda,
        ernam LIKE mch1-ernam,
        aenam LIKE mch1-aenam,
        laeda LIKE mch1-laeda,
        zaedt LIKE mch1-zaedt,
        fvdt1 LIKE mch1-fvdt1,
        fvdt2 LIKE mch1-fvdt2,
        fvdt3 LIKE mch1-fvdt3,
        fvdt4 LIKE mch1-fvdt4,
        fvdt5 LIKE mch1-fvdt5,
        fvdt6 LIKE mch1-fvdt6,
        herkl LIKE mch1-herkl,
        herkr LIKE mch1-herkr,
        mtver LIKE mch1-mtver,
      END OF ex_batch_data.

DATA: BEGIN OF fix_batch_data,
        bwtar LIKE mcha-bwtar,
        lifnr LIKE mcha-lifnr,
        lwedt LIKE mcha-lwedt,
        vfdat LIKE mcha-vfdat,
        hsdat LIKE mcha-hsdat,
        verab LIKE mcha-verab,
        qndat LIKE mcha-qndat,
      END OF fix_batch_data.

*---- Schnittstelle Chargenfindung und CFC-003
DATA: xkomkh    LIKE komkh.
DATA: xkomph    LIKE komph.
DATA: xmbcfc003 LIKE mbcfc003.

DATA: BEGIN OF e_bdbatch OCCURS 0.
        INCLUDE STRUCTURE bdbatch.
DATA: END OF e_bdbatch.

DATA: BEGIN OF i_bdbatch OCCURS 0.
        INCLUDE STRUCTURE bdbatch.
DATA: END OF i_bdbatch.

*---- Schnittstelle Bestandsfindung
DATA: BEGIN OF e_bfstock OCCURS 0.
        INCLUDE STRUCTURE bfstock.
DATA: END OF e_bfstock.