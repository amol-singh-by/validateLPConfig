%dw 2.0
@StreamCapable()
output application/xml deferred = true, skipNullOn = "everywhere"
import * from dw::Runtime

fun checkHistoricalOrderCount(count) = try(() -> (count as Number) > 0) match {
    case theOutput if(theOutput.success ~= false) -> false
else -> $.result
}

---
"AutoApprovalRules": {(payload[vars.bulkType] filter($.documentActionCode != "DELETE") map ((aar , index) -> {
	"Record" : {
		"AutoApprovalRuleID" : if (!isEmpty(aar.autoApprovalRuleId)) (aar.autoApprovalRuleId) else '',
		("Description" : aar.autoApprovalRuleDescription) if (!isEmpty(aar.autoApprovalRuleDescription)),
		("AdditionalCoverageDuration" : aar.maximumOptimizationDuration) if (!isEmpty(aar.maximumOptimizationDuration)),
		("MaxVehicleLoadCount" : aar.maximumVehicleLoadCount) if (!isEmpty(aar.maximumVehicleLoadCount)),
		"UnitID" : if (checkHistoricalOrderCount(aar.historicalOrderCount) and !isEmpty(aar.historicalOrderBasedThresholdParameters.measurementUnitCode)) aar.historicalOrderBasedThresholdParameters.measurementUnitCode else null,
		"Currency" : if (checkHistoricalOrderCount(aar.historicalOrderCount) and !isEmpty(aar.historicalOrderBasedThresholdParameters.currencyCode)) aar.historicalOrderBasedThresholdParameters.currencyCode else null,
		("HistoricalOrderCount" : aar.historicalOrderCount) if (!isEmpty(aar.historicalOrderCount)),
		("LowerThreshold" : aar.historicalOrderBasedThresholdParameters.minimumThresholdPercentage) if (!isEmpty(aar.historicalOrderBasedThresholdParameters.minimumThresholdPercentage)),
		("UpperThreshold" : aar.historicalOrderBasedThresholdParameters.maximumThresholdPercentage) if (!isEmpty(aar.historicalOrderBasedThresholdParameters.maximumThresholdPercentage))
		
	}
}))}
