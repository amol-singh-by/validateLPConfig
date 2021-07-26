%dw 2.0

fun getType(referenceDay,finalOrderTime,typeValue) =
  if ( typeValue == "ORDER" and (referenceDay as String {format: "yyyy-MM-dd"}) == (finalOrderTime as String {format: "yyyy-MM-dd"})) "PLAN_ARRIVAL"
  else if ( typeValue == "ORDER" and (referenceDay as String {format: "yyyy-MM-dd"}) < (finalOrderTime as String {format: "yyyy-MM-dd"})) "FALLBACK_ORDER"
  else if ( typeValue == "ORDERPROJECTION") "ORDER_PROJECTION"
  else ''
  
output application/json skipNullOn = "everywhere"
---
{
	"header": {
		"sender": p('lpa.outbound.sender'),
		"receiver": [
			p('lpa.outbound.receiver')
		],
		"model": p('lpa.outbound.model'),
		"messageVersion": p('lpa.outbound.OrderProposals.messageVersion'),
		"messageId": uuid(),
		"type" : "plannedSupply",
		"creationDateAndTime": now() as String { format: "yyyy-MM-dd'T'HH:mm:ssxxx"} as String
	},
	"plannedSupply": payload.OrderProposals.*Record map (op , indexOfOp) -> {
		"creationDateTime" : now() as String { format: "yyyy-MM-dd'T'HH:mm:ssxxx"} as String,
		"documentStatusCode" : "ORIGINAL",
		"documentActionCode" : "ADD",
		"plannedSupplyId" : {
			"item" : {
				"primaryId" : if (!isEmpty(op.ProductID)) (op.ProductID) else ''
				},
			"shipTo" : {
				"primaryId" : if (!isEmpty(op.LocationIDTarget)) (op.LocationIDTarget) else ''
				},
			"shipFrom" : {
				"primaryId" : if (!isEmpty(op.LocationIDSource)) (op.LocationIDSource) else ''
				}
		
		},
		"type" : getType(op.ReferenceDay, op.FinalOrderTime, op.'Type'),
		"additionalReferenceInformation" : op.BYOrderItemID,
		"plannedSupplyDetail" : [{
			"requestedDeliveryDate" : (op.ExpectedArrival as Date as String {format: "uuuu-MM-dd"}),
			"requestedDeliveryTime" : (op.ExpectedArrival as DateTime as String {format: "HH:mm:ssXXX"}),
			"availableForSaleDate" : (op.ExpectedAvailability as Date as String {format: "uuuu-MM-dd"}),
			"availableForSaleTime" : (op.ExpectedAvailability as DateTime as String {format: "HH:mm:ssXXX"}),
			"requestedQuantity" : {
				"value" : op.Quantity as Number,
				"measurementUnitCode" : op.UnitID,
			},
			"unconstrainedQuantity": {
				"value": op.UnconstrainedQuantity as Number
			},
			"purchaseMethod" : op.ProcurementPlanType,
			"procurementCalendarID" : op.ProcurementCalendarID,
			"orderCutoffDateTime" : op.FinalOrderTime,
			"historyEndDate" : op.ReferenceDay
		}]
	}
}