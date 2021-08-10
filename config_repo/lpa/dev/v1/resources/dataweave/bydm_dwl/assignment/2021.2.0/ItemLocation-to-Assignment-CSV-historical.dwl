%dw 2.0
import * from dw::Runtime
@StreamCapable()

fun getOperationType(parent, child) =
	if ( parent.documentActionCode != "DELETE" )
		if (child."availability.actionCode" == "ADD" or child."availability.actionCode" == "CHANGE") "Record"
		else if (child."availability.actionCode" == "DELETE") "DeleteRecord"
		else "Record"
	else "DeleteRecord"

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemLocationTypeCode(value, codelistFlag) =
  codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupOptional(vars.codeMap.ItemLocationTypeCode, "ItemLocationTypeCode", value default "")
    else ''
    else -> try(() -> jda::CodeMap::keyLookupOptional(vars.codeMap.ItemLocationTypeCode, "ItemLocationTypeCode", value default "")) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

output application/xml deferred = true, skipNullOn="everywhere"
---
Assignments: ({
	((payload filter(()-> $.includesAvailability default false)) map (item,index) -> (getOperationType(item, item)): {
		"ProductID": if ( item."itemLocationId.item.primaryId" != null ) item."itemLocationId.item.primaryId" else "",
		"LocationID": if ( item."itemLocationId.location.primaryId" != null ) item."itemLocationId.location.primaryId" else "",
		"Type": codeListItemLocationTypeCode(item."availability.type", codelistFlag),
		"ActiveFrom": if (!isEmpty(item."availability.effectiveFromDate")) item."availability.effectiveFromDate" else "1970-01-01",
		"ActiveUpTo": if (!isEmpty(item."availability.effectiveUpToDate")) item."availability.effectiveUpToDate" else "9999-12-31"
	})
})
