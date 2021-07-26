%dw 2.0
@StreamCapable()
import * from dw::Runtime

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

output application/xml  deferred=true, skipNullOn="everywhere"
---
OrderItemStatus: {
	(payload map((item,index)->
	Record: if ( payload."receivingAdvice.documentActionCode" != "DELETE" ) {
		OrderID: if ( item.'receivingAdvice.receivingAdviceLogisticUnit.lineItem.purchaseOrder.entityId' != null ) item.'receivingAdvice.receivingAdviceLogisticUnit.lineItem.purchaseOrder.entityId' else "",
		Position: if ( item.'receivingAdvice.receivingAdviceLogisticUnit.lineItem.purchaseOrder.lineItemNumber' != null ) item.'receivingAdvice.receivingAdviceLogisticUnit.lineItem.purchaseOrder.lineItemNumber' else "",
		Type: "ARRIVED",
		StatusTime: if ( item.'receivingAdvice.receivingDateTime' != null ) item.'receivingAdvice.receivingDateTime' else "",
		Quantity: if ( item.'receivingAdvice.receivingAdviceLogisticUnit.lineItem.quantityReceived.value' != null ) item.'receivingAdvice.receivingAdviceLogisticUnit.lineItem.quantityReceived.value' else "",
		UnitID: codeListItemTypeCode(item.'receivingAdvice.receivingAdviceLogisticUnit.lineItem.quantityReceived.measurementUnitCode' , codelistFlag)
	} else {
	}
))
}