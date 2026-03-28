@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Entity CDS View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZE_SALESORDITEM
  as select from ZI_SALESORDITEM
  association to parent ZR_SALESORDHDR as _header on $projection.Salesorder = _header.Salesorder
{
  key Salesorder,
  key Salesitem,
      Material,
      Batchnumber,
      Materialgroup,
      Refmaterial,
      Netitemamount,
      Currency,
      _header
}
