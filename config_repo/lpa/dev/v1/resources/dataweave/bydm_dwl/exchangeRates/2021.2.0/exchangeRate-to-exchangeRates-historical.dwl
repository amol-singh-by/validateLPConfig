%dw 2.0
import * from dw::Runtime

fun getOperationType(documentActionCode) =
  if ( documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH" ) "Record"
  else if ( documentActionCode == "DELETE" ) "DeleteRecord"
  else "Record"

output application/xml deferred = true, skipNullOn = "everywhere"
---
ExchangeRates: {
	(payload[vars.bulkType] map () -> {
		(getOperationType($.documentActionCode)): 
        if ( (getOperationType($.documentActionCode)) != "DeleteRecord" ) {
			ReferenceCurrency: if ( $.sourceCurrency != null ) $.sourceCurrency
              else "",
			Currency: if ( $.targetCurrency != null ) $.targetCurrency
              else "",
			ExchangeRate: if ( $.sourceToTargetRatio != null ) $.sourceToTargetRatio
              else "",
			ActiveFrom: if ( !isEmpty($.effectiveFromDate) ) $.effectiveFromDate else "1970-01-01",
			ActiveUpTo: if ( !isEmpty($.effectiveUpToDate) ) $.effectiveUpToDate else "9999-12-31"
		}
        else
          {
			ReferenceCurrency: if ( $.sourceCurrency != null or $.sourceCurrency != "" ) $.sourceCurrency
              else "",
			Currency: if ( $.targetCurrency != null or $.targetCurrency != "" ) $.targetCurrency
              else "",
			ActiveFrom: if ( !isEmpty($.effectiveFromDate) ) $.effectiveFromDate else "1970-01-01",
			ActiveUpTo: if ( !isEmpty($.effectiveUpToDate) ) $.effectiveUpToDate else "9999-12-31"
		}
	})
}