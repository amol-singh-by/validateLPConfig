%dw 2.0
import * from dw::Runtime

fun getDate(value) =
  value[0 to 9]

fun getTimeZone(value) =
  value[10 to 15] default "+00:00"

fun getDateTime(date, time) =
  if ( (time != null and time != "") and (date != null and date != "") ) (getDate(date) ++ "T" ++ time ++ getTimeZone(date))
  else null

fun validateDateTimeFormat(str) = try(() -> (str as DateTime) as String { format: "yyyy-MM-dd'T'HH:mm:ssxxx"}) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result 
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
OrderItems: {
	(payload[vars.bulkType] filter (() -> ($.orderTypeCode == "150" or $.orderTypeCode == "220") and ($.documentActionCode != "DELETE")) map ((order, orderIndex) -> {
		(order.lineItem map ((orderLI, orderLIIndex) -> Record: {
			OrderID: if ( order.orderId != null ) order.orderId
                else "",
			Position: if ( orderLI.lineItemNumber != null ) orderLI.lineItemNumber
                else "",
			ProductID: if ( orderLI.transactionalTradeItem.primaryId != null ) orderLI.transactionalTradeItem.primaryId
                else "",
			ExpectedArrival: validateDateTimeFormat(getDateTime(orderLI.lineItemDetail[0].orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date, orderLI.lineItemDetail[0].orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.time)),
			ExpectedAvailability: if (validateDateTimeFormat(getDateTime(orderLI.transactionalTradeItem.transactionalItemData[0].availableForSaleDate, orderLI.transactionalTradeItem.transactionalItemData[0].availableForSaleTime)) != '')
									validateDateTimeFormat(getDateTime(orderLI.transactionalTradeItem.transactionalItemData[0].availableForSaleDate, orderLI.transactionalTradeItem.transactionalItemData[0].availableForSaleTime))
				else validateDateTimeFormat(getDateTime(orderLI.lineItemDetail[0].orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date, orderLI.lineItemDetail[0].orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.time)),
			Description: (order.orderNote filter (() -> ($.'type' == "DESCRIPTION")))[0].text.value default null,
			(flatten(orderLI.transactionalTradeItem.additionalTradeItemId) filter ($.typeCode == "FOR_INTERNAL_USE_1") map (item) -> 
                BYOrderItemID: item.value)
		}
      ))
	}))
}