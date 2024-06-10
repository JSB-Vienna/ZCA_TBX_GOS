"! <p class="shorttext synchronized" lang="en">CA-TBX: GOS: Popup to select attachments</p>
INTERFACE zif_ca_gos_boas_popup PUBLIC.
* i n s t a n c e   a t t r i b u t e s
  DATA:
*   o b j e c t   r e f e r e n c e s
    "! <p class="shorttext synchronized" lang="en">GOS: Consumer implementation for BO attachment selection</p>
    mo_gos_cons    TYPE REF TO zif_ca_gos_boas,
    "! <p class="shorttext synchronized" lang="en">Splitter container</p>
    mo_splt        TYPE REF TO cl_gui_splitter_container,
    "! <p class="shorttext synchronized" lang="en">Parent container for ALV</p>
    mo_cnt_sellist TYPE REF TO cl_gui_container,
    "! <p class="shorttext synchronized" lang="en">GOS: ALV selection list with attachments</p>
    mo_alv_sl      TYPE REF TO zif_ca_gos_boas_sellist.

* i n s t a n c e   m e t h o d s
  METHODS:
    "! <p class="shorttext synchronized" lang="en">Returns result to main GOS class</p>
    "!
    "! @parameter rt_gos_bomd | <p class="shorttext synchronized" lang="en">GOS: As attachment marked documents</p>
    get_result DEFAULT FAIL
      RETURNING
        VALUE(rt_gos_bomd) TYPE zca_tt_gos_bomd.
ENDINTERFACE.
