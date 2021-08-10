%dw 2.0
import * from dw::Runtime

fun validateDate(date) = try(() -> date as DateTime) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

var entityDatePolicy = (vars.entityConfig.targetEntities filter $.name == vars.fullLPEntityName)[0].datePolicy
var entityIncrementalDate = (vars.entityConfig.targetEntities filter $.name == vars.fullLPEntityName)[0].incrementalDate

var defaultFromDateTime =  if (p("useGlobalDatePolicy.value")) 
	(if (p("useGlobalDatePolicy.datePolicy") == "NEXT_DAY") 
								(now() as DateTime) + ("P" ++ (p("useGlobalDatePolicy.incrementalDate") default 0) as String ++ "D") as Period
					  		else (now() as DateTime))

else if (!p("useGlobalDatePolicy.value")) 
	(if (entityDatePolicy == "NEXT_DAY") 
								(now() as DateTime) + ("P" ++ (entityIncrementalDate default 0) as String ++ "D") as Period
					  		else (now() as DateTime))

else ""

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListPricingActivityTypeCode(value, codelistFlag) =
  codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.PricingActivityTypeCode, "PricingActivityTypeCode", value, value)
    	else ''
    else -> try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.PricingActivityTypeCode, "PricingActivityTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
			else -> $.result
	}
	
}

fun getOperationType(documentActionCode) =
	if(documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH") "Record"
	else if(documentActionCode == "DELETE") "DeleteRecord"
	else "Record"
	
output application/xml deferred = true, skipNullOn = "everywhere"
--- 
"PricingActivities": {(
    (payload[vars.bulkType] map(pa,index) -> {
            (if ( getOperationType(pa.documentActionCode) == "Record" ) "Record":{
                "LocationID" : if(pa.pricingActivityId.locationId != null and pa.pricingActivityId.locationId != "*UNKNOWN") pa.pricingActivityId.locationId else "",
				"ProductID" : if(pa.pricingActivityId.itemId != null and pa.pricingActivityId.itemId != "*UNKNOWN") pa.pricingActivityId.itemId else "",
				"DeliverPrices" : if(pa.deliverPrices != null) pa.deliverPrices else "",
				"PricingStrategy" : if(pa.pricingActivityId.pricingStrategyTypeCode != null and pa.pricingActivityId.pricingStrategyTypeCode != "*UNKNOWN") 
                					codeListPricingActivityTypeCode(pa.pricingActivityId.pricingStrategyTypeCode, codelistFlag) else "",
				"MinimalPrice" : if(pa.minimumPrice != null) pa.minimumPrice else null,
				"MaximalPrice" : if(pa.maximumPrice != null ) pa.maximumPrice else null,
				"Currency" : if(pa.currencyCode != null) pa.currencyCode else null,
				"StockTargetDate" : if(pa.stockTargetDate != null) pa.stockTargetDate else "",
				"ActiveFrom" : if(!isEmpty(pa.pricingActivityId.effectiveFromDateTime)) pa.pricingActivityId.effectiveFromDateTime else defaultFromDateTime,
				"ActiveUpTo" : if(!isEmpty(pa.effectiveUpToDateTime)) validateDate(pa.effectiveUpToDateTime) else "9999-12-31T23:59:59+00:00"
            }
            else if ( getOperationType(pa.documentActionCode) == "DeleteRecord" and pa.pricingActivityId.locationId == "*UNKNOWN" or 
            	pa.pricingActivityId.itemId == "*UNKNOWN" or pa.pricingActivityId.pricingStrategyTypeCode == "*UNKNOWN") "DeleteAllRecords": {
                "LocationID" : if(pa.pricingActivityId.locationId != null and pa.pricingActivityId.locationId != "*UNKNOWN") pa.pricingActivityId.locationId else null,
				"ProductID" : if(pa.pricingActivityId.itemId != null and pa.pricingActivityId.itemId != "*UNKNOWN") pa.pricingActivityId.itemId else null,
                "PricingStrategy" : if(pa.pricingActivityId.pricingStrategyTypeCode != null and pa.pricingActivityId.pricingStrategyTypeCode != "*UNKNOWN") 
                					codeListPricingActivityTypeCode(pa.pricingActivityId.pricingStrategyTypeCode, codelistFlag) else null,
                "ActiveFrom" : if(!isEmpty(pa.pricingActivityId.effectiveFromDateTime)) pa.pricingActivityId.effectiveFromDateTime else defaultFromDateTime,
				"ActiveUpTo" : if(!isEmpty(pa.effectiveUpToDateTime)) validateDate(pa.effectiveUpToDateTime) else "9999-12-31T23:59:59+00:00"
            }
            else if ( getOperationType(pa.documentActionCode) == "DeleteRecord" ) "DeleteRecord" : {
				"LocationID" : if(pa.pricingActivityId.locationId != null and pa.pricingActivityId.locationId != "*UNKNOWN") pa.pricingActivityId.locationId else "",
				"ProductID" : if(pa.pricingActivityId.itemId != null and pa.pricingActivityId.itemId != "*UNKNOWN") pa.pricingActivityId.itemId else "",
                "PricingStrategy" : if(pa.pricingActivityId.pricingStrategyTypeCode != null and pa.pricingActivityId.pricingStrategyTypeCode != "*UNKNOWN") 
                					codeListPricingActivityTypeCode(pa.pricingActivityId.pricingStrategyTypeCode, codelistFlag) else "",
                "ActiveFrom" : if(!isEmpty(pa.pricingActivityId.effectiveFromDateTime)) pa.pricingActivityId.effectiveFromDateTime else defaultFromDateTime,
				"ActiveUpTo" : if(!isEmpty(pa.effectiveUpToDateTime)) validateDate(pa.effectiveUpToDateTime) else "9999-12-31T23:59:59+00:00"
            }
            else{
            })
    })
 )}