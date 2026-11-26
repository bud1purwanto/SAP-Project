* Data-Definition...
include lkv20da4.
include lkv20da6.
TABLES: KKS00.
data: PA_KOKRS  like KKS00-KOKRS value is initial,
      PA_BATCH  like KKS00-BATCH value is initial,
      PA_WERKS  LIKE KKS00-WERKS value is initial,

      PA_AUFNR  LIKE KKS00-AUFNR value is initial,
      PA_AUFNB  LIKE KKS00-AUFNB value is initial,
      PA_AUART  LIKE KKS00-AUART value is initial,
      PA_AUTYP  LIKE KKS00-AUTYP value is initial,

      P_PROCNR  LIKE KKS00-PROCNR value is initial,
      P_PROCNB  LIKE KKS00-PROCNB value is initial,
      PA_SAFNR  LIKE KKS00-SAFNR value is initial,
      PA_SAFNB  LIKE KKS00-SAFNB value is initial,
      PA_VERID  LIKE KKS00-VERID value is initial,
      PA_MATNR  LIKE KKS00-MATNR value is initial,
      PA_MATNB  LIKE KKS00-MATNB value is initial,

      PA_KDAUF  LIKE KKS00-KDAUF value is initial,
      PA_KDAUB  LIKE KKS00-KDAUB value is initial,
      PA_KDPOS  LIKE KKS00-KDPOS value is initial,
      PA_PROJN  LIKE KKS00-PROJN value is initial,
      PA_PROJB  LIKE KKS00-PROJB value is initial,

      PA_PRIMS  LIKE KKS00-PRIMS value is initial,

      PA_OKCOD  LIKE KKS00-OKCOD value is initial,
      PA_TCODE  LIKE KKS00-TCODE value is initial,
      PA_DYNNR  LIKE KKS00-DYNNR value is initial,

*     P_KKS00C  LIKE KKS00C value is initial,

      PA_VERWS  LIKE KKS00-VERWS value is initial,
      PA_STAKZ  LIKE KKS00-STAKZ value is initial,
      PA_STAMD  LIKE KKS00-STAMD value is initial,
      PA_STANO  LIKE KKS00-STANO value is initial,
      PA_FORTS  LIKE KKS00-FORTS value is initial,
*     PA_TSTKZ  LIKE KKS00-TSTKZ value is initial,

      PA_INCLF  LIKE KKS00-INCLF value is initial,
      PA_INCLP  LIKE KKS00-INCLP value is initial,
      PA_INCLI  LIKE KKS00-INCLI value is initial,
*     PA_VSSEL  like KKS00-VSSEL value is initial,
      PA_VSALL  like KKS00-VSALL value is initial,
      PA_SAMML  like KKS00-SAMML value is initial,
      PA_OBJKT  like KKS00-OBJKT value is initial,
      PA_AWVRS  like KKS00-AWVRS value is initial.
data: PA_ANZVS  like KKS07-ANZVS value is initial,
      PA_INITI  like KV042-XFELD value 'X',
      PA_KKS04  like KKS04,
      PA_REPID  like SY-REPID.
data: TA_KV20A  like KV20A OCCURS 5,
      TA_KV20B  like KV20B OCCURS 5,
      TA_DYFLD  LIKE dynpread OCCURS 2 WITH HEADER LINE,
      TA_TXTPL  TYPE TEXTPOOL OCCURS 50 WITH HEADER LINE.
* Sender Selektion -> Funktionsgruppe KASS...
DATA: BEGIN OF IT_SENDER OCCURS 0.
        INCLUDE STRUCTURE COSEL2.
DATA: END   OF IT_SENDER.
* Hilfsfelder...
DATA: HLP_VARIANT LIKE RSVAR-VARIANT,
      HLP_ONE,
      HLP_SELART  TYPE KASS_SELART,
      HLP_LISTF   LIKE KV042-XFELD,
      HLP_AWVSE   LIKE KV042-XFELD,
      HLP_LINES   TYPE I.
* Flags...
DATA: FLG_AWVSE LIKE KV042-XFELD.
INCLUDE <ICON>.