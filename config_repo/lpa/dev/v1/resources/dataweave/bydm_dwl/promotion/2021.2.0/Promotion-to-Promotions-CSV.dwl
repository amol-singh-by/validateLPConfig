%dw 2.0
@StreamCapable()
import * from dw::Runtime

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

fun getOperationType(documentActionCode) =
  if ( documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH" ) "Record"
  else if ( documentActionCode == "DELETE" ) "DeleteRecord"
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
		if ( getOperationType(item.documentActionCode) == "Record" ) {
		Record: {
			CommonPromotionID: if ( item.promotionId != null ) item.promotionId
          else "",
			LocationID: if ( item."eligibilityInformation.location.locationId" != null and item."eligibilityInformation.location.locationId" != "" ) item."eligibilityInformation.location.locationId"
          else null,
			ProductID: if ( item."eligibilityInformation.item.itemId" != null ) item."eligibilityInformation.item.itemId"
          else "",
			PromotionFrom: if ( item."eligibilityInformation.effectiveFromDate" != null ) item."eligibilityInformation.effectiveFromDate"
          else "",
			PromotionUpTo: if ( !isEmpty(item."eligibilityInformation.effectiveUpToDate") ) validateDate(item."eligibilityInformation.effectiveUpToDate")
		  else "",
			Description: if ( item."eligibilityInformation.financialInformation.description.value" != null and item."eligibilityInformation.financialInformation.description.value" != "" ) item."eligibilityInformation.financialInformation.description.value"
          else null,
			Strategy: if ( item."eligibilityInformation.financialInformation.promotionStrategy" != null and item."eligibilityInformation.financialInformation.promotionStrategy" != "" ) item."eligibilityInformation.financialInformation.promotionStrategy"
          else null,
			Value: getPromotionValue(item),
			BuyQuantity: if ( item."eligibilityInformation.financialInformation.buyQuantity" != null and item."eligibilityInformation.financialInformation.buyQuantity" != "" ) item."eligibilityInformation.financialInformation.buyQuantity"
          else null,
			Spend: if ( item."eligibilityInformation.financialInformation.promotionSpend.value" != null and item."eligibilityInformation.financialInformation.promotionSpend.value" != "" ) item."eligibilityInformation.financialInformation.promotionSpend.value"
          else null,
			Condition: if ( item."eligibilityInformation.financialInformation.promotionCondition" != null and item."eligibilityInformation.financialInformation.promotionCondition" != "" ) item."eligibilityInformation.financialInformation.promotionCondition"
          else null,
			BuyLimit: if ( item."eligibilityInformation.financialInformation.maximumPromotionBuyQuantity" != null and item."eligibilityInformation.financialInformation.maximumPromotionBuyQuantity" != "" ) item."eligibilityInformation.financialInformation.maximumPromotionBuyQuantity"
          else null
		}
	} else {
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
	})
}
