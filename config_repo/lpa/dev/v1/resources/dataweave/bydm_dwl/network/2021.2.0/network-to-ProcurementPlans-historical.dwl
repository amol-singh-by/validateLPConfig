%dw 2.0
import * from dw::Runtime

fun getOperationType(parent, child) =
	if (isEmpty(child.actionCode))
		if ( parent.documentActionCode != "DELETE" ) "Record"
		else "DeleteRecord"
	else if ( child.actionCode != "DELETE" ) "Record"
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
	(payload[vars.bulkType] map ((item_n, index_n) -> {
		(item_n.sourcingInformation map ((item, index) -> 
	if ( getOperationType(item_n,item) == "Record" ) (getOperationType(item_n,item)) : {
			"ProcurementCalendarID": if ( item.procurementCalendar != null ) item.procurementCalendar else "",
			"ProductID": item.sourcingItem.itemId default "",
			"LocationIDSource": if ( item_n.pickUpLocation.locationId != null ) item_n.pickUpLocation.locationId else "",
			"LocationIDTarget": if ( item_n.dropOffLocation.locationId != null ) item_n.dropOffLocation.locationId else "",
			"UnitID": codeListItemTypeCode(item.sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode, codelistFlag),
			"Type": if ( !isEmpty(item.sourcingDetails.procurementDetails.procurementType) and (item.sourcingDetails.procurementDetails.procurementType == "STANDARD" or item.sourcingDetails.procurementDetails.procurementType ==  "STOCKBUILD") ) item.sourcingDetails.procurementDetails.procurementType else "STANDARD",
			"CanBeOrderedFrom": if ( item.sourcingDetails.effectiveFromDate != null and item.sourcingDetails.effectiveFromDate != "") item.sourcingDetails.effectiveFromDate else "1970-01-01",
			"CanBeOrderedUpTo": if ( !isEmpty(item.sourcingDetails.effectiveUpToDate )) (validateDateFormat(item.sourcingDetails.effectiveUpToDate)) else "9999-12-31",
			"InternationalProductNumber": (item.sourcingItem.additionalTradeItemId filter($.typeCode == "EAN"))[0].value default null,
			"MinOrderQuantity": if ( !isEmpty(item.sourcingDetails.procurementDetails.minimumOrderQuantity.value) ) item.sourcingDetails.procurementDetails.minimumOrderQuantity.value else null,
			"MaxOrderQuantity": if ( !isEmpty(item.sourcingDetails.procurementDetails.maximumOrderQuantity.value) ) item.sourcingDetails.procurementDetails.maximumOrderQuantity.value else null,
			"OrderMultiple": if ( !isEmpty(item.sourcingDetails.procurementDetails.incrementalOrderQuantity.value) ) item.sourcingDetails.procurementDetails.incrementalOrderQuantity.value else null,
			"StockBuildDays": if ( item.sourcingDetails.procurementDetails.procurementType == "STOCKBUILD" and item.sourcingDetails.procurementDetails.procurementType != null and item.sourcingDetails.procurementDetails.procurementType != "" and !isEmpty(item.sourcingDetails.procurementDetails.stockBuildDays ) ) item.sourcingDetails.procurementDetails.stockBuildDays 
			else if ( item.sourcingDetails.procurementDetails.procurementType != "STOCKBUILD" and item.sourcingDetails.procurementDetails.procurementType != null and item.sourcingDetails.procurementDetails.procurementType != "" ) null
			else null,
			"StockBuildEventFrom": if ( item.sourcingDetails.procurementDetails.procurementType == "STOCKBUILD" and item.sourcingDetails.procurementDetails.procurementType != null and item.sourcingDetails.procurementDetails.procurementType != "" and !isEmpty(item.sourcingDetails.procurementDetails.eventFromDate ) ) item.sourcingDetails.procurementDetails.eventFromDate 
			else if ( item.sourcingDetails.procurementDetails.procurementType != "STOCKBUILD" and item.sourcingDetails.procurementDetails.procurementType != null and item.sourcingDetails.procurementDetails.procurementType != "" ) null
			else null,
			"StockBuildEventUpTo": if ( item.sourcingDetails.procurementDetails.procurementType == "STOCKBUILD" and item.sourcingDetails.procurementDetails.procurementType != null and item.sourcingDetails.procurementDetails.procurementType != "" and !isEmpty(item.sourcingDetails.procurementDetails.eventUpToDate ) ) item.sourcingDetails.procurementDetails.eventUpToDate 
			else if ( item.sourcingDetails.procurementDetails.procurementType != "STOCKBUILD" and item.sourcingDetails.procurementDetails.procurementType != null and item.sourcingDetails.procurementDetails.procurementType != "" ) null
			else null,
			"PurchaseGroupID": if ( !isEmpty(item.sourcingDetails.procurementDetails.orderGroup ) ) item.sourcingDetails.procurementDetails.orderGroup else null,
			"PurchaseSubGroup": if ( !isEmpty(item.sourcingDetails.procurementDetails.orderGroupMember ) ) item.sourcingDetails.procurementDetails.orderGroupMember else null,
			"VendorLeadTimeVariance": if ( !isEmpty(item.sourcingDetails.procurementDetails.leadTimeVarianceDays ) ) item.sourcingDetails.procurementDetails.leadTimeVarianceDays else null,
			"RoundingRuleID": if ( !isEmpty(item.sourcingDetails.procurementDetails.roundingRuleId ) ) item.sourcingDetails.procurementDetails.roundingRuleId else null
		}
	else if ( getOperationType(item_n, item) == "DeleteRecord" and (item.sourcingItem.itemId == "DELETE_ALL_PLANS" or item_n.pickUpLocation.locationId == "DELETE_ALL_PLANS" or item_n.dropOffLocation.locationId == "DELETE_ALL_PLANS") ) "DeleteAllRecords": {
			"ProcurementCalendarID": if ( item.procurementCalendar != null and item.procurementCalendar != "" ) item.procurementCalendar else null,
			"ProductID": if (!isEmpty(item.sourcingItem.itemId) and item.sourcingItem.itemId != "DELETE_ALL_PLANS") item.sourcingItem.itemId else null,
			"LocationIDSource": if ( !isEmpty(item_n.pickUpLocation.locationId) and item_n.pickUpLocation.locationId != "DELETE_ALL_PLANS" ) item_n.pickUpLocation.locationId else null,
			"LocationIDTarget": if ( !isEmpty(item_n.dropOffLocation.locationId) and item_n.dropOffLocation.locationId != "DELETE_ALL_PLANS" ) item_n.dropOffLocation.locationId else null,
			"UnitID": codeListItemTypeCode(item.sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode, codelistFlag),
			"Type": if ( !isEmpty(item.sourcingDetails.procurementDetails.procurementType) and (item.sourcingDetails.procurementDetails.procurementType == "STANDARD" or item.sourcingDetails.procurementDetails.procurementType ==  "STOCKBUILD") ) item.sourcingDetails.procurementDetails.procurementType else "STANDARD",
			"CanBeOrderedFrom": if ( item.sourcingDetails.effectiveFromDate != null and item.sourcingDetails.effectiveFromDate != "") item.sourcingDetails.effectiveFromDate else "1970-01-01",
			"CanBeOrderedUpTo": if ( !isEmpty(item.sourcingDetails.effectiveUpToDate ))  (validateDateFormat(item.sourcingDetails.effectiveUpToDate)) else "9999-12-31",
		} 
	else if ( getOperationType(item_n,item) == "DeleteRecord" ) (getOperationType(item_n,item)) : {
			"ProcurementCalendarID": if ( item.procurementCalendar != null ) item.procurementCalendar else "",
			"ProductID": item.sourcingItem.itemId default "",
			"LocationIDSource": if ( item_n.pickUpLocation.locationId != null ) item_n.pickUpLocation.locationId else "",
			"LocationIDTarget": if ( item_n.dropOffLocation.locationId != null ) item_n.dropOffLocation.locationId else "",
			"UnitID": codeListItemTypeCode(item.sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode, codelistFlag),
			"Type": if ( !isEmpty(item.sourcingDetails.procurementDetails.procurementType) and (item.sourcingDetails.procurementDetails.procurementType == "STANDARD" or item.sourcingDetails.procurementDetails.procurementType ==  "STOCKBUILD") ) item.sourcingDetails.procurementDetails.procurementType else "STANDARD",
			"CanBeOrderedFrom": if ( item.sourcingDetails.effectiveFromDate != null and item.sourcingDetails.effectiveFromDate != "") item.sourcingDetails.effectiveFromDate else "1970-01-01",
			"CanBeOrderedUpTo": if ( !isEmpty(item.sourcingDetails.effectiveUpToDate ))  (validateDateFormat(item.sourcingDetails.effectiveUpToDate)) else "9999-12-31",
		} else {
		}
	))
	}
))
}