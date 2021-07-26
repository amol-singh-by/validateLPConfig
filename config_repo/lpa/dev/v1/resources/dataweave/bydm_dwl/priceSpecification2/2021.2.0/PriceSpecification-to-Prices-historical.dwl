%dw 2.0
import * from dw::Runtime
fun getOperationType(obj) =
  if ((obj.itemId == "*UNKNOWN" or isEmpty(obj.itemId) 
  	or obj.locationId == "*UNKNOWN" or isEmpty(obj.locationId) 
  	or obj.priceType == "*UNKNOWN" or isEmpty(obj.priceType)
  ) and (obj.documentActionCode == "DELETE")) "DeleteAllRecords"
  else if ( obj.documentActionCode == "DELETE" ) "DeleteRecord"
  else "Record"

output application/xml deferred = true, skipNullOn = "everywhere"
---
Prices: {
	(payload[vars.bulkType] map () -> {
		(getOperationType($)): 
        if ( getOperationType($) == "DeleteAllRecords" ) {
			ProductID: if ( !isEmpty($.itemId) and $.itemId != "*UNKNOWN" ) $.itemId
              else null,
			LocationID: if ( !isEmpty($.locationId) and $.locationId != "*UNKNOWN" ) $.locationId
              else null,
			Type: if ( !isEmpty($.priceType) and $.priceType != "*UNKNOWN" ) $.priceType
              else null,
			ActiveFrom: if ( $.priceEffectiveFromDate != null ) $.priceEffectiveFromDate
              else "",
			ActiveUpTo: if ( $.priceEffectiveUpToDate != null ) $.priceEffectiveUpToDate
              else ""
		}
        else if ( getOperationType($) == "DeleteRecord" ) {
			ProductID: if ( $.itemId != null ) $.itemId
              else "",
			LocationID: if ( $.locationId != null ) $.locationId
              else "",
			Type: if ( $.priceType != null ) $.priceType
              else "",
			ActiveFrom: if ( $.priceEffectiveFromDate != null ) $.priceEffectiveFromDate
              else "",
			ActiveUpTo: if ( $.priceEffectiveUpToDate != null ) $.priceEffectiveUpToDate
              else ""
		}
        else
          {
			ProductID: if ( $.itemId != null ) $.itemId
              else "",
			LocationID: if ( $.locationId != null ) $.locationId
              else "",
			Type: if ( $.priceType != null ) $.priceType
              else "",
			PriceWithoutTax: if ( $.depositAmount.value != null and $.depositAmount.value != "" and $.priceType == "NORMAL" ) $.depositAmount.value
              else if ( $.retailPrice.value != null and $.retailPrice.value != "" and $.priceType == "PURCHASE" ) $.retailPrice.value
              else null,
			CustomerPrice: if ( $.retailPriceWithTaxes.value != null and $.retailPriceWithTaxes.value != "" and ($.priceType == "NORMAL" or $.priceType == "REDUCED") ) $.retailPriceWithTaxes.value
              else null,
			TaxPercentage: if ( $.taxPercentage != null and $.taxPercentage != "" ) $.taxPercentage
              else null,
			Deposit: if ( $.depositAmount.value != null and $.depositAmount.value != "" ) $.depositAmount.value
              else null,
			ActiveFrom: if ( $.priceEffectiveFromDate != null ) $.priceEffectiveFromDate
              else "",
			ActiveUpTo: if ( $.priceEffectiveUpToDate != null ) $.priceEffectiveUpToDate
              else "",
			Currency: if ( $.depositAmount.currencyCode != null and $.depositAmount.currencyCode != "" ) $.depositAmount.currencyCode
              else null
		}
	})
}
