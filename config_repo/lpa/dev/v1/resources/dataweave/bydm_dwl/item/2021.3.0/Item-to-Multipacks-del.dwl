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

output application/xml deferred = true, skipNullOn = "everywhere"
---
Multipacks: {
	(payload[vars.bulkType] filter ($.documentActionCode != 'DELETE' and (($.tradeItemUnitDescriptorCode default '') == 'PACK_OR_INNER_PACK')) map(item,index) -> DeleteAllRecords: {
		"MultipackProductID": if (item.itemId.primaryId != "*UNKNOWN") item.itemId.primaryId else null,
		"ItemProductID": if (item.childItem.childTradeItem[0].primaryId != "*UNKNOWN") item.childItem.childTradeItem[0].primaryId else null,
		"ActiveFrom": if ( item.status != null and (item.status[0].effectiveFromDateTime) != null and (item.status[0].effectiveFromDateTime) != "" ) (item.status[0].effectiveFromDateTime splitBy "T")[0] else defaultFromDate,
		"ActiveUpTo": if ( item.status != null and (item.status[0].effectiveUpToDateTime) != null and (item.status[0].effectiveUpToDateTime) != "" ) validateDate((item.status[0].effectiveUpToDateTime splitBy "T")[0]) else '9999-12-31'
	})
}