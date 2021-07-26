%dw 2.0
import * from dw::Runtime
@StreamCapable()

var documentActionCode = "DELETE"

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
	(payload filter (getOperationType($.documentActionCode) == "Record") map ((item, index) -> {
		DeleteRecord: {
			"ProcurementCalendarID": if ( item.procurementCalendar != null ) item.procurementCalendar
                else "",
			"ProductID": item."sourcingId.item.itemId" default "",
			"LocationIDSource": if ( item."sourcingId.pickUpLocation.locationId" != null ) item."sourcingId.pickUpLocation.locationId"
                else "",
			"LocationIDTarget": if ( item."sourcingId.dropOffLocation.locationId" != null ) item."sourcingId.dropOffLocation.locationId"
                else "",
			"UnitID": codeListItemTypeCode(item."sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode", codelistFlag),
			"Type": if ( item."sourcingDetails.procurementDetails.procurementType" != null ) item."sourcingDetails.procurementDetails.procurementType"
                else "STANDARD",
			"CanBeOrderedFrom": if ( item."sourcingDetails.effectiveFromDate" != null and item."sourcingDetails.effectiveFromDate" != "") (item."sourcingDetails.effectiveFromDate" splitBy  /[A-Z]/)[0] else defaultFromDate,
			"CanBeOrderedUpTo": if ( !isEmpty(item."sourcingDetails.effectiveUpToDate" )) validateDateFormat(((item."sourcingDetails.effectiveUpToDate") splitBy  /[A-Z]/)[0]) else "9999-12-31"
		}
	}
))
}
