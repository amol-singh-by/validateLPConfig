%dw 2.0
import * from dw::Runtime
@StreamCapable()

fun validateDateFormat(str) = try(() -> str as Date) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result + |P1D|
}

fun getOperationType(parent, child) =
	if (isEmpty(child.'sourcingInformation.sourcingItem.actionCode'))
		if ( parent.documentActionCode != "DELETE" ) "Record"
		else "DeleteRecord"
	else if ( child.'sourcingInformation.sourcingItem.actionCode' != "DELETE" ) "Record"
	else "DeleteRecord"

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

var entityDatePolicy = (vars.entityConfig.targetEntities filter $.name == vars.fullLPEntityName)[0].datePolicy
var entityIncrementalDate = (vars.entityConfig.targetEntities filter $.name == vars.fullLPEntityName)[0].incrementalDate

var defaultFromDate =  if (p("useGlobalDatePolicy.value")) 
	(if (p("useGlobalDatePolicy.datePolicy") == "NEXT_DAY") 
								(now() as Date) + ("P" ++ (p("useGlobalDatePolicy.incrementalDate") default 0) as String ++ "D") as Period
					  		else (now() as Date))

else if (!p("useGlobalDatePolicy.value")) 
	(if (entityDatePolicy == "NEXT_DAY") 
								(now() as Date) + ("P" ++ (entityIncrementalDate default 0) as String ++ "D") as Period
					  		else (now() as Date))

else ""

output application/xml  deferred = true, skipNullOn = "everywhere"
---
ProcurementPlans: {
	(payload map ((item, index) -> 
        if ( getOperationType(item,item) == "Record" ) "DeleteRecord": {
		"ProcurementCalendarID": if ( item."sourcingInformation.procurementCalendar" != null ) item."sourcingInformation.procurementCalendar" else "",
		"ProductID": item."sourcingInformation.sourcingItem.itemId" default "",
		"LocationIDSource": if ( item."pickUpLocation.locationId" != null ) item."pickUpLocation.locationId" else "",
		"LocationIDTarget": if ( item."dropOffLocation.locationId" != null ) item."dropOffLocation.locationId" else"",
		"UnitID": codeListItemTypeCode(item."sourcingInformation.sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode", codelistFlag),
		"Type": if ( item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" != null ) item."sourcingInformation.sourcingDetails.procurementDetails.procurementType" else "STANDARD",
		"CanBeOrderedFrom": if ( item."sourcingInformation.sourcingDetails.effectiveFromDate" != null and item."sourcingInformation.sourcingDetails.effectiveFromDate" != "") (item."sourcingInformation.sourcingDetails.effectiveFromDate" splitBy  /[A-Z]/) else defaultFromDate,
		"CanBeOrderedUpTo": if ( !isEmpty(item."sourcingInformation.sourcingDetails.effectiveUpToDate" )) (validateDateFormat(item."sourcingInformation.sourcingDetails.effectiveUpToDate")) splitBy  /[A-Z]/ else "9999-12-31",
	} else {
	}))
}