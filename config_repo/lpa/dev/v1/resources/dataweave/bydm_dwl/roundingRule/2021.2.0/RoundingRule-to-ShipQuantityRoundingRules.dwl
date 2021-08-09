%dw 2.0
output application/xml deferred = true, skipNullOn = "everywhere"

fun transformRoundingRule(receiptLine) =
    if ( receiptLine.documentActionCode == "ADD" or receiptLine.documentActionCode == "CHANGE_BY_REFRESH" ) tranformRecord(receiptLine)
   	else if ( receiptLine.documentActionCode == "DELETE" ) tranformDeleteRecord(receiptLine)
   	else tranformRecord(receiptLine)

fun tranformDeleteRecord(roundingRule) = DeleteRecord : {
             RoundingRuleID : if (!isEmpty(roundingRule.roundingRuleId)) (roundingRule.roundingRuleId) else '',
            DesiredShipQuantity :  if (!isEmpty(roundingRule.desiredShipQuantities.desiredShipQuantity)) (roundingRule.desiredShipQuantities[0].desiredShipQuantity) else ''
            }

fun tranformRecord(roundingRule) = Record : {
            RoundingRuleID : if (!isEmpty(roundingRule.roundingRuleId)) (roundingRule.roundingRuleId) else '',
            DesiredShipQuantity :  if (!isEmpty(roundingRule.desiredShipQuantities.desiredShipQuantity)) (roundingRule.desiredShipQuantities[0].desiredShipQuantity) else '',
            (Description : roundingRule.description) if !isEmpty(roundingRule.description),
            RoundDownFactor : if (!isEmpty(roundingRule.desiredShipQuantities.roundingUpFactor)) (roundingRule.desiredShipQuantities[0].roundingUpFactor)  else '',
            RoundUpFactor : if (!isEmpty(roundingRule.desiredShipQuantities.roundDownFactor)) (roundingRule.desiredShipQuantities[0].roundDownFactor) else ''
        }
---
ShipQuantityRoundingRules : {(payload[vars.bulkType] map (roundingRule) -> {
        (transformRoundingRule(roundingRule))
    })}