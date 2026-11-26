***INCLUDE LKKAGF89.

*.Abweichungskategorien.................................................
DATA: ABKAT_ABW_RST     LIKE COSBA-ABKAT VALUE '31'.

*.Abgrenzungskategorien.................................................
DATA: ABKAT_0           LIKE COSBA-ABKAT VALUE '50',
      ABKAT_BST_KOS_AP  LIKE COSBA-ABKAT VALUE '51',
      ABKAT_BST_KOS_AW  LIKE COSBA-ABKAT VALUE '52',
      ABKAT_BST_KOS_NF  LIKE COSBA-ABKAT VALUE '53',
      ABKAT_RUE_KOS_AP  LIKE COSBA-ABKAT VALUE '54',
      ABKAT_RUE_KOS_AW  LIKE COSBA-ABKAT VALUE '55',
      ABKAT_RUE_KOS_NF  LIKE COSBA-ABKAT VALUE '56',
      ABKAT_RUE_PRO_AP  LIKE COSBA-ABKAT VALUE '57',
      ABKAT_RUE_PRO_AW  LIKE COSBA-ABKAT VALUE '58',
      ABKAT_RUE_PRO_NF  LIKE COSBA-ABKAT VALUE '59',
      ABKAT_RDV         LIKE COSBA-ABKAT VALUE '60',
      ABKAT_RDV_ANFB    LIKE COSBA-ABKAT VALUE '61',
      ABKAT_BST_ERG     LIKE COSBA-ABKAT VALUE '62',
      ABKAT_KDU_AP      LIKE COSBA-ABKAT VALUE '63',
      ABKAT_KDU_AW      LIKE COSBA-ABKAT VALUE '64',
      ABKAT_KDU_NF      LIKE COSBA-ABKAT VALUE '65',
      ABKAT_ERR_KOS     LIKE COSBA-ABKAT VALUE '66',
      ABKAT_ERR_ERL     LIKE COSBA-ABKAT VALUE '67',
      ABKAT_POC_BST_ERL LIKE COSBA-ABKAT VALUE '68',
      ABKAT_POC_RUE_ERL LIKE COSBA-ABKAT VALUE '69',
      ABKAT_POC_GEW     LIKE COSBA-ABKAT VALUE '70',
      ABKAT_POC_VRL     LIKE COSBA-ABKAT VALUE '71',
      ABKAT_POC_VREAL   LIKE COSBA-ABKAT VALUE '72',
      ABKAT_IST_KOS_BEW LIKE COSBA-ABKAT VALUE '73',
      ABKAT_IST_PRO_BEW LIKE COSBA-ABKAT VALUE '74',
      ABKAT_ERL         LIKE COSBA-ABKAT VALUE '75',          "P30F.MOD5
      ABKAT_ABW         LIKE COSBA-ABKAT VALUE '76',          "P30F.INS5
      ABKAT_POC_ANZ_BK  LIKE COSBA-ABKAT VALUE '79',            "H448150
      ABKAT_POC_ANZ_UE  LIKE COSBA-ABKAT VALUE '80',            "H448150
      abkat_plb_erl     like cosba-abkat value '81',           "H448150B
      abkat_plb_kos     like cosba-abkat value '82'.           "H448150B

*.Abgrenzungskategorien kreditorisch....................................
DATA: ABKAT_ABG_KOS_KRED LIKE COSBA-ABKAT VALUE '97',             "lupo1
      ABKAT_RUE_KRED     LIKE COSBA-ABKAT VALUE '98',             "lupo1
      ABKAT_BST_KRED     LIKE COSBA-ABKAT VALUE '99'.             "lupo1

*.Abgrenzungskategorien debitorisch.....................................
DATA: ABKAT_ABG_ERL_DEB LIKE COSBA-ABKAT VALUE '95',              "lupo1
      ABKAT_BST_DEB     LIKE COSBA-ABKAT VALUE '96'.              "lupo1