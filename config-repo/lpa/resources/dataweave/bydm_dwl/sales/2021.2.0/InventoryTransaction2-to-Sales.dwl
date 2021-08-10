%dw 2.0
import * from dw::Runtime
fun trimValues(value) =
  value match {
	case is Array -> value map (trimValues($))
    case is Object -> value mapObject {
		($$): trimValues($)
	}
    case is String -> trim($)
    else -> $
}

var arrTransCodes = trimValues(Mule::p('transactionCodes') as String splitBy (","))

// This function intends to filter out the values that, if sent, might fail within the LP system
fun filterTransCode(transactionCode: String) = arrTransCodes contains transactionCode

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemTypeCode(value, codelistFlag) =
  codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, 'PCS')
    else ''
    else -> try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, 'PCS')) match {
		case theOutput if(theOutput.success ~= false) -> value
	else -> $.result
	}
}

fun codeListSalesTypeCode(value, codelistFlag) =
  codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.SalesTypeCode, "SalesTypeCode", value, value)
    else ''
    else -> try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.SalesTypeCode, "SalesTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

output application/xml deferred = true, skipNullOn = "everywhere"

---
Sales: {(payload[vars.bulkType] filter($.documentActionCode != "DELETE") map ((item, index) -> {
			Record: if(filterTransCode(item.transactionCode default "")) {
				ProductID: if ( item.itemId != null ) item.itemId
          				else "",
				LocationID: if ( item.locationId != null ) item.locationId
          				else "",
				Type: codeListSalesTypeCode(item.transactionCode, codelistFlag),
				Quantity: if ( item.quantity != null and item.quantity.value != null ) item.quantity.value
          				else "",
				UnitID: codeListItemTypeCode(item.quantity.measurementUnitCode, codelistFlag),
				ValidDay: if(!isEmpty(item.startDate))(item.startDate replace "Z" with "") else "",
				LastSoldTimestamp: if ( item.lastSoldDateTime != null and item.lastSoldDateTime != "" ) item.lastSoldDateTime
          				else null,
				Turnover: if ( item.totalRetailAmountWithTaxes.value != null and item.totalRetailAmountWithTaxes.value != "") item.totalRetailAmountWithTaxes.value
          				else null,
				TurnoverNotax: if ( item.totalRetailAmount.value != null and item.totalRetailAmount.value != "" ) item.totalRetailAmount.value
          				else null,
				Currency: if ( item.totalRetailAmount.currencyCode != null and item.totalRetailAmount.currencyCode != "" ) item.totalRetailAmount.currencyCode
          				else "USD"
			} else {
				ProductID: "",
				LocationID: "",
				Type: "",
				Quantity: "",
				UnitID: "",
				ValidDay: ""
			}
}))}