%dw 2.0
import * from dw::Runtime
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

output application/xml deferred = true, skipNullOn = "everywhere"
---
"PurchaseGroupVendorMinimums": {(
    (payload[vars.bulkType] map(og,index) -> {
        (og.orderGroupSupplierConstraint map (ogsc,index) -> {
            (if ( getOperationType(og.documentActionCode) as String == "Record" ) "Record":{
                "PurchaseGroupID" : if (!isEmpty(og.orderGroupId)) (og.orderGroupId) else '',
				"UnitID" : codeListItemTypeCode(ogsc.measurementUnitCode),
				("Currency" : ogsc.currencyCode) if (!isEmpty(ogsc.currencyCode)),
				"MinValue" : if (!isEmpty(ogsc.minimumAllowableValue)) (ogsc.minimumAllowableValue) else ''
            }
            else{
            })
        }),
		(og.orderGroupMemberDetail map (ogmd,index) -> {
            (if ( getOperationType(og.documentActionCode) as String == "Record" ) "Record":{
               "PurchaseGroupID" : if (!isEmpty(og.orderGroupId)) (og.orderGroupId) else '',
				("PurchaseSubGroup" : ogmd.orderGroupMemberId) if (!isEmpty(ogmd.orderGroupMemberId)),
				("UnitID" : codeListItemTypeCode(ogmd.orderGroupMemberSupplierConstraint.measurementUnitCode[0])) if (ogmd.orderGroupMemberSupplierConstraint.measurementUnitCode != null),
				("Currency" : ogmd.orderGroupMemberSupplierConstraint.currencyCode) if (!isEmpty(ogmd.orderGroupMemberSupplierConstraint.currencyCode)),
            	"MinValue" : if (!isEmpty(ogmd.orderGroupMemberSupplierConstraint.minimumAllowableValue)) (ogmd.orderGroupMemberSupplierConstraint.minimumAllowableValue) else ''
            }
            else{
            })
        })
    })
 )}