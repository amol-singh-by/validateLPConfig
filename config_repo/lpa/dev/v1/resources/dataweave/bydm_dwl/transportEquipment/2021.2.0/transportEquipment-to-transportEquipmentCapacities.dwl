%dw 2.0
output application/xml deferred = true, skipNullOn = "everywhere"

fun getOperationType(documentActionCode) =
	if(documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH") "Record"
	else if(documentActionCode == "DELETE") "DeleteRecord"
	else "Record"
---
"TransportEquipmentCapacities": {(
    (payload[vars.bulkType] map(te,index) -> {
        (te.usageThresholdValues map (utv,index) -> {
            (if ( getOperationType(te.documentActionCode) as String == "Record" ) "Record":{
                TransportEquipmentID : if (!isEmpty(te.transportEquipmentId)) (te.transportEquipmentId) else '',
                (UnitID : utv.measurementUnitCode) if !isEmpty(utv.measurementUnitCode),
                (Currency : utv.currencyCode) if !isEmpty(utv.currencyCode),
                MinCapacity :  if (!isEmpty(utv.minimumAllowableValue)) (utv.minimumAllowableValue) else '',
                MaxCapacity :  if (!isEmpty(utv.maximumAllowableValue)) (utv.maximumAllowableValue) else '',
                IsHardConstraint :  if (!isEmpty(utv.isHardConstraint)) (utv.isHardConstraint) else ''
            }
            else{
            })
        })
    })
 )}