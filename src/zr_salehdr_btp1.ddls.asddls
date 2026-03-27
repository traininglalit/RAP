@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header Root CDS View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_SALEHDR_BTP1
  as select from ZI_SALEHDR_BTP1
  composition[0..*] of ZE_SALEITM_BTP1 as _item
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
      _item
} 
//where Personname = $session.user
