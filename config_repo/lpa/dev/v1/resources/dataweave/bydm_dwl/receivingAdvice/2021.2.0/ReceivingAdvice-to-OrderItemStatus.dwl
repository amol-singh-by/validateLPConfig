%dw 2.0
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

output application/xml deferred = true, skipNullOn = "everywhere"
---
OrderItemStatus: {
	(payload[vars.bulkType] filter ($.documentActionCode != "DELETE") map((receivingAdvice,receivingAdviceIndex) -> {
		(receivingAdvice.receivingAdviceLogisticUnit map ((receivingAdviceLU, receivingAdviceLUIndex) ->
    	{
			(receivingAdviceLU.lineItem map ((LI, LIIndex) ->
            Record: {
				OrderID: if ( LI.purchaseOrder.entityId != null ) LI.purchaseOrder.entityId else "",
				Position: if ( LI.purchaseOrder.lineItemNumber != null ) LI.purchaseOrder.lineItemNumber else "",
				Type: "ARRIVED",
				StatusTime: if ( receivingAdvice.receivingDateTime != null ) receivingAdvice.receivingDateTime else "",
				Quantity: if ( LI.quantityReceived.value != null ) LI.quantityReceived.value else "",
				UnitID: codeListItemTypeCode(LI.quantityReceived.measurementUnitCode, codelistFlag)
			}        
         ))
		}
		))
	}   
))
}
