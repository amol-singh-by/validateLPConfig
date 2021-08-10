%dw 2.0
import * from dw::Runtime

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
CommonPromotions: {
	(payload[vars.bulkType] filter (() -> ($.documentActionCode != 'DELETE')) distinctBy $.promotionId map () -> {
		Record: {
			CommonPromotionID: if ( $.promotionId != null ) $.promotionId
          else "",
			Name: if ( $.name != null ) $.name
          else "",
			Description: if ( $.description.value != null and $.description.value != "" ) $.description.value
          else null,
			Type: if ( $.promotionTypeCode != null ) $.promotionTypeCode
          else "",
			PromotionFrom: if ( $.effectiveFromDate != null ) $.effectiveFromDate
          else "",
			PromotionUpTo: if ( !isEmpty($.effectiveUpToDate)) validateDate($.effectiveUpToDate)
		  else ""
		}
	})
}