"! <p class="shorttext synchronized" lang="en">GOS: Search help exit: get classes implementing a certain interface</p>
"!
"! @parameter shlp        | <p class="shorttext synchronized" lang="en">Technical description of search help</p>
"! @parameter callcontrol | <p class="shorttext synchronized" lang="en">Control Structure for F4 Process with Search Help Exit</p>
"! @parameter shlp_tab    | <p class="shorttext synchronized" lang="en">Table of elementary search helps</p>
"! @parameter record_tab  | <p class="shorttext synchronized" lang="en">Search help result records / entries</p>
FUNCTION z_ca_gos_boas_f4if_class.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------
  "Local data definitions
  DATA:
    lt_classes           TYPE STANDARD TABLE OF sic_s_class_descr.

  IF callcontrol-step NE 'SELECT' ##no_text.
    RETURN.
  ENDIF.

  TRY.
      lt_classes =
            cl_sic_configuration=>get_classes_for_interface(
                                          iv_interface = 'ZIF_CA_GOS_BOAS' ) ##no_text.

    CATCH cx_class_not_existent INTO DATA(lx_error).
      MESSAGE lx_error TYPE 'E'.
  ENDTRY.

* Put the result in the list
  IF lt_classes IS INITIAL.
    RETURN.
  ENDIF.

* Put the class name
  CALL FUNCTION 'F4UT_PARAMETER_RESULTS_PUT'
    EXPORTING
      parameter   = 'EV_CLASS'
      fieldname   = 'CLSNAME'
    TABLES
      shlp_tab    = shlp_tab[]
      record_tab  = record_tab[]
      source_tab  = lt_classes[]
    CHANGING
      shlp        = shlp
      callcontrol = callcontrol
    EXCEPTIONS
      OTHERS      = 1 ##no_text.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Put the description
  CALL FUNCTION 'F4UT_PARAMETER_RESULTS_PUT'
    EXPORTING
      parameter   = 'EV_DESCR'
      fieldname   = 'DESCRIPTION'
    TABLES
      shlp_tab    = shlp_tab[]
      record_tab  = record_tab[]
      source_tab  = lt_classes[]
    CHANGING
      shlp        = shlp
      callcontrol = callcontrol
    EXCEPTIONS
      OTHERS      = 1 ##no_text.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  callcontrol-step = 'DISP' ##no_text.

ENDFUNCTION.                                             "#EC CI_VALPAR
