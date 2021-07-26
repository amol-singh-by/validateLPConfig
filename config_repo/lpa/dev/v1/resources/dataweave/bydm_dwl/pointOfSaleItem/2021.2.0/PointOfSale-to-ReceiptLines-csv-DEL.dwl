%dw 2.0
@StreamCapable()
import * from dw::Runtime
output application/xml deferred = true, skipNullOn = "everywhere"
//Force Delete
var documentActionCode = 'DELETE'
var codelistFlag = Mule::p('bydm.canmodel.codeList')
fun codeListItemTypeCode(value, codelistFlag) = codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value) 
						  else ''
    else ->  try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

fun tranformDeleteRecord(receiptLine) = DeleteRecord : {
    ReceiptID : receiptLine.pOSId default ""
}

---
ReceiptLines : 
({( (payload filter ($.documentActionCode != "DELETE" ) map (receiptLine) -> {
    (tranformDeleteRecord(receiptLine))
})) })