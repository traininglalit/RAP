CLASS zcl_fill_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fill_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: lt_salesorder_hdr TYPE STANDARD TABLE OF zdb_salesordhdr,
          lt_salesorder_itm TYPE STANDARD TABLE OF zdb_salesorditem.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_time) = cl_abap_context_info=>get_system_time( ).
    DATA(lv_warranty) = lv_date + 90.

    lt_salesorder_hdr = VALUE #( ( salesorder = '1000000000'
                              createdon  = lv_date
                              creationtime = lv_time
                              personname   = 'Lalit'
                              quotationdate = lv_date
                              quotationbiddate = lv_date
                              documentdate = lv_date
                              documentcat = 'C'
                              transactiongrp = '0'
                              salesordtype = 'OR'
                              orderreason = ''
                              warrantydate = lv_warranty
                              netamount = '2000'
                              currency  = 'INR'
                          ) ).

    lt_salesorder_itm = VALUE #( (
                             salesorder = '1000000000'
                             salesitem  = '000010'
                             material   = 'MAT01'
                             batchnumber = 'B201802-US'
                             materialgroup = 'L001'
                             refmaterial = ' '
                             netitemamount = '100'
                             currency = 'INR'
                               )
                               (
                             salesorder = '1000000000'
                             salesitem  = '000020'
                             material   = 'MAT02'
                             batchnumber = 'B201802-US'
                             materialgroup = 'L001'
                             refmaterial = ' '
                             netitemamount = '200'
                             currency = 'INR'
                               )
                               ).

    INSERT zdb_salesordhdr FROM TABLE @lt_salesorder_hdr.
    INSERT zdb_salesorditem FROM TABLE @lt_salesorder_itm.
  ENDMETHOD.

ENDCLASS.
