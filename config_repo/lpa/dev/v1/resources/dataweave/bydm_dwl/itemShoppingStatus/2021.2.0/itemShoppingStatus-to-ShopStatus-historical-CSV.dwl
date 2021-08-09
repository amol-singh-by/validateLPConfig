%dw 2.0
import * from dw::Runtime
@StreamCapable()

fun getOperationType(documentActionCode) =
  if ( documentActionCode == "DELETE" ) "DeleteRecord"
  else "Record"
 
var codelistFlag = Mule::p('bydm.canmodel.codeList')
 
fun codeListItemShoppingStatusTypeCode(value, codelistFlag) =
  codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemShoppingStatusTypeCode, "ItemShoppingStatusTypeCode", value, value)
    else ''
    else -> try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemShoppingStatusTypeCode, "ItemShoppingStatusTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
		else -> $.result
	}
}


output application/xml  deferred = true, skipNullOn = "everywhere"
---
ShopStatus: ({
	(payload map ((item, index) -> 
if ( getOperationType(item.documentActionCode) == "Record" ) (getOperationType(item.documentActionCode)) : {
			"LocationID": if ( item."itemShoppingStatusId.locationId" != null ) item."itemShoppingStatusId.locationId" else "",
			"ProductID": item."itemShoppingStatusId.itemId" default "",
			"Availability": codeListItemShoppingStatusTypeCode(item.availabilityTypeCode, codelistFlag),
			"PriceInShop": if ( item."price.value" != null ) item."price.value" else null,
			"Currency": if ( item."price.currencyCode" != null ) item."price.currencyCode" else null,
			"ActiveFrom": if(item."itemShoppingStatusId.effectiveFromDateTime" != null and item."itemShoppingStatusId.effectiveFromDateTime" != "") item."itemShoppingStatusId.effectiveFromDateTime" 
			else "1970-01-01T00:00:00+00:00",
			"ActiveUpTo": if(item.effectiveUpToDateTime != null and item.effectiveUpToDateTime != "") item.effectiveUpToDateTime
			else "9999-12-31T00:00:00+00:00"
		}
else if ( getOperationType(item.documentActionCode) == "DeleteRecord" and (item."itemShoppingStatusId.locationId" == "DELETE_ALL" or item."itemShoppingStatusId.itemId" == "DELETE_ALL") ) "DeleteAllRecords": {
			"LocationID": if ( item."itemShoppingStatusId.locationId" != null ) item."itemShoppingStatusId.locationId" else "",
			"ProductID": item."itemShoppingStatusId.itemId" default "",
			"ActiveFrom": if(item."itemShoppingStatusId.effectiveFromDateTime" != null and item."itemShoppingStatusId.effectiveFromDateTime" != "") item."itemShoppingStatusId.effectiveFromDateTime" 
			else "1970-01-01T00:00:00+00:00",
			"ActiveUpTo": if(item.effectiveUpToDateTime != null and item.effectiveUpToDateTime != "") item.effectiveUpToDateTime
			else "9999-12-31T00:00:00+00:00"
		}
else if ( getOperationType(item.documentActionCode) == "DeleteRecord" ) (getOperationType(item.documentActionCode)) : {
			"LocationID": if ( item."itemShoppingStatusId.locationId" != null ) item."itemShoppingStatusId.locationId" else "",
			"ProductID": item."itemShoppingStatusId.itemId" default "",
			"Availability": codeListItemShoppingStatusTypeCode(item.availabilityTypeCode, codelistFlag),
			"ActiveFrom": if(item."itemShoppingStatusId.effectiveFromDateTime" != null and item."itemShoppingStatusId.effectiveFromDateTime" != "") item."itemShoppingStatusId.effectiveFromDateTime" 
			else "1970-01-01T00:00:00+00:00",
			"ActiveUpTo": if(item.effectiveUpToDateTime != null and item.effectiveUpToDateTime != "") item.effectiveUpToDateTime
			else "9999-12-31T00:00:00+00:00"
		}
else {
		}
	))
})
