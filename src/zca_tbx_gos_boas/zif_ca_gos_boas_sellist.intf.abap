"! <p class="shorttext synchronized" lang="en">CA-TBX: GOS: ALV selection list with attachments</p>
INTERFACE zif_ca_gos_boas_sellist PUBLIC.
* s t a t i c   a t t r i b u t e s
  CLASS-DATA:
    "! <p class="shorttext synchronized" lang="en">Reference of used ALV selection table</p>
    mr_sel_list     TYPE REF TO data.

* i n s t a n c e   a t t r i b u t e s
  DATA:
*   o b j e c t   r e f e r e n c e s
    "! <p class="shorttext synchronized" lang="en">GOS: Consumer implementation for BO attachment selection</p>
    mo_gos_cons    TYPE REF TO zif_ca_gos_boas,
    "! <p class="shorttext synchronized" lang="en">Popup controller</p>
    mo_popup_ctlr  TYPE REF TO zcl_ca_scr_fw_window_ctlr,
    "! <p class="shorttext synchronized" lang="en">Container right pane for document viewing</p>
    mo_cnt_docview TYPE REF TO cl_gui_container.

* i n s t a n c e   m e t h o d s
  METHODS:
    "! <p class="shorttext synchronized" lang="en">Determine marked documents and save into DB</p>
    "!
    "! @parameter result | <p class="shorttext synchronized" lang="en">GOS: As attachment marked documents</p>
    get_marked_docs DEFAULT FAIL
      RETURNING
        VALUE(result) TYPE zca_tt_gos_bomd,

    "! <p class="shorttext synchronized" lang="en">Get selected line</p>
    "!
    "! @parameter iv_row     | <p class="shorttext synchronized" lang="en">Index of selected line</p>
    "! @parameter result | <p class="shorttext synchronized" lang="en">Data reference of selected line</p>
    "! @raising   zcx_ca_ui  | <p class="shorttext synchronized" lang="en">Common exception: UI interaction messages</p>
    get_selected_entry DEFAULT FAIL
      IMPORTING
        iv_row        TYPE salv_de_row
      RETURNING
        VALUE(result) TYPE REF TO data
      RAISING
        zcx_ca_ui.
ENDINTERFACE.
