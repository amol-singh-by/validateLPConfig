%dw 2.0
import * from dw::Runtime
@StreamCapable()

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

output application/xml  deferred = true, skipNullOn = "everywhere"
---
OrderItemStatus: {
	(payload filter ($.documentActionCode != "DELETE") map ((orderItemStatus, orderItemStatusIndex) -> if ( orderItemStatus.orderTypeCode == "150" or orderItemStatus.orderTypeCode == "220" ) Record: {
		OrderID: if ( orderItemStatus.orderId != null ) orderItemStatus.orderId
              else "",
		Position: if ( orderItemStatus.'lineItem.lineItemNumber' != null ) orderItemStatus.'lineItem.lineItemNumber'
              else "",
		Type: if ( orderItemStatus.'lineItem.lineItemActionCode' != null ) getOrderStatus(orderItemStatus.'lineItem.lineItemActionCode')
              else "",
		StatusTime: if ( !isEmpty(orderItemStatus.'lineItem.lastUpdateDateTime') ) validateDateTimeFormat(orderItemStatus.'lineItem.lastUpdateDateTime')
                else "",
		Quantity: if ( orderItemStatus.'lineItem.requestedQuantity.value' != null ) orderItemStatus.'lineItem.requestedQuantity.value'
              else "",
		UnitID: codeListItemTypeCode(orderItemStatus.'lineItem.requestedQuantity.measurementUnitCode', codelistFlag)
	}

      else if ( orderItemStatus.orderTypeCode == "10005" or orderItemStatus.orderTypeCode == "10007" ) Record: {
		OrderID: if ( orderItemStatus.orderId != null ) orderItemStatus.orderId
              else "",
		Position: if ( orderItemStatus.'lineItem.lineItemNumber' != null ) orderItemStatus.'lineItem.lineItemNumber'
              else "",
		Type: "CANCELLED",
		StatusTime: if ( !isEmpty(orderItemStatus.'lineItem.lastUpdateDateTime') ) validateDateTimeFormat(orderItemStatus.'lineItem.lastUpdateDateTime')
                else "",
		Quantity: if ( orderItemStatus.'lineItem.lineItemDetail.requestedQuantity.value' != null ) orderItemStatus.'lineItem.lineItemDetail.requestedQuantity.value'
              else "",
		UnitID: codeListItemTypeCode(orderItemStatus.'lineItem.lineItemDetail.requestedQuantity.measurementUnitCode', codelistFlag)
	}

      else Record: ""
    ))
}
