%dw 2.0
import * from dw::Runtime

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

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

fun getOperationType(parent) =
  if (parent.documentActionCode != "DELETE")
    "Record"
  else
    "DeleteRecord"

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemLocationTypeCode(value, codelistFlag) =
  codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupOptional(vars.codeMap.ItemLocationTypeCode, "ItemLocationTypeCode", value default "")
    else ''
    else -> try(() -> jda::CodeMap::keyLookupOptional(vars.codeMap.ItemLocationTypeCode, "ItemLocationTypeCode", value default "")) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
Assignments: {
	((payload[vars.bulkType] filter (() -> (($.includesAvailability default 'false') ~= 'true'))) map (item, index) -> {
		(item.availability map (avail,index) ->
	        if (getOperationType(item) == "Record") "DeleteRecord": {
			"ProductID": if ( item.itemLocationId.item.primaryId != null ) item.itemLocationId.item.primaryId else "",
			"LocationID": if ( item.itemLocationId.location.primaryId != null ) item.itemLocationId.location.primaryId else "",
			"Type": codeListItemLocationTypeCode(avail."type", codelistFlag),
			"ActiveFrom": if (!isEmpty(avail.effectiveFromDate)) avail.effectiveFromDate else defaultFromDate,
			"ActiveUpTo": if (!isEmpty(avail.effectiveUpToDate)) validateDate(avail.effectiveUpToDate) else "9999-12-31"
		} else {})
	})
}
