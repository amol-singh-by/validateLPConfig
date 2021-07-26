%dw 2.0
import * from dw::Runtime
@StreamCapable()

fun getOperationType(parent, child) =
	if (isEmpty(child.'sourcingInformation.sourcingItem.actionCode'))
		if ( parent.documentActionCode != "DELETE" ) "Record"
		else "DeleteRecord"
	else if ( child.'sourcingInformation.sourcingItem.actionCode' != "DELETE" ) "Record"
	else "DeleteRecord"

fun validateDateFormat(str) = try(() -> str as Date) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result + |P1D|
}

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemTypeCode(value, codelistFlag) =
  codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)
    else ''
    else -> try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}


output application/xml deferred = true, skipNullOn = "everywhere"
---
ProcurementPlans: {
	(payload map ((item, index) ->
if ( getOperationType(item,item) == "Record" ) (getOperationType(item,item)): {
		"ProcurementCalendarID": if ( item."sourcingInformation.procurementCalendar" != null ) item."sourcingInformation.procurementCalendar" else "",
		"ProductID": item."sourcingInformation.sourcingItem.itemId" default "",
		"LocationIDSource": if ( item."pickUpLocation.locationId" != null ) item."pickUpLocation.locationId" else "",
		"LocationIDTarget": if ( item."dropOffLocation.locationId" != null ) item."dropOffLocation.locationId" else "",
		"UnitID": codeListItemTypeCode(item."sourcingInformation.sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode", codelistFlag),
		"Type": if ( item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != null ) item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" else "STANDARD",
		"CanBeOrderedFrom": if (item."sourcingInformation.sourcingDetails.effectiveFromDate" != null and item."sourcingInformation.sourcingDetails.effectiveFromDate" != "") (item."sourcingInformation.sourcingDetails.effectiveFromDate" splitBy  /[A-Z]/) else "1970-01-01",
		"CanBeOrderedUpTo": if (!isEmpty(item."sourcingInformation.sourcingDetails.effectiveUpToDate" )) ((validateDateFormat(item."sourcingInformation.sourcingDetails.effectiveUpToDate")) splitBy  /[A-Z]/) else "9999-12-31",
		"InternationalProductNumber": if ( item."sourcingInformation.sourcingItem.additionalTradeItemId.typeCode" == "EAN" and !isEmpty(item."sourcingInformation.sourcingItem.additionalTradeItemId.value") ) item."sourcingInformation.sourcingItem.additionalTradeItemId.value" else null,
		"MinOrderQuantity": if ( !isEmpty(item."sourcingInformation.sourcingDetails.procurementDetails.minimumOrderQuantity.value" ) ) item."sourcingInformation.sourcingDetails.procurementDetails.minimumOrderQuantity.value" else null,
		"MaxOrderQuantity": if ( !isEmpty(item."sourcingInformation.sourcingDetails.procurementDetails.maximumOrderQuantity.value" ) ) item."sourcingInformation.sourcingDetails.procurementDetails.maximumOrderQuantity.value" else null,
		"OrderMultiple": if ( !isEmpty(item."sourcingInformation.sourcingDetails.procurementDetails.incrementalOrderQuantity.value" ) ) item."sourcingInformation.sourcingDetails.procurementDetails.incrementalOrderQuantity.value" else null,
		"StockBuildDays": if (item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" == "STOCKBUILD" and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != null and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != "" and !isEmpty(item."sourcingInformation.sourcingDetails.procurementDetails.stockBuildDays")) item."sourcingInformation.sourcingDetails.procurementDetails.stockBuildDays" 
		else if(item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != "STOCKBUILD" and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != null and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != "") null
		else null,
		"StockBuildEventFrom": if (item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" == "STOCKBUILD" and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != null and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != "" and !isEmpty(item."sourcingInformation.sourcingDetails.procurementDetails.eventFromDate")) item."sourcingInformation.sourcingDetails.procurementDetails.eventFromDate"
		else if(item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != "STOCKBUILD" and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != null and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != "") null
		else null,
		"StockBuildEventUpTo": if (item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" == "STOCKBUILD" and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != null and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != "" and !isEmpty(item."sourcingInformation.sourcingDetails.procurementDetails.eventUpToDate")) item."sourcingInformation.sourcingDetails.procurementDetails.eventUpToDate" 
		else if(item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != "STOCKBUILD" and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != null and item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != "") null
		else null,
		"PurchaseGroupID": if ( !isEmpty(item."sourcingInformation.sourcingDetails.procurementDetails.orderGroup" ) ) item."sourcingInformation.sourcingDetails.procurementDetails.orderGroup" else null,
		"PurchaseSubGroup": if ( !isEmpty(item."sourcingInformation.sourcingDetails.procurementDetails.orderGroupMember" ) ) item."sourcingInformation.sourcingDetails.procurementDetails.orderGroupMember" else null,
		"VendorLeadTimeVariance": if ( !isEmpty(item."sourcingInformation.sourcingDetails.procurementDetails.leadTimeVarianceDays" ) ) item."sourcingInformation.sourcingDetails.procurementDetails.leadTimeVarianceDays" else null,
		"RoundingRuleID": if ( !isEmpty(item."sourcingInformation.sourcingDetails.procurementDetails.roundingRuleId" )) item."sourcingInformation.sourcingDetails.procurementDetails.roundingRuleId" else null,
		}
else if ( getOperationType(item, item) == "DeleteRecord" and (item."sourcingInformation.sourcingItem.itemId" == "DELETE_ALL_PLANS" or item."pickUpLocation.locationId" == "DELETE_ALL_PLANS" or item."dropOffLocation.locationId" == "DELETE_ALL_PLANS") ) "DeleteAllRecords": {
		"ProcurementCalendarID": if ( item."sourcingInformation.procurementCalendar" != null ) item."sourcingInformation.procurementCalendar" else "",
		"ProductID": if (!isEmpty(item."sourcingInformation.sourcingItem.itemId") and item."sourcingInformation.sourcingItem.itemId" != "DELETE_ALL_PLANS") item."sourcingInformation.sourcingItem.itemId" else null,
		"LocationIDSource": if ( !isEmpty(item."pickUpLocation.locationId") and item."pickUpLocation.locationId" != "DELETE_ALL_PLANS" ) item."pickUpLocation.locationId" else null,
		"LocationIDTarget": if ( !isEmpty(item."dropOffLocation.locationId") and item."dropOffLocation.locationId" != "DELETE_ALL_PLANS" ) item."dropOffLocation.locationId" else null,
		"UnitID": codeListItemTypeCode(item."sourcingInformation.sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode", codelistFlag),
		"Type": if ( item."sourcingDetails.procurementDetails.procurementType" != null ) item."sourcingDetails.procurementDetails.procurementType" else "STANDARD",
		"CanBeOrderedFrom": if ( item."sourcingInformation.sourcingDetails.effectiveFromDate" != null and item."sourcingInformation.sourcingDetails.effectiveFromDate" != "") (item."sourcingInformation.sourcingDetails.effectiveFromDate" splitBy  /[A-Z]/) else "1970-01-01",
		"CanBeOrderedUpTo": if ( !isEmpty(item."sourcingInformation.sourcingDetails.effectiveUpToDate" ))  ((validateDateFormat(item."sourcingInformation.sourcingDetails.effectiveUpToDate")) splitBy  /[A-Z]/)  else "9999-12-31"
	}
else if ( getOperationType(item,item) == "DeleteRecord" ) (getOperationType(item,item)) : {
		"ProcurementCalendarID": if ( item."sourcingInformation.procurementCalendar" != null ) item."sourcingInformation.procurementCalendar" else "",
		"ProductID": item."sourcingInformation.sourcingItem.itemId" default "",
		"LocationIDSource": if ( item."pickUpLocation.locationId" != null ) item."pickUpLocation.locationId" else "",
		"LocationIDTarget": if ( item."dropOffLocation.locationId" != null ) item."dropOffLocation.locationId" else "",
		"UnitID": codeListItemTypeCode(item."sourcingInformation.sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode", codelistFlag),
		"Type": if ( item."sourcingDetails.procurementDetails.procurementType" != null ) item."sourcingDetails.procurementDetails.procurementType" else "STANDARD",
		"CanBeOrderedFrom": if ( item."sourcingInformation.sourcingDetails.effectiveFromDate" != null and item."sourcingInformation.sourcingDetails.effectiveFromDate" != "") (item."sourcingInformation.sourcingDetails.effectiveFromDate" splitBy  /[A-Z]/) else "1970-01-01",
		"CanBeOrderedUpTo": if ( !isEmpty(item."sourcingInformation.sourcingDetails.effectiveUpToDate" )) ((validateDateFormat(item."sourcingInformation.sourcingDetails.effectiveUpToDate")) splitBy  /[A-Z]/)  else "9999-12-31"
	} else {
	}
))
}