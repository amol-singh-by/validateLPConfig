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
	
var documentActionCode = "DELETE"

fun getOperationType() = documentActionCode 
	 match {
	 	case documentActionCode: "DELETE" -> "DeleteRecord"
		case documentActionCode: "ADD" -> "Record"
		case documentActionCode: "CHANGE_BY_REFRESH" -> "Record" 	
	}

var codelistFlag = Mule::p('bydm.canmodel.codeList')


fun codeListItemTypeCode(value) = codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value) 
						  else ''
    else ->  try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
StockParameters: {((payload[vars.bulkType] filter (() -> $."documentActionCode" != "DELETE" and (($.includesStockParameters default 'false') ~= 'true'))) map () -> 
        (getOperationType()): {
		"ProductID": if ($.itemLocationId.item.primaryId != null) $.itemLocationId.item.primaryId
            else "",
		"LocationID": if ($.itemLocationId.location.primaryId != null) $.itemLocationId.location.primaryId
            else "",
		"UnitID": codeListItemTypeCode($.effectiveInventoryParameters[0].minimumSafetyStockQuantity.measurementUnitCode),
		"ActiveFrom": if ($.effectiveFromDate != null and $.effectiveFromDate != "") $.effectiveFromDate 
            else defaultFromDate,
		"ActiveUpTo": if ($.effectiveUpToDate != null and $.effectiveUpToDate != "") validateDate($.effectiveUpToDate)
            else "9999-12-31"
	})}