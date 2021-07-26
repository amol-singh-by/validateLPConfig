%dw 2.0
@StreamCapable()
output application/xml  deferred = true, skipNullOn = "everywhere"

fun transformRoundingRule(receiptLine) =
    if ( receiptLine.documentActionCode == "ADD" or receiptLine.documentActionCode == "CHANGE_BY_REFRESH" ) tranformRecord(receiptLine)
   	else if ( receiptLine.documentActionCode == "DELETE" ) tranformDeleteRecord(receiptLine)
   	else tranformRecord(receiptLine)

fun tranformDeleteRecord(roundingRule) = DeleteRecord : {
            RoundingRuleID : if (!isEmpty(roundingRule.'roundingRuleId')) (roundingRule.'roundingRuleId') else '',
            DesiredShipQuantity :  if (!isEmpty(roundingRule.'desiredShipQuantities.desiredShipQuantity')) (roundingRule.'desiredShipQuantities.desiredShipQuantity') else '',
        }

fun tranformRecord(roundingRule) = Record : {
            RoundingRuleID : if (!isEmpty(roundingRule.'roundingRuleId')) (roundingRule.'roundingRuleId') else '',
            DesiredShipQuantity :  if (!isEmpty(roundingRule.'desiredShipQuantities.desiredShipQuantity')) (roundingRule.'desiredShipQuantities.desiredShipQuantity') else '',
            (Description : roundingRule.'description') if !isEmpty(roundingRule.'description'),
            RoundDownFactor : if (!isEmpty(roundingRule.'desiredShipQuantities.roundingUpFactor')) (roundingRule.'desiredShipQuantities.roundingUpFactor')  else '',
            RoundUpFactor : if (!isEmpty(roundingRule.'desiredShipQuantities.roundDownFactor')) (roundingRule.'desiredShipQuantities.roundDownFactor') else ''
        }

---
ShipQuantityRoundingRules : {
    (payload map (roundingRule) -> {
        (transformRoundingRule(roundingRule))
    })
}