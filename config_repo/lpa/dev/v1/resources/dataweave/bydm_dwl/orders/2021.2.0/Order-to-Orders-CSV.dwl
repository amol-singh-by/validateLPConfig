%dw 2.0
@StreamCapable()
import * from dw::Runtime

fun validateDateTimeFormat(str) = try(() -> (str as DateTime) as String { format: "yyyy-MM-dd'T'HH:mm:ssxxx"}) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result 
}

output application/xml  deferred = true, skipNullOn = "everywhere"
---
Orders: {
	(payload filter (() -> ($.orderTypeCode == "150" or $.orderTypeCode == "220") and ($.documentActionCode != "DELETE")) map ((order, orderIndex) -> Record: {
		OrderID: if ( order.orderId != null ) order.orderId
              else "",
		Name: if ( order.'orderName' != null and order.'orderName' != "" ) order.'orderName'
              else order.orderId default "",
		Description: if ( order.'orderNote.type' == "DESCRIPTION" ) order.'orderNote.text.value'
              else null,
		LocationIDTarget: if ( order.'orderLogisticalInformation.shipTo.primaryId' != null ) order.'orderLogisticalInformation.shipTo.primaryId'
              else "",
		OrderTime: if ( !isEmpty(order.creationDateTime) ) validateDateTimeFormat(order.creationDateTime) else ""
	}))
}
