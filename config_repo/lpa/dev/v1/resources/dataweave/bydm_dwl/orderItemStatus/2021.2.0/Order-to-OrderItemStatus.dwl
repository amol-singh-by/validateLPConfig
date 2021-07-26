%dw 2.0
import * from dw::Runtime

fun validateDateTimeFormat(str) = try(() -> (str as DateTime) as String { format: "yyyy-MM-dd'T'HH:mm:ssxxx"}) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result 
}

fun getOrderStatus(in) =
  if ( in == "ADDITION" or in == "CHANGED" ) "ORDERED"
  else if ( in == "DELETED" ) "CANCELLED"
  else ""

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemTypeCode(value, codelistFlag) =
  codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)
    else ''
    else -> try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
OrderItemStatus: {
	(payload[vars.bulkType] filter ($.documentActionCode != "DELETE") map ((order, orderIndex) -> {
		(order.lineItem map ((orderLI, orderLIIndex) -> if ( order.orderTypeCode == "150" or order.orderTypeCode == "220" ) Record: {
			OrderID: if ( order.orderId != null ) order.orderId
                else "",
			Position: if ( orderLI.lineItemNumber != null ) orderLI.lineItemNumber
                else "",
			Type: getOrderStatus(orderLI.actionCode),
			StatusTime: if ( !isEmpty(orderLI.lastUpdateDateTime) ) validateDateTimeFormat(orderLI.lastUpdateDateTime)
                else "",
			Quantity: if ( orderLI.requestedQuantity.value is Object ) orderLI.requestedQuantity.value
                else (if ( orderLI.requestedQuantity.value != null ) orderLI.requestedQuantity.value
                else ""),
			UnitID: codeListItemTypeCode(orderLI.requestedQuantity.measurementUnitCode, codelistFlag)
		}

        else if ( order.orderTypeCode == "10005" or order.orderTypeCode == "10007" ) Record: {
			OrderID: if ( order.orderId != null ) order.orderId
                else "",
			Position: if ( orderLI.lineItemNumber != null ) orderLI.lineItemNumber
                else "",
			Type: "CANCELLED",
			StatusTime: if ( !isEmpty(orderLI.lastUpdateDateTime) ) validateDateTimeFormat(orderLI.lastUpdateDateTime) else "",
			Quantity: if ( orderLI.lineItemDetail.requestedQuantity.value is Object ) orderLI.lineItemDetail.requestedQuantity.value
                else (if ( orderLI.lineItemDetail.requestedQuantity.value != null ) orderLI.lineItemDetail.requestedQuantity.value
                else ""),
			UnitID: codeListItemTypeCode(orderLI.lineItemDetail.requestedQuantity.measurementUnitCode, codelistFlag)
		}
        else Record: ""
      ))
	}))
}