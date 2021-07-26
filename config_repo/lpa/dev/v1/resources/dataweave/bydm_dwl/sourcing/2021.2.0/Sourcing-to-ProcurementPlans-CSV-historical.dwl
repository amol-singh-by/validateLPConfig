%dw 2.0
import * from dw::Runtime
@StreamCapable()

fun getOperationType(documentActionCode) =
	if(documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH") "Record"
	else if(documentActionCode == "DELETE") "DeleteRecord"
	else "Record"

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
if ( getOperationType(item.documentActionCode) == "Record" ) (getOperationType(item.documentActionCode)): {
		"ProcurementCalendarID": if ( item."procurementCalendar" != null ) item."procurementCalendar" else "",
		"ProductID": item."sourcingId.item.itemId" default "",
		"LocationIDSource": if ( item."sourcingId.pickUpLocation.locationId" != null ) item."sourcingId.pickUpLocation.locationId" else "",
		"LocationIDTarget": if ( item."sourcingId.dropOffLocation.locationId" != null ) item."sourcingId.dropOffLocation.locationId" else "",
		"UnitID": codeListItemTypeCode(item."sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode", codelistFlag),
		"Type": if ( item."sourcingDetails.procurementDetails.procurementType" != null ) item."sourcingDetails.procurementDetails.procurementType" else "STANDARD",
		"CanBeOrderedFrom": if ( item."sourcingDetails.effectiveFromDate" != null and item."sourcingDetails.effectiveFromDate" != "") (item."sourcingDetails.effectiveFromDate" splitBy  /[A-Z]/) [0] else "1970-01-01",
		"CanBeOrderedUpTo": if ( !isEmpty(item."sourcingDetails.effectiveUpToDate" )) (validateDateFormat(((item."sourcingDetails.effectiveUpToDate") splitBy  /[A-Z]/)[0])) else "9999-12-31",
		"InternationalProductNumber": if ( item."sourcingId.item.additionalTradeItemId.typeCode" == "EAN" and !isEmpty(item."sourcingId.item.additionalTradeItemId.value") ) item."sourcingId.item.additionalTradeItemId.value" else null,
		"MinOrderQuantity": if ( !isEmpty(item."sourcingDetails.procurementDetails.minimumOrderQuantity.value" ) ) item."sourcingDetails.procurementDetails.minimumOrderQuantity.value" else null,
		"MaxOrderQuantity": if ( !isEmpty(item."sourcingDetails.procurementDetails.maximumOrderQuantity.value" ) ) item."sourcingDetails.procurementDetails.maximumOrderQuantity.value" else null,
		"OrderMultiple": if ( !isEmpty(item."sourcingDetails.procurementDetails.incrementalOrderQuantity.value" ) ) item."sourcingDetails.procurementDetails.incrementalOrderQuantity.value" else null,
		"PurchaseGroupID": if ( !isEmpty(item."sourcingDetails.procurementDetails.orderGroup" ) ) item."sourcingDetails.procurementDetails.orderGroup" else null,
		"PurchaseSubGroup": if ( !isEmpty(item."sourcingDetails.procurementDetails.orderGroupMember" ) ) item."sourcingDetails.procurementDetails.orderGroupMember" else null,
		"VendorLeadTimeVariance": if ( !isEmpty(item."sourcingDetails.procurementDetails.leadTimeVarianceDays" ) ) item."sourcingDetails.procurementDetails.leadTimeVarianceDays" else null,
		"RoundingRuleID": if ( !isEmpty(item."sourcingDetails.procurementDetails.roundingRuleId" ) ) item."sourcingDetails.procurementDetails.roundingRuleId" else null,
	}
else if ( getOperationType(item.documentActionCode) == "DeleteRecord" and (item."sourcingId.item.itemId" == "DELETE_ALL_PLANS" or item."sourcingId.pickUpLocation.locationId" == "DELETE_ALL_PLANS" or item."sourcingId.dropOffLocation.locationId" == "DELETE_ALL_PLANS") ) "DeleteAllRecords": {
		"ProcurementCalendarID": if ( item."procurementCalendar" != null ) item."procurementCalendar" else "",
		"ProductID": if (!isEmpty(item."sourcingId.item.itemId") and item."sourcingId.item.itemId" != "DELETE_ALL_PLANS") item."sourcingId.item.itemId" else "",
		"LocationIDSource": if ( !isEmpty(item."sourcingId.pickUpLocation.locationId") and item."sourcingId.pickUpLocation.locationId" != "DELETE_ALL_PLANS" ) item."sourcingId.pickUpLocation.locationId" else null,
		"LocationIDTarget": if ( !isEmpty(item."sourcingId.dropOffLocation.locationId") and item."sourcingId.dropOffLocation.locationId" != "DELETE_ALL_PLANS" ) item."sourcingId.dropOffLocation.locationId" else null,
		"UnitID": codeListItemTypeCode(item."sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode", codelistFlag),
		"Type": if ( item."sourcingDetails.procurementDetails.procurementType" != null ) item."sourcingDetails.procurementDetails.procurementType" else "STANDARD",
		"CanBeOrderedFrom": if ( item."sourcingDetails.effectiveFromDate" != null and item."sourcingDetails.effectiveFromDate" != "") (item."sourcingDetails.effectiveFromDate" splitBy  /[A-Z]/) [0] else "1970-01-01",
		"CanBeOrderedUpTo": if ( !isEmpty(item."sourcingDetails.effectiveUpToDate" )) (validateDateFormat(((item."sourcingDetails.effectiveUpToDate") splitBy  /[A-Z]/)[0])) else "9999-12-31"
		}
else if ( getOperationType(item.documentActionCode) == "DeleteRecord" ) (getOperationType(item.documentActionCode)) : {
		"ProcurementCalendarID": if ( item."procurementCalendar" != null ) item."procurementCalendar" else "",
		"ProductID": item."sourcingId.item.itemId" default "",
		"LocationIDSource": if ( item."sourcingId.pickUpLocation.locationId" != null ) item."sourcingId.pickUpLocation.locationId" else "",
		"LocationIDTarget": if ( item."sourcingId.dropOffLocation.locationId" != null ) item."sourcingId.dropOffLocation.locationId" else "",
		"UnitID": codeListItemTypeCode(item."sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode", codelistFlag),
		"Type": if ( item."sourcingDetails.procurementDetails.procurementType" != null ) item."sourcingDetails.procurementDetails.procurementType" else "STANDARD",
		"CanBeOrderedFrom": if ( item."sourcingDetails.effectiveFromDate" != null and item."sourcingDetails.effectiveFromDate" != "") (item."sourcingDetails.effectiveFromDate" splitBy  /[A-Z]/) [0] else "1970-01-01",
		"CanBeOrderedUpTo": if ( !isEmpty(item."sourcingDetails.effectiveUpToDate" )) (validateDateFormat(((item."sourcingDetails.effectiveUpToDate") splitBy  /[A-Z]/)[0])) else "9999-12-31"
		} else {
	}
))
}