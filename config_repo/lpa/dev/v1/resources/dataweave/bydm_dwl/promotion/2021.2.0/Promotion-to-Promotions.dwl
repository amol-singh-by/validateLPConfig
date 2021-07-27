%dw 2.0
import * from dw::Runtime

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

fun getOperationType(promotion) =
  if ( promotion.documentActionCode == "ADD" or promotion.documentActionCode == "CHANGE_BY_REFRESH" ) "Record"
  else if ( promotion.documentActionCode == "DELETE" ) "DeleteRecord"
  else "Record"
  
fun getPromotionValue(eligibilityInformation) =
  eligibilityInformation.financialInformation.promotionStrategy match {
	case "FIXEDPRICE" -> eligibilityInformation.financialInformation.promotionRetailPrice.value
    case "RELATIVE" -> eligibilityInformation.financialInformation.promotionPercentage
    case "FREEQUANTITY" -> eligibilityInformation.financialInformation.getQuantity
    case "ABSOLUTE" -> eligibilityInformation.financialInformation.absoluteDiscount.value
    else -> null
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
Promotions: {
	(payload[vars.bulkType] map (promo, index) -> {
		(promo.eligibilityInformation map (eligibilityInfo,index_ei) -> 
			if ( getOperationType(promo) == "Record" ) {
		Record: {
			CommonPromotionID: if ( promo.promotionId != null ) promo.promotionId
	          else "",
			LocationID: if ( eligibilityInfo.location.locationId != null and eligibilityInfo.location.locationId != "" ) eligibilityInfo.location.locationId
	          else null,
			ProductID: if ( eligibilityInfo.item.itemId != null ) eligibilityInfo.item.itemId
	          else "",
			PromotionFrom: if ( eligibilityInfo.effectiveFromDate != null ) eligibilityInfo.effectiveFromDate
	          else "",
			PromotionUpTo: if ( !isEmpty(eligibilityInfo.effectiveUpToDate) ) validateDate(eligibilityInfo.effectiveUpToDate)
			  else "",
			Description: if ( eligibilityInfo.financialInformation.description.value != null and eligibilityInfo.financialInformation.description.value != "" ) eligibilityInfo.financialInformation.description.value
	          else null,
			Strategy: if ( eligibilityInfo.financialInformation.promotionStrategy != null and eligibilityInfo.financialInformation.promotionStrategy != "" ) eligibilityInfo.financialInformation.promotionStrategy
	          else null,
			Value: getPromotionValue(eligibilityInfo),
			BuyQuantity: if ( eligibilityInfo.financialInformation.buyQuantity != null and eligibilityInfo.financialInformation.buyQuantity != "" ) eligibilityInfo.financialInformation.buyQuantity
	          else null,
			Spend: if ( eligibilityInfo.financialInformation.promotionSpend.value != null and eligibilityInfo.financialInformation.promotionSpend.value != "" ) eligibilityInfo.financialInformation.promotionSpend.value
	          else null,
			Condition: if ( eligibilityInfo.financialInformation.promotionCondition != null and eligibilityInfo.financialInformation.promotionCondition != "" ) eligibilityInfo.financialInformation.promotionCondition
	          else null,
			BuyLimit: if ( eligibilityInfo.financialInformation.maximumPromotionBuyQuantity != null and eligibilityInfo.financialInformation.maximumPromotionBuyQuantity != "" ) eligibilityInfo.financialInformation.maximumPromotionBuyQuantity
	          else null
		}
	} else {
		"DeleteRecord": {
			CommonPromotionID: if ( promo.promotionId != null ) promo.promotionId
	          else "",
			LocationID: if (eligibilityInfo.location.locationId != null and eligibilityInfo.location.locationId != "" ) eligibilityInfo.location.locationId
	          else null,
			ProductID: if (eligibilityInfo.item.itemId != null ) eligibilityInfo.item.itemId
	          else "",
			PromotionFrom: if (eligibilityInfo.effectiveFromDate != null and eligibilityInfo.effectiveFromDate != "") eligibilityInfo.effectiveFromDate
	          else "",
			PromotionUpTo: if (!isEmpty(eligibilityInfo.effectiveUpToDate)) validateDate(eligibilityInfo.effectiveUpToDate)
			  else ""
		}
	})})
}