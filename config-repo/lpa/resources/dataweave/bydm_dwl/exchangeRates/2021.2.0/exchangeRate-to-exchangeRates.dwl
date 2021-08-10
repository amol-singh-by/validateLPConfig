%dw 2.0
import * from dw::Runtime

fun getOperationType(documentActionCode) =
  if ( documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH" ) "Record"
  else if ( documentActionCode == "DELETE" ) "DeleteRecord"
  else "Record"

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
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
"ExchangeRates": {(
    (payload[vars.bulkType] map(er,index) -> {
            (if ( getOperationType(er.documentActionCode) == "Record" ) "Record":{
                ReferenceCurrency: if ( er.sourceCurrency != null ) er.sourceCurrency
	              else "",
				Currency: if ( er.targetCurrency != null ) er.targetCurrency
	              else "",
				ExchangeRate: if ( er.sourceToTargetRatio != null ) er.sourceToTargetRatio
	              else "",
				ActiveFrom: if ( !isEmpty(er.effectiveFromDate) ) er.effectiveFromDate else defaultFromDate,
				ActiveUpTo: if ( !isEmpty(er.effectiveUpToDate) ) validateDate(er.effectiveUpToDate) else "9999-12-31"
           }
            else if ( getOperationType(er.documentActionCode) == "DeleteRecord" and (er.sourceCurrency == "*UNKNOWN" or er.targetCurrency == "*UNKNOWN")
            ) "DeleteAllRecords": {
                ReferenceCurrency: if ( er.sourceCurrency != null and er.sourceCurrency != "*UNKNOWN" ) er.sourceCurrency else null,
				Currency: if ( er.targetCurrency != null and er.targetCurrency != "*UNKNOWN") er.targetCurrency else null,
				ActiveFrom: if ( !isEmpty(er.effectiveFromDate) ) er.effectiveFromDate else defaultFromDate,
				ActiveUpTo: if ( !isEmpty(er.effectiveUpToDate) ) validateDate(er.effectiveUpToDate) else "9999-12-31"
            }
            else if ( getOperationType(er.documentActionCode) == "DeleteRecord" ) "DeleteRecord" : {
                ReferenceCurrency: if ( er.sourceCurrency != null or er.sourceCurrency != "" ) er.sourceCurrency
	              else "",
				Currency: if ( er.targetCurrency != null or er.targetCurrency != "" ) er.targetCurrency
	              else "",
				ActiveFrom: if ( !isEmpty(er.effectiveFromDate) ) er.effectiveFromDate else defaultFromDate,
				ActiveUpTo: if ( !isEmpty(er.effectiveUpToDate) ) validateDate(er.effectiveUpToDate) else "9999-12-31"
            }
            else{
            })
    })
 )}