%dw 2.0
import * from dw::Runtime

fun getOperationType(documentActionCode) =
  if ( documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH" ) "Record"
  else if ( documentActionCode == "DELETE" ) "DeleteRecord"
  else "Record"

output application/xml deferred = true, skipNullOn = "everywhere"
---
"ExchangeRates": {(
    (payload[vars.bulkType] map(er,index) -> {
            (if ( getOperationType(er.documentActionCode) == "Record" ) "Record":{
                ReferenceCurrency: if ( er.sourceCurrency != null ) er.sourceCurrency else "",
				Currency: if ( er.targetCurrency != null ) er.targetCurrency else "",
				ExchangeRate: if ( er.sourceToTargetRatio != null ) er.sourceToTargetRatio else "",
				ActiveFrom: if ( !isEmpty(er.effectiveFromDate) ) er.effectiveFromDate else "1970-01-01",
				ActiveUpTo: if ( !isEmpty(er.effectiveUpToDate) ) er.effectiveUpToDate else "9999-12-31"
           }
            else if ( getOperationType(er.documentActionCode) == "DeleteRecord" and (er.sourceCurrency == "*UNKNOWN" or er.targetCurrency == "*UNKNOWN")
            ) "DeleteAllRecords": {
                ReferenceCurrency: if ( er.sourceCurrency != null and er.sourceCurrency != "*UNKNOWN" ) er.sourceCurrency else null,
				Currency: if ( er.targetCurrency != null and er.targetCurrency != "*UNKNOWN" ) er.targetCurrency else null,
				ActiveFrom: if ( !isEmpty(er.effectiveFromDate) ) er.effectiveFromDate else "1970-01-01",
				ActiveUpTo: if ( !isEmpty(er.effectiveUpToDate) ) er.effectiveUpToDate else "9999-12-31"
            }
            else if ( getOperationType(er.documentActionCode) == "DeleteRecord" ) "DeleteRecord" : {
                ReferenceCurrency: if ( er.sourceCurrency != null or er.sourceCurrency != "" ) er.sourceCurrency else "",
				Currency: if ( er.targetCurrency != null or er.targetCurrency != "" ) er.targetCurrency else "",
				ActiveFrom: if ( !isEmpty(er.effectiveFromDate) ) er.effectiveFromDate else "1970-01-01",
				ActiveUpTo: if ( !isEmpty(er.effectiveUpToDate) ) er.effectiveUpToDate else "9999-12-31"
            }
            else{
            })
    })
 )}