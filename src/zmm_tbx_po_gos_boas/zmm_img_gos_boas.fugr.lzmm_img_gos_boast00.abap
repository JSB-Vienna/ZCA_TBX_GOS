*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_MV_GOSBOASDT................................*
TABLES: ZMM_MV_GOSBOASDT, *ZMM_MV_GOSBOASDT. "view work areas
CONTROLS: TCTRL_ZMM_MV_GOSBOASDT
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZMM_MV_GOSBOASDT. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZMM_MV_GOSBOASDT.
* Table for entries selected to show on screen
DATA: BEGIN OF ZMM_MV_GOSBOASDT_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZMM_MV_GOSBOASDT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZMM_MV_GOSBOASDT_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZMM_MV_GOSBOASDT_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZMM_MV_GOSBOASDT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZMM_MV_GOSBOASDT_TOTAL.

*.........table declarations:.................................*
TABLES: T161                           .
TABLES: T161T                          .
TABLES: TDWA                           .
TABLES: TDWAT                          .
TABLES: TOJTB                          .
TABLES: TOJTT                          .
TABLES: ZCA_GOS_BOAS                   .
TABLES: ZMM_GOS_BOASDT                 .
