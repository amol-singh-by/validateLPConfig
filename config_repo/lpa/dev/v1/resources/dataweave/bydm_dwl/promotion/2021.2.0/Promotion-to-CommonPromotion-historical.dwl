%dw 2.0
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
			PromotionFrom: if ( !isEmpty($.effectiveFromDate) ) $.effectiveFromDate
          else "",
			PromotionUpTo: if ( !isEmpty($.effectiveUpToDate) ) $.effectiveUpToDate
          else ""
		}
	})
}