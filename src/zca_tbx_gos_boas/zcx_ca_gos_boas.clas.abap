class ZCX_CA_GOS_BOAS definition
  public
  inheriting from ZCX_CA_PARAM
  create public .

public section.

  constants:
    begin of ZCX_CA_GOS_BOAS,
      msgid type symsgid value 'ZCA_TOOLBOX',
      msgno type symsgno value '061',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_CA_GOS_BOAS .
  constants:
    begin of INTERFACE_NOT_FOUND,
      msgid type symsgid value 'ZCA_TOOLBOX',
      msgno type symsgno value '062',
      attr1 type scx_attrname value 'MV_MSGV1',
      attr2 type scx_attrname value 'MV_MSGV2',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INTERFACE_NOT_FOUND .
  constants:
    begin of ERROR_CREATING_CONSUMER,
      msgid type symsgid value 'ZCA_TOOLBOX',
      msgno type symsgno value '063',
      attr1 type scx_attrname value 'MV_MSGV1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ERROR_CREATING_CONSUMER .
  constants C_ZCX_CA_GOS_BOAS type SEOCLSNAME value 'ZCX_CA_GOS_BOAS' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MT_RETURN type BAPIRET2_T optional
      !MV_SUBRC type SYST_SUBRC optional
      !MV_MSGTY type SYMSGTY optional
      !MV_MSGV1 type SYMSGV optional
      !MV_MSGV2 type SYMSGV optional
      !MV_MSGV3 type SYMSGV optional
      !MV_MSGV4 type SYMSGV optional
      !MV_SEVERITY type T_SEVERITY optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_CA_GOS_BOAS IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MT_RETURN = MT_RETURN
MV_SUBRC = MV_SUBRC
MV_MSGTY = MV_MSGTY
MV_MSGV1 = MV_MSGV1
MV_MSGV2 = MV_MSGV2
MV_MSGV3 = MV_MSGV3
MV_MSGV4 = MV_MSGV4
MV_SEVERITY = MV_SEVERITY
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_CA_GOS_BOAS .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
