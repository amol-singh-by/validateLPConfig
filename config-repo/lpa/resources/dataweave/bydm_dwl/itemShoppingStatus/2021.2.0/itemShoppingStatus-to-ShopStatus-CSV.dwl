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

var entityDatePolicy = (vars.entityConfig.targetEntities filter $.name == vars.fullLPEntityName)[0].datePolicy
var entityIncrementalDate = (vars.entityConfig.targetEntities filter $.name == vars.fullLPEntityName)[0].incrementalDate

var defaultFromDateTime =  if (p("useGlobalDatePolicy.value")) 
	(if (p("useGlobalDatePolicy.datePolicy") == "NEXT_DAY") 
								(now() as DateTime) + ("P" ++ (p("useGlobalDatePolicy.incrementalDate") default 0) as String ++ "D") as Period
					  		else (now() as DateTime))

else if (!p("useGlobalDatePolicy.value")) 
	(if (entityDatePolicy == "NEXT_DAY") 
								(now() as DateTime) + ("P" ++ (entityIncrementalDate default 0) as String ++ "D") as Period
					  		else (now() as DateTime))

else ""

fun validateDate(date) = try(() -> date as DateTime) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
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
			else defaultFromDateTime,
			"ActiveUpTo": if(item.effectiveUpToDateTime != null and item.effectiveUpToDateTime != "") validateDate(item.effectiveUpToDateTime)
			else "9999-12-31T00:00:00+00:00"
		}
else if ( getOperationType(item.documentActionCode) == "DeleteRecord" and (item."itemShoppingStatusId.locationId" == "DELETE_ALL" or item."itemShoppingStatusId.itemId" == "DELETE_ALL") ) "DeleteAllRecords": {
			"LocationID": if ( item."itemShoppingStatusId.locationId" != null ) item."itemShoppingStatusId.locationId" else "",
			"ProductID": item."itemShoppingStatusId.itemId" default "",
			"ActiveFrom": if(item."itemShoppingStatusId.effectiveFromDateTime" != null and item."itemShoppingStatusId.effectiveFromDateTime" != "") item."itemShoppingStatusId.effectiveFromDateTime" 
			else defaultFromDateTime,
			"ActiveUpTo": if(item.effectiveUpToDateTime != null and item.effectiveUpToDateTime != "") validateDate(item.effectiveUpToDateTime)
			else "9999-12-31T00:00:00+00:00"
		}
else if ( getOperationType(item.documentActionCode) == "DeleteRecord" ) (getOperationType(item.documentActionCode)) : {
			"LocationID": if ( item."itemShoppingStatusId.locationId" != null ) item."itemShoppingStatusId.locationId" else "",
			"ProductID": item."itemShoppingStatusId.itemId" default "",
			"Availability": codeListItemShoppingStatusTypeCode(item.availabilityTypeCode, codelistFlag),
			"ActiveFrom": if(item."itemShoppingStatusId.effectiveFromDateTime" != null and item."itemShoppingStatusId.effectiveFromDateTime" != "") item."itemShoppingStatusId.effectiveFromDateTime" 
			else defaultFromDateTime,
			"ActiveUpTo": if(item.effectiveUpToDateTime != null and item.effectiveUpToDateTime != "") validateDate(item.effectiveUpToDateTime)
			else "9999-12-31T00:00:00+00:00"
		}
else {
		}
	))
})
