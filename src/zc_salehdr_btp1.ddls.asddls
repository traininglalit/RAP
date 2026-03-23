@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header Proj CDS View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_SALEHDR_BTP1
  provider contract transactional_query
  as projection on ZR_SALEHDR_BTP1
{
  key Salesorder,
      Createdon,
      Creationtime,
      Personname,
      Quotationdate,
      Quotationbiddate,
      Documentdate,
      Documentcat,
      Transactiongrp,
      Salesordtype,
      Orderreason,
      Warrantydate,
      Netamount,
      Currency,
      Totalamount,
      /* Associations */
      _item : redirected to composition child ZC_SALEITM_BTP1
}
