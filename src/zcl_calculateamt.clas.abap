CLASS zcl_calculateamt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_calculateamt IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_salesheader TYPE STANDARD TABLE OF zc_salesordhdr.
    lt_salesheader = CORRESPONDING #( it_original_data ).
    LOOP AT lt_salesheader ASSIGNING FIELD-SYMBOL(<fs_salesheader>).
      <fs_salesheader>-calculateAmt = <fs_salesheader>-Netamount + ( <fs_salesheader>-Netamount  *  '0.1' ).
    ENDLOOP.
    ct_calculated_data = CORRESPONDING #( lt_salesheader ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.

ENDCLASS.
