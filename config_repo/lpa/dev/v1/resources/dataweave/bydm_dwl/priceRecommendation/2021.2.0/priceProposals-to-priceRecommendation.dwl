%dw 2.0
output application/json skipNullOn = "everywhere"
---
{
	"header": {
		"sender": p('lpa.outbound.sender'),
		"receiver": [
			p('lpa.outbound.receiver')
		],
		"model": p('lpa.outbound.model'),
		"messageVersion": p('lpa.outbound.PriceProposals.messageVersion'),
		"messageId": uuid(),
		"type" : "priceRecommendation",
		"creationDateAndTime": now() as String { format: "yyyy-MM-dd'T'HH:mm:ssxxx"} as String
	},
	"priceRecommendation": payload.PriceProposals.*Record map (pp , indexOfOp) -> {
		"creationDateTime" : now() as String { format: "yyyy-MM-dd'T'HH:mm:ssxxx"} as String,
		"documentStatusCode" : "ORIGINAL",
		"documentActionCode" : "ADD",
		"priceRecommendationId" : {
			"itemId" : if (!isEmpty(pp.ProductID)) (pp.ProductID) else '',
			"locationId" : if (!isEmpty(pp.LocationID)) (pp.LocationID) else '',
			"effectiveFromDateTime" : if (!isEmpty(pp.ValidFrom)) (pp.ValidFrom) else '',
			"priceTypeCode" : if (!isEmpty(pp.PriceType)) (pp.PriceType) else '',
		},
		"recommendedPrice" : {
			"currencyCode" : if (!isEmpty(pp.Currency)) (pp.Currency) else '',
			"value" : if (!isEmpty(pp.Price)) (pp.Price as Number) else 0 as Number
		},
		"referenceDateTime" : if (!isEmpty(pp.ReferenceTimestamp)) (pp.ReferenceTimestamp as String {format: "yyyy-MM-dd'T'HH:mm:ssxxx"}) else ''
	}
}
