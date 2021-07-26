%dw 2.0
@StreamCapable()
import * from dw::Runtime
output application/xml  deferred = true, skipNullOn = "everywhere"

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemTypeCode(value) = codelistFlag match {
    case str: "ERROR" -> if((value) != null) 
							jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value) 
						  else ''
    else ->  try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

fun getOperationType(documentActionCode) =
	if(documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH") "Record"
	else if(documentActionCode == "DELETE") "DeleteRecord"
	else "Record"

---
"PurchaseGroupVendorMinimums": {
	(payload map ((og , index) -> {
		(if ( getOperationType(og.documentActionCode) as String == "Record" ) "Record" : {
	    	"PurchaseGroupID" : if (!isEmpty(og."orderGroupId")) (og."orderGroupId") else '',
			"UnitID" : codeListItemTypeCode(og."orderGroupSupplierConstraint.measurementUnitCode"),
			("Currency" : og."orderGroupSupplierConstraint.currencyCode") if (!isEmpty(og."orderGroupSupplierConstraint.currencyCode")),
			"MinValue" : if (!isEmpty(og."orderGroupSupplierConstraint.minimumAllowableValue")) (og."orderGroupSupplierConstraint.minimumAllowableValue") else '',
		}
		else{
		}),
		(if ( getOperationType(og.documentActionCode) as String == "Record" ) "Record" : {
	    	"PurchaseGroupID" : if (!isEmpty(og."orderGroupId")) (og."orderGroupId") else '',
			("PurchaseSubGroup" : og."orderGroupMemberDetail.orderGroupMemberId") if (!isEmpty(og."orderGroupMemberDetail.orderGroupMemberId")),
			"UnitID" : codeListItemTypeCode(og."orderGroupMemberDetail.orderGroupMemberSupplierConstraint.measurementUnitCode"),
			("Currency" : og."orderGroupMemberDetail.orderGroupMemberSupplierConstraint.currencyCode") if (!isEmpty(og."orderGroupMemberDetail.orderGroupMemberSupplierConstraint.currencyCode")),
			"MinValue" : if (!isEmpty(og."orderGroupMemberDetail.orderGroupMemberSupplierConstraint.minimumAllowableValue")) (og."orderGroupMemberDetail.orderGroupMemberSupplierConstraint.minimumAllowableValue") else '',
		}
		else{
		})
	}))
}