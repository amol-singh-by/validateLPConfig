%dw 2.0
@StreamCapable()
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

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemTypeCode(value, codelistFlag) = codelistFlag match {
    case str: "ERROR" -> if((value) != null) 
							jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value) 
						  else ''
    else ->   try(() ->  jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

output application/xml deferred = true, skipNullOn="everywhere"
---
StockParameters: {
	((payload filter(()-> $."documentActionCode" != "DELETE" and ($.includesStockParameters default false))) map((stockP,stockPIndex) ->
		DeleteRecord: {
		ProductID: if (stockP."itemLocationId.item.primaryId" != null) stockP."itemLocationId.item.primaryId" else "",
		LocationID: if (stockP."itemLocationId.location.primaryId" != null) stockP."itemLocationId.location.primaryId" else "",
		UnitID: codeListItemTypeCode(stockP."effectiveInventoryParameters.minimumSafetyStockQuantity.measurementUnitCode", codelistFlag),
		ActiveFrom: if (!isEmpty(stockP.effectiveFromDate)) stockP.effectiveFromDate else defaultFromDate,
		ActiveUpTo: if (!isEmpty(stockP.effectiveUpToDate)) validateDate(stockP.effectiveUpToDate) else "9999-12-31"
	}
	))
}