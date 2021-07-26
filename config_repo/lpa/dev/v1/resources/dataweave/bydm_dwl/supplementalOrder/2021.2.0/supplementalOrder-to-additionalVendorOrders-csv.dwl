%dw 2.0
@StreamCapable()
import * from dw::Runtime
output application/xml  deferred = true, skipNullOn = "everywhere"

fun validateDateFormat(str) = try(() -> str as Date) match {
    case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

fun getOperationType(documentActionCode) =
	if(documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH") "Record"
	else if(documentActionCode == "DELETE") "DeleteRecord"
	else "Record"

---
"AdditionalVendorOrders": ({
	(payload map ((so, index) -> 
	if (getOperationType(so.documentActionCode) == "Record") "Record" : {
			"ProductID" : if (!isEmpty(so."supplementalOrderId.itemLocationId.item.primaryId")) (so."supplementalOrderId.itemLocationId.item.primaryId") else '',
			"LocationID" : if (!isEmpty(so."supplementalOrderId.itemLocationId.location.primaryId")) (so."supplementalOrderId.itemLocationId.location.primaryId") else '',
			"AdditionalOrderID" : if (!isEmpty(so."supplementalOrderId.additionalOrderId")) so."supplementalOrderId.additionalOrderId" else '',
			"RequestedArrivalDate" : if (!isEmpty(so."supplementalOrderId.requestedDeliveryDate")) (validateDateFormat(so."supplementalOrderId.requestedDeliveryDate")) else '',
			"RequestedQuantity" : if (!isEmpty(so."requestedQuantity.value")) so."requestedQuantity.value" else '',
			("HoldoutReleaseDate" : validateDateFormat(so."inventoryHoldReleaseDate")) if (!isEmpty(so."inventoryHoldReleaseDate")),
			("GroupOrderType" : so."groupOrderType") if (!isEmpty(so."groupOrderType")),
			("OrderType" : so."supplementalOrderType") if (!isEmpty(so."supplementalOrderType"))
		}
		else {
		}
	))
})