CLASS lhc_ZR_SALEHDR_BTP1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_salehdr_btp1 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zr_salehdr_btp1 RESULT result.

    METHODS excelUpload FOR MODIFY
      IMPORTING keys FOR ACTION zr_salehdr_btp1~excelUpload.

ENDCLASS.

CLASS lhc_ZR_SALEHDR_BTP1 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD excelUpload.
    TYPES: BEGIN OF lty_excel,
             salesorder   TYPE zr_salehdr_btp1-Salesorder,
             salesordtype TYPE zr_salehdr_btp1-Salesordtype,
*             personname   TYPE zr_salehdr_btp1
*             createdon    TYPE zr_salehdr_btp1-Createdon,
*             creationtime TYPE
*             quotationdate
*             quotationbiddate
*             documentdate
*             documentcat
*             transactiongrp
*             salesordtype
*             orderreason
*             warrantydate
*             netamount
*             currency
*             totalamount
           END OF lty_excel.
  ENDMETHOD.

ENDCLASS.
