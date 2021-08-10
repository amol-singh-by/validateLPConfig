%dw 2.0
import * from dw::Runtime

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
Promotions: {
	(payload[vars.bulkType] filter ($.documentActionCode != "DELETE") map (promo, index) -> {
		(promo.eligibilityInformation map (eligibilityInfo,index_ei) -> {
		"DeleteRecord": {
			CommonPromotionID: if ( promo.promotionId != null ) promo.promotionId
	          else "",
			LocationID: if ( eligibilityInfo.location.locationId != null and eligibilityInfo.location.locationId != "" ) eligibilityInfo.location.locationId
	          else null,
			ProductID: if ( eligibilityInfo.item.itemId != null ) eligibilityInfo.item.itemId
	          else "",
			PromotionFrom: if ( eligibilityInfo.effectiveFromDate != null ) eligibilityInfo.effectiveFromDate
	          else "",
			PromotionUpTo: if ( !isEmpty(eligibilityInfo.effectiveUpToDate) ) validateDate(eligibilityInfo.effectiveUpToDate)
			  else ""
		}
	})})
}
