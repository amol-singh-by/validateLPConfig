%dw 2.0
output application/xml deferred = true, skipNullOn = "everywhere"

fun getOperationType(documentActionCode) =
	if(documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH") "Record"
	else if(documentActionCode == "DELETE") "DeleteRecord"
	else "Record"
---
"AutoApprovalExceptions": {(
    (payload[vars.bulkType] map(aae,index) -> {
            (if ( getOperationType(aae.documentActionCode) as String == "Record" ) "Record":{
                "AutoApprovalRuleID" : if (!isEmpty(aae.autoApprovalExceptionId)) (aae.autoApprovalExceptionId) else "",
				"ExceptionNumber" : if (!isEmpty(aae.exceptionCode)) (aae.exceptionCode) else ""
            }
			else{
            })
    })
 )}