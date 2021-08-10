%dw 2.0
import * from dw::Runtime
@StreamCapable()

fun getDate(value) = value[0 to 9]

fun getTimeZone(value) = value[10 to 15] default "+00:00"

fun getDateTime(date, time) =
  if ( (time != null and time != "") and (date != null and date != "") ) (getDate(date) ++ "T" ++ time ++ getTimeZone(date))
  else null

fun validateDateTimeFormat(str) = try(() -> (str as DateTime) as String { format: "yyyy-MM-dd'T'HH:mm:ssxxx"}) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result 
}

output application/xml  deferred = true, skipNullOn = "everywhere"
---
OrderItems: {
	(payload filter (() -> ($.orderTypeCode == "150" or $.orderTypeCode == "220") and ($.documentActionCode != "DELETE")) map ((orderItem, orderItemIndex) -> Record: {
		OrderID: if ( orderItem.orderId != null ) orderItem.orderId
              else "",
		Position: if ( orderItem.'lineItem.lineItemNumber' != null ) orderItem.'lineItem.lineItemNumber'
              else "",
		ProductID: if ( orderItem.'lineItem.transactionalTradeItem.primaryId' != null ) orderItem.'lineItem.transactionalTradeItem.primaryId'
              else "",
		ExpectedArrival: validateDateTimeFormat(getDateTime(orderItem.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date', orderItem.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.time')),
		ExpectedAvailability: if (validateDateTimeFormat(getDateTime(orderItem.'lineItem.transactionalTradeItem.transactionalItemData.availableForSaleDate', orderItem.'lineItem.transactionalTradeItem.transactionalItemData.availableForSaleTime')) != '')
								validateDateTimeFormat(getDateTime(orderItem.'lineItem.transactionalTradeItem.transactionalItemData.availableForSaleDate', orderItem.'lineItem.transactionalTradeItem.transactionalItemData.availableForSaleTime'))
			  else validateDateTimeFormat(getDateTime(orderItem.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date', orderItem.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.time')),
		Description: if ( orderItem.'orderNote.type' == "DESCRIPTION" ) orderItem.'orderNote.text.value'
              else null,
		BYOrderItemID: if ( orderItem.'lineItem.transactionalTradeItem.additionalTradeItemId.typeCode' == "FOR_INTERNAL_USE_1" ) orderItem.'lineItem.transactionalTradeItem.additionalTradeItemId.value'
              else null
	}
    ))
}
