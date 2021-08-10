%dw 2.0
import * from dw::Runtime

fun validateDateFormat(str) = try(() -> str as Date) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result + |P1D|
}

fun getOperationType(parent, child) =
	if (isEmpty(child.actionCode))
		if ( parent.documentActionCode != "DELETE" ) "Record"
		else "DeleteRecord"
	else if ( child.actionCode != "DELETE" ) "Record"
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

output application/xml deferred = true, skipNullOn = "everywhere"
---
ProcurementPlans: {
	(payload[vars.bulkType] map ((item_n, index_n) -> {
		(item_n.sourcingInformation map ((item, index) -> if ( getOperationType(item_n,item) == "Record" ) "DeleteRecord": {
			"ProcurementCalendarID": if ( item.procurementCalendar != null ) item.procurementCalendar
                  else "",
			"ProductID": if ( item.sourcingItem.itemId != null ) item.sourcingItem.itemId
                  else "",
			"LocationIDSource": if ( item_n.pickUpLocation.locationId != null ) item_n.pickUpLocation.locationId
                  else "",
			"LocationIDTarget": if ( item_n.dropOffLocation.locationId != null ) item_n.dropOffLocation.locationId
                  else "",
			"UnitID": codeListItemTypeCode(item.sourcingDetails.procurementDetails.maximumOrderQuantity.measurementUnitCode, codelistFlag),
			"Type": if ( !isEmpty(item.sourcingDetails.procurementDetails.procurementType) and (item.sourcingDetails.procurementDetails.procurementType == "STANDARD" or item.sourcingDetails.procurementDetails.procurementType ==  "STOCKBUILD") ) item.sourcingDetails.procurementDetails.procurementType else "STANDARD",
			"CanBeOrderedFrom": if ( item.sourcingDetails.effectiveFromDate != null and item.sourcingDetails.effectiveFromDate != "") item.sourcingDetails.effectiveFromDate
                  else defaultFromDate,
			"CanBeOrderedUpTo": if ( !isEmpty(item.sourcingDetails.effectiveUpToDate)) validateDateFormat(item.sourcingDetails.effectiveUpToDate)
                  else "9999-12-31"
		}
          else {
		}))
	}))
}