%dw 2.0
output application/xml deferred = true, skipNullOn = "everywhere"
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

---

"VendorOrderParameters": {(
    ((payload[vars.bulkType] filter (() -> (($.includesVendorOrderParameters default 'false') ~= 'true'))) map (item, index) -> {
            (if ( getOperationType(item.documentActionCode) as String == "Record" ) "Record":{
                "ProductID" : if (!isEmpty(item.itemLocationId.item.primaryId)) (item.itemLocationId.item.primaryId) else '',
				"LocationID" : if (!isEmpty(item.itemLocationId.location.primaryId)) (item.itemLocationId.location.primaryId) else '',
				("DesiredCoverageDuration" : item.planningParameters.receiptCoverageDuration.value) if (!isEmpty(item.planningParameters.receiptCoverageDuration.value)),
				("MaxCoverageDuration" : item.planningParameters.maximumRetentionDuration.value) if (!isEmpty(item.planningParameters.maximumRetentionDuration.value)),
				("Currency" : item.demandParameters.unitCost.currencyCode) if (!isEmpty(item.demandParameters.unitCost.currencyCode)),
				("UnitCost" : item.demandParameters.unitCost.value) if (!isEmpty(item.demandParameters.unitCost.value)),
				("TargetServiceLevel" : item.safetyStockParameters.safetyStockCustomerServiceLevel) if (!isEmpty(item.safetyStockParameters.safetyStockCustomerServiceLevel)),
				("MinSafetyStockQuantity" : item.safetyStockParameters.minimumSafetyStock.value) if (!isEmpty(item.safetyStockParameters.minimumSafetyStock.value)),
				("MaxSafetyStockQuantity" : item.safetyStockParameters.maximumSafetyStock.value) if (!isEmpty(item.safetyStockParameters.maximumSafetyStock.value)),
				"UnitID": codeListItemTypeCode(item.safetyStockParameters.maximumSafetyStock.measurementUnitCode)
            }
			else{
            })
    })
 )}
