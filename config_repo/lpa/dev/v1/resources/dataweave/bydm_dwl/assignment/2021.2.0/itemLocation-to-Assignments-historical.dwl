%dw 2.0
import * from dw::Runtime

fun getOperationType(parent, child) =
	if ( parent.documentActionCode != "DELETE" )
		if (child.actionCode == "ADD" or child.actionCode == "CHANGE") "Record"
		else if (child.actionCode == "DELETE") "DeleteRecord"
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

output application/xml deferred = true, skipNullOn = "everywhere"
---
Assignments: {
	((payload[vars.bulkType] filter (() -> (($.includesAvailability default 'false') ~= 'true'))) map (item, index) -> {
		(item.availability map (avail,index) ->
	        (getOperationType(item, avail)): {
			"ProductID": if ( item.itemLocationId.item.primaryId != null ) item.itemLocationId.item.primaryId else "",
			"LocationID": if ( item.itemLocationId.location.primaryId != null ) item.itemLocationId.location.primaryId else "",
			"Type": codeListItemLocationTypeCode(avail."type", codelistFlag),
			"ActiveFrom": if (!isEmpty(avail.effectiveFromDate)) avail.effectiveFromDate else "1970-01-01",
			"ActiveUpTo": if (!isEmpty(avail.effectiveUpToDate)) avail.effectiveUpToDate else "9999-12-31"
		})
	})
}

