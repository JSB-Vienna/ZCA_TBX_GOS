"! <p class="shorttext synchronized" lang="en">CA-TBX: GOS: Consumer implement. for BO attachm. selection</p>
INTERFACE zif_ca_gos_boas PUBLIC.
* i n s t a n c e   a t t r i b u t e s
  DATA:
*   o b j e c t   r e f e r e n c e s
    "! <p class="shorttext synchronized" lang="en">GOS: BO Attachment selection for mails (service)</p>
    mo_gos_svc   TYPE REF TO zcl_ca_gos_boas_svc READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">GOS: Enhanced BO content handler</p>
    mo_arch_cont TYPE REF TO zcl_ca_gos_boas_arch_cont READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">GOS: Popup to select attachments</p>
    mo_popup     TYPE REF TO zif_ca_gos_boas_popup READ-ONLY.

* s t a t i c   m e t h o d s
  CLASS-METHODS:
    "! <p class="shorttext synchronized" lang="en">Factory to create consumer instance</p>
    "!
    "! @parameter io_gos_svc | <p class="shorttext synchronized" lang="en">GOS: BO Attachment selection for mails (service)</p>
    "! @parameter result     | <p class="shorttext synchronized" lang="en">GOS: Consumer implementation for BO attachment selection</p>
    "! @raising   zcx_ca_gos_boas | <p class="shorttext synchronized" lang="en">GOS: Errors while selecting attachments to BO</p>
    factory DEFAULT FAIL
      IMPORTING
        io_gos_svc    TYPE REF TO zcl_ca_gos_boas_svc
      RETURNING
        VALUE(result) TYPE REF TO zif_ca_gos_boas
      RAISING
        zcx_ca_gos_boas.

* i n s t a n c e   e v e n t s
  EVENTS:
    "! <p class="shorttext synchronized" lang="en">Data saved and service closed</p>
    "!
    "! @parameter it_gos_bomd | <p class="shorttext synchronized" lang="en">GOS: As attachment marked documents</p>
    svc_saved
      EXPORTING
        VALUE(it_gos_bomd) TYPE zca_tt_gos_bomd,

    "! <p class="shorttext synchronized" lang="en">Service closed without saving</p>
    svc_closed.

* i n s t a n c e   m e t h o d s
  METHODS:
    "! <p class="shorttext synchronized" lang="en">Check service activation in customizing</p>
    "!
    "! @parameter result | <p class="shorttext synchronized" lang="en">X = Activate service</p>
    "! @raising   zcx_ca_gos_boas | <p class="shorttext synchronized" lang="en">GOS: Errors while selecting attachments to BO</p>
    activate_service DEFAULT FAIL
      RETURNING
        VALUE(result) TYPE abap_bool
      RAISING
        zcx_ca_gos_boas,

    "! <p class="shorttext synchronized" lang="en">Determine if any content exist to BO</p>
    "!
    "! @parameter iv_raise_excp | <p class="shorttext synchronized" lang="en">X = Raise exception if no content found</p>
    "! @parameter result        | <p class="shorttext synchronized" lang="en">X = Content found to BO</p>
    "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling Archive content</p>
    has_content DEFAULT FAIL
      IMPORTING
        iv_raise_excp TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE abap_bool
      RAISING
        zcx_ca_archive_content,

    "! <p class="shorttext synchronized" lang="en">Executes main function of GOS</p>
    "!
    "! @parameter io_container | <p class="shorttext synchronized" lang="en">By GOS environment provided GUI container</p>
    "! @raising   zcx_ca_param | <p class="shorttext synchronized" lang="en">Common exception: Parameter error (INHERIT from this excep!)</p>
    execute_consumer DEFAULT FAIL
      IMPORTING
        io_container TYPE REF TO cl_gui_container
      RAISING
        zcx_ca_param,

    "! <p class="shorttext synchronized" lang="en">Receiving last action forwarding to GOS service</p>
    "!
    "! @parameter iv_fcode | <p class="shorttext synchronized" lang="en">Function code</p>
    on_fcode_triggered DEFAULT FAIL
      FOR EVENT fcode_triggered OF zcl_ca_reusable_popup_cust_cnt
      IMPORTING
        iv_fcode.
ENDINTERFACE.
