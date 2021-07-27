%dw 2.0
@StreamCapable()
output application/xml  deferred = true, skipNullOn = "everywhere"

fun getOperationType(documentActionCode) =
	if(documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH") "Record"
	else if(documentActionCode == "DELETE") "DeleteRecord"
	else "Record"
---
"TransportEquipmentCapacities": ({
	(payload map ((te, index) -> 
	if ( getOperationType(te.documentActionCode) as String == "Record" ) "Record" : {
			"TransportEquipmentID" : if (!isEmpty(te."transportEquipmentId")) (te."transportEquipmentId") else '',
			("UnitID" : te."usageThresholdValues.measurementUnitCode") if !isEmpty(te."usageThresholdValues.measurementUnitCode"),
			("Currency" : te."usageThresholdValues.currencyCode") if !isEmpty(te."usageThresholdValues.currencyCode"),
			"MinCapacity" :  if (!isEmpty(te."usageThresholdValues.minimumAllowableValue")) (te."usageThresholdValues.minimumAllowableValue") else '',
			"MaxCapacity" :  if (!isEmpty(te."usageThresholdValues.maximumAllowableValue")) (te."usageThresholdValues.maximumAllowableValue") else '',
			"IsHardConstraint" :  if (!isEmpty(te."usageThresholdValues.isHardConstraint")) (te."usageThresholdValues.isHardConstraint") else ''
		}
	else {
		}
	))
})
