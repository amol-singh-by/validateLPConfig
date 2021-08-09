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
ExchangeRates: {
	(payload[vars.bulkType] filter ($.documentActionCode != "DELETE" ) map () -> {
		"DeleteRecord": {
			ReferenceCurrency: if ( $.sourceCurrency != null ) $.sourceCurrency
          else "",
			Currency: if ( $.targetCurrency != null ) $.targetCurrency
          else "",
			ActiveFrom: if ( !isEmpty($.effectiveFromDate) ) $.effectiveFromDate else defaultFromDate,
			ActiveUpTo: if ( !isEmpty($.effectiveUpToDate) ) validateDate($.effectiveUpToDate) else "9999-12-31"
		}
	})
}