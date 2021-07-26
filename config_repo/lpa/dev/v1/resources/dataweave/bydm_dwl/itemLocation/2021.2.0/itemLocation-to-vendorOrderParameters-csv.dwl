%dw 2.0
@StreamCapable()
output application/xml deferred = true, skipNullOn = "everywhere"
import * from dw::Runtime

var codelistFlag = Mule::p('bydm.canmodel.codeList')
fun codeListItemTypeCode(value, codelistFlag) = codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value) 
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
"VendorOrderParameters": ({
	((payload filter(()-> $.includesVendorOrderParameters default false)) map ((il, index) -> 
	if ( getOperationType(il.documentActionCode) as String == "Record" ) "Record" : {
			"ProductID": if ( !isEmpty(il."itemLocationId.item.primaryId") ) (il."itemLocationId.item.primaryId") else '',
			"LocationID": if ( !isEmpty(il."itemLocationId.location.primaryId") ) (il."itemLocationId.location.primaryId") else '',
			("DesiredCoverageDuration": il."planningParameters.receiptCoverageDuration.value") if (!isEmpty(il."planningParameters.receiptCoverageDuration.value")),
			("MaxCoverageDuration": il."planningParameters.maximumRetentionDuration.value") if (!isEmpty(il."planningParameters.maximumRetentionDuration.value")),
			("Currency": il."demandParameters.unitCost.currencyCode") if (!isEmpty(il."demandParameters.unitCost.currencyCode")),
			("UnitCost": il."demandParameters.unitCost.value") if (!isEmpty(il."demandParameters.unitCost.value")),
			("TargetServiceLevel": il."safetyStockParameters.safetyStockCustomerServiceLevel") if (!isEmpty(il."safetyStockParameters.safetyStockCustomerServiceLevel")),
			("MinSafetyStockQuantity": il."safetyStockParameters.minimumSafetyStock.value") if (!isEmpty(il."safetyStockParameters.minimumSafetyStock.value")),
			("MaxSafetyStockQuantity": il."safetyStockParameters.maximumSafetyStock.value") if (!isEmpty(il."safetyStockParameters.maximumSafetyStock.value")),
			UnitID: codeListItemTypeCode(il."safetyStockParameters.maximumSafetyStock.measurementUnitCode", codelistFlag)
		}
		else {
		}
	))
})