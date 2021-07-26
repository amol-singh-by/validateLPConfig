%dw 2.0
@StreamCapable()
import * from dw::Runtime
output application/xml  deferred = true, skipNullOn = "everywhere"
---
"PurchaseGroups": {
	"Record" : payload filter($.documentActionCode != "DELETE") map ((og , index) -> {
		"PurchaseGroupID" : if (!isEmpty(og."orderGroupId")) (og."orderGroupId") else '',
		("Description" : og."description.value") if (!isEmpty(og."description.value")),
		"ProcurementCalendarID" : if (!isEmpty(og."orderGroupParameters.procurementCalendar")) (og."orderGroupParameters.procurementCalendar") else '',
		"TransportEquipmentID" : if (!isEmpty(og."transportEquipmentTypeCode.value")) (og."transportEquipmentTypeCode.value") else '',
		("ProjectedOrderDuration" : og."projectedOrderDurationInDays") if (!isEmpty(og."projectedOrderDurationInDays")),
		("AutoApprovalRuleID" : og."orderGroupParameters.autoApprovalRuleId") if (!isEmpty(og."orderGroupParameters.autoApprovalRuleId")),
		("CoverageDurationTolerance" : og."orderGroupParameters.coverageDurationToleranceDays") if (!isEmpty(og."orderGroupParameters.coverageDurationToleranceDays")),
		("LoadBuildDownTolerance" : og."orderGroupParameters.loadDecrementTolerancePercentage") if (!isEmpty(og."orderGroupParameters.loadDecrementTolerancePercentage")),
		("LoadBuildUpTolerance" : og."orderGroupParameters.loadIncrementTolerancePercentage") if (!isEmpty(og."orderGroupParameters.loadIncrementTolerancePercentage")),
		("LoadBuildRule" : og."orderGroupParameters.loadBuildRuleType") if (!isEmpty(og."orderGroupParameters.loadBuildRuleType")),
		("LoadMinRule" : og."orderGroupParameters.loadMinimumRuleType") if (!isEmpty(og."orderGroupParameters.loadMinimumRuleType")),
		("LoadTolerance" : og."orderGroupParameters.loadTolerancePercentage") if (!isEmpty(og."orderGroupParameters.loadTolerancePercentage")),
		("UniqueProductPerPallet" : lower(og."orderGroupParameters.isSingleItemPallet")) if (!isEmpty(og."orderGroupParameters.isSingleItemPallet")),
		"TransportationMinRule" : if (!isEmpty(og."orderGroupParameters.areAllTransportationMinimumRulesRequired") and lower(og."orderGroupParameters.areAllTransportationMinimumRulesRequired")) "ALL" else "ANY",
		"VendorMinRule" : if (!isEmpty(og."orderGroupParameters.areAllSupplierMinimumRulesRequired") and lower(og."orderGroupParameters.areAllSupplierMinimumRulesRequired")) "ALL" else "ANY"
	})
}