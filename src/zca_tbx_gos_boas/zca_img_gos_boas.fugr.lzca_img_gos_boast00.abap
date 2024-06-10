*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCA_MV_GOS_BOAS.................................*
TABLES: ZCA_MV_GOS_BOAS, *ZCA_MV_GOS_BOAS. "view work areas
CONTROLS: TCTRL_ZCA_MV_GOS_BOAS
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZCA_MV_GOS_BOAS. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZCA_MV_GOS_BOAS.
* Table for entries selected to show on screen
DATA: BEGIN OF ZCA_MV_GOS_BOAS_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZCA_MV_GOS_BOAS.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZCA_MV_GOS_BOAS_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZCA_MV_GOS_BOAS_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZCA_MV_GOS_BOAS.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZCA_MV_GOS_BOAS_TOTAL.

*.........table declarations:.................................*
TABLES: TOJTB                          .
TABLES: TOJTT                          .
TABLES: ZCA_GOS_BOAS                   .
