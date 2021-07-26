%dw 2.0
@StreamCapable()
import * from dw::Runtime
output application/xml deferred = true, skipNullOn = "everywhere"

var codelistFlag = Mule::p('bydm.canmodel.codeList')
fun codeListItemTypeCode(value, codelistFlag) = codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value) 
						  else ''
    else ->  try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

fun tranformReceiptLines(receiptLine) =
    if ( receiptLine.documentActionCode == "ADD" or receiptLine.documentActionCode == "CHANGE_BY_REFRESH" ) tranformRecord(receiptLine)
   	else if ( receiptLine.documentActionCode == "DELETE" ) tranformDeleteRecord(receiptLine)
   	else tranformRecord(receiptLine)

fun tranformDeleteRecord(receiptLine) = DeleteRecord : {
    ReceiptID : receiptLine.pOSId default ""
}
fun tranformRecord(receiptLine) = Record : {
    ReceiptID : receiptLine.pOSId default "",
    LocationID: receiptLine.locationId default "",
    (ProductID : receiptLine.itemId) if !isBlank(receiptLine.itemId),
    (CommonPromotionID : receiptLine.promotionID) if !isBlank(receiptLine.promotionID),
    (CustomerID : receiptLine.customerId) if !isBlank(receiptLine.promotionID),
    Type : receiptLine.pOSLineTypeCode default "",
    TransactionTimestamp: receiptLine.transactionDateTime default "",
    (Quantity : receiptLine."quantity.value") if !isEmpty(receiptLine."quantity.value"),
    (UnitID : codeListItemTypeCode(receiptLine."quantity.measurementUnitCode", codelistFlag)) if !isBlank(receiptLine."quantity.measurementUnitCode"),
    (Turnover : receiptLine."amountWithTax.value") if !isBlank(receiptLine."amountWithTax.value"),
    (Currency : receiptLine."amountWithTax.currencyCode") if !isBlank(receiptLine."amountWithTax.currencyCode")
}


---
ReceiptLines : 
({( (payload map (receiptLine) -> {
    (tranformReceiptLines(receiptLine))
})) })