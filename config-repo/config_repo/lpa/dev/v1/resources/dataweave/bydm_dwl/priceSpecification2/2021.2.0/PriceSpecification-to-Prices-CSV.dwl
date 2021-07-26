%dw 2.0
@StreamCapable()
import * from dw::Runtime

fun getOperationType(obj) =
  if ((obj.itemId == "*UNKNOWN" or isEmpty(obj.itemId) 
  	or obj.locationId == "*UNKNOWN" or isEmpty(obj.locationId) 
  	or obj.priceType == "*UNKNOWN" or isEmpty(obj.priceType)
  ) and (obj.documentActionCode == "DELETE")) "DeleteAllRecords"
  else if ( obj.documentActionCode == "DELETE" ) "DeleteRecord"
  else "Record"
  
fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

output application/xml  deferred = true, skipNullOn = "everywhere"
---
Prices: {
	(payload map (item, index) -> {
		(getOperationType(item)): 
        if ( getOperationType(item) == "DeleteAllRecords" ) {
			ProductID: if ( !isEmpty(item.itemId) and item.itemId != "*UNKNOWN" ) item.itemId
              else null,
			LocationID: if ( !isEmpty(item.locationId) and item.locationId != "*UNKNOWN" ) item.locationId
              else null,
			Type: if ( !isEmpty(item.priceType) and item.priceType != "*UNKNOWN" ) item.priceType
              else null,
			ActiveFrom: if ( item.priceEffectiveFromDate != null and item.priceEffectiveFromDate != "") item.priceEffectiveFromDate
              else "",
			ActiveUpTo: if ( item.priceEffectiveUpToDate != null and item.priceEffectiveUpToDate != "") validateDate(item.priceEffectiveUpToDate)
              else ""
		}
        else if ( getOperationType(item) == "DeleteRecord" ) {
			ProductID: if ( item.itemId != null ) item.itemId
              else "",
			LocationID: if ( item.locationId != null ) item.locationId
              else "",
			Type: if ( item.priceType != null ) item.priceType
              else "",
			ActiveFrom: if ( item.priceEffectiveFromDate != null and item.priceEffectiveFromDate != "") item.priceEffectiveFromDate
              else "",
			ActiveUpTo: if ( item.priceEffectiveUpToDate != null and item.priceEffectiveUpToDate != "") validateDate(item.priceEffectiveUpToDate)
              else ""
		}
        else
          {
			ProductID: if ( item.itemId != null ) item.itemId
              else "",
			LocationID: if ( item.locationId != null ) item.locationId
              else "",
			Type: if ( item.priceType != null ) item.priceType
              else "",
			PriceWithoutTax: if ( item."depositAmount.value" != null and item."depositAmount.value" != "" and item.priceType == "NORMAL" ) item."depositAmount.value"
              else if ( item."retailPrice.value" != null and item."retailPrice.value" != "" and item.priceType == "PURCHASE" ) item."retailPrice.value"
              else null,
			CustomerPrice: if ( item."retailPriceWithTaxes.value" != null and item."retailPriceWithTaxes.value" != "" and (item.priceType == "NORMAL" or item.priceType == "REDUCED") ) item."retailPriceWithTaxes.value"
              else null,
			TaxPercentage: if ( item.taxPercentage != null and item.taxPercentage != "" ) item.taxPercentage
              else null,
			Deposit: if ( item."depositAmount.value" != null and item."depositAmount.value" != "" ) item."depositAmount.value"
              else null,
			ActiveFrom: if ( item.priceEffectiveFromDate != null and item.priceEffectiveFromDate != "") item.priceEffectiveFromDate
              else "",
			ActiveUpTo: if ( item.priceEffectiveUpToDate != null and item.priceEffectiveUpToDate != "") validateDate(item.priceEffectiveUpToDate)
              else "",
			Currency: if ( item."depositAmount.currencyCode" != null ) item."depositAmount.currencyCode"
              else ""
		}
	})
}
