%dw 2.0
@StreamCapable()
import * from dw::Runtime

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

fun getOperationType(item) =
	if (isEmpty(item.'eligibilityInformation.actionCode'))
		if ( item.documentActionCode != "DELETE" ) "Record"
		else "DeleteRecord"
	else if ( item.'eligibilityInformation.actionCode' == "DELETE" ) "DeleteRecord"
	else "Record"

fun getPromotionValue(promotion) =
  promotion."eligibilityInformation.financialInformation.promotionStrategy" match {
    case "FIXEDPRICE" -> promotion."eligibilityInformation.financialInformation.promotionRetailPrice.value"
    case "RELATIVE" -> promotion."eligibilityInformation.financialInformation.promotionPercentage"
    case "FREEQUANTITY" -> promotion."eligibilityInformation.financialInformation.getQuantity"
    case "ABSOLUTE" -> promotion."eligibilityInformation.financialInformation.absoluteDiscount.value"
    else -> null
  }

output application/xml  deferred = true, skipNullOn = "everywhere"
---
Promotions: {
	(payload map (item, index) -> 
		if (getOperationType(item) == "Record") {
		"DeleteRecord": {
			CommonPromotionID: if ( item.promotionId != null ) item.promotionId
          else "",
			LocationID: if ( item."eligibilityInformation.location.locationId" != null and item."eligibilityInformation.location.locationId" != "" ) item."eligibilityInformation.location.locationId"
          else null,
			ProductID: if ( item."eligibilityInformation.item.itemId" != null ) item."eligibilityInformation.item.itemId"
          else "",
			PromotionFrom: if ( item."eligibilityInformation.effectiveFromDate" != null ) item."eligibilityInformation.effectiveFromDate"
          else "",
			PromotionUpTo: if ( !isEmpty(item."eligibilityInformation.effectiveUpToDate") ) validateDate(item."eligibilityInformation.effectiveUpToDate")
		  else ""
		}
	} else {}
	)
}
