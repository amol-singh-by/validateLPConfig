%dw 2.0
import * from dw::Runtime

fun validateDateTimeFormat(str) =
  try(() -> (str as DateTime) as String {format: "yyyy-MM-dd'T'HH:mm:ssxxx"}) match {
    case theOutput if theOutput.success ~= false -> ''
    else -> $.result
  }

output application/xml  deferred = true, skipNullOn = "everywhere"
---
Orders: {
	(payload[vars.bulkType] filter (() -> ($.orderTypeCode == "150" or $.orderTypeCode == "220") and ($.documentActionCode != "DELETE")) map ((order, orderIndex) -> 
      Record: {
		OrderID: if ( order.orderId != null ) order.orderId else "",
		Name: if ( order.orderName != null and order.orderName != "" ) order.orderName else order.orderId default "",
		Description: (order.orderNote filter (() -> ($.'type' == "DESCRIPTION")))[0].text.value default null,
		LocationIDTarget: if ( order.orderLogisticalInformation.shipTo.primaryId != null ) order.orderLogisticalInformation.shipTo.primaryId else "",
		OrderTime: if ( !isEmpty(order.creationDateTime) ) validateDateTimeFormat(order.creationDateTime) else ""
	}
  ))
}
