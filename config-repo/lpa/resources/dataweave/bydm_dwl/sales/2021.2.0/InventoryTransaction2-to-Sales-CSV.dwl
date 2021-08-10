%dw 2.0
@StreamCapable()
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
fun filterTransCode(transactionCode: String) =
  arrTransCodes contains transactionCode

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
Sales: {
	((payload filter (() -> $."documentActionCode" != "DELETE" )) map ((item, index) -> 
      Record: if (filterTransCode(item."transactionCode" default "")) {
		ProductID: if ( item.itemId != null ) item.itemId
          else null,
		LocationID: if ( item.locationId != null ) item.locationId
          else null,
		Type: codeListSalesTypeCode(item.transactionCode, codelistFlag),
		Quantity: item."quantity.value" default "5",
		UnitID: codeListItemTypeCode(item."quantity.measurementUnitCode", codelistFlag),
		ValidDay: item.startDate default "",
		LastSoldTimestamp: if ( item.lastSoldDateTime != "" and item.lastSoldDateTime != null ) item.lastSoldDateTime
          else null,
		Turnover: if ( item."totalRetailAmountWithTaxes.value" != "" and item."totalRetailAmountWithTaxes.value" != null ) item."totalRetailAmountWithTaxes.value" as Number {
			format: "##.0000"
		}
          else null,
		TurnoverNotax: if ( item."totalRetailAmount.value" != "" and item."totalRetailAmount.value" != null ) item."totalRetailAmount.value" as Number {
			format: "##.0000"
		}
          else null,
		Currency: if ( item."totalRetailAmount.currencyCode" != "" and item."totalRetailAmount.currencyCode" != null ) item."totalRetailAmount.currencyCode"
          else if ( item."totalRetailAmountWithTaxes.currencyCode" != "" ) item."totalRetailAmountWithTaxes.currencyCode"
          else "USD"
	} else {
		ProductID: "",
		LocationID: "",
		Type: "",
		Quantity: "",
		UnitID: "",
		ValidDay: ""
	}
    ))
}
