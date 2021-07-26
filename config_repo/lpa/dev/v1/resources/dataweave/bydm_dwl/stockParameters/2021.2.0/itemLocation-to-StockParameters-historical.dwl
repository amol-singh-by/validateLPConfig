%dw 2.0
import * from dw::Runtime

fun getOperationType(documentActionCode) =
    if ( documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH" ) "Record"
   	else if ( documentActionCode == "DELETE" ) "DeleteRecord"
    else "Record"

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemTypeCode(value) = codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value) 
						  else ''
    else ->  try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}
fun codeListTimeMeasurementTypeCode(value) = codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.TimeMeasurementTypeCode, "TimeMeasurementTypeCode", value, value) 
						  else ''
    else ->  try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.TimeMeasurementTypeCode, "TimeMeasurementTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
StockParameters: {((payload[vars.bulkType] filter (() -> (($.includesStockParameters default 'false') ~= 'true'))) map () -> 
        (getOperationType($.documentActionCode)): 
          if ( $.documentActionCode != "DELETE" ) {
	"ProductID": if ($.itemLocationId.item.primaryId != null ) $.itemLocationId.item.primaryId
                else "",
	"LocationID": if ($.itemLocationId.location.primaryId != null ) $.itemLocationId.location.primaryId
                else "",
	"UnitID": codeListItemTypeCode($.effectiveInventoryParameters[0].minimumSafetyStockQuantity.measurementUnitCode),
	"MinQuantity": if ($.effectiveInventoryParameters.minimumSafetyStockQuantity.value != null and $.effectiveInventoryParameters.minimumSafetyStockQuantity.value != "" ) $.effectiveInventoryParameters.minimumSafetyStockQuantity.value
                else null,
	"MaxQuantity": if ($.planningParameters.maximumOnHandQuantity.value != null and $.planningParameters.maximumOnHandQuantity.value != "" ) $.planningParameters.maximumOnHandQuantity.value
                else null,
	"MinNumberExpirationDays": if ( $.perishableParameters.minimumShelfLifeDuration.value != null and $.perishableParameters.minimumShelfLifeDuration.value != "" ) (codeListTimeMeasurementTypeCode($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode) as Number * $.perishableParameters.minimumShelfLifeDuration.value as Number)
                else null,
	"ActiveFrom": if ($.effectiveFromDate != null and $.effectiveFromDate != "") $.effectiveFromDate 
                else "1970-01-01",
	"ActiveUpTo": if ($.effectiveUpToDate != null and $.effectiveUpToDate != "") $.effectiveUpToDate 
                else "9999-12-31"
}
          else
            {
	"ProductID": if ($.itemLocationId.item.primaryId != null ) $.itemLocationId.item.primaryId
                else "",
	"LocationID": if ($.itemLocationId.location.primaryId != null ) $.itemLocationId.location.primaryId
                else "",
	"UnitID": codeListItemTypeCode($.effectiveInventoryParameters[0].minimumSafetyStockQuantity.measurementUnitCode),
	"ActiveFrom": if ($.effectiveFromDate != null and $.effectiveFromDate != "") $.effectiveFromDate 
                else "1970-01-01",
	"ActiveUpTo": if ($.effectiveUpToDate != null and $.effectiveUpToDate != "") $.effectiveUpToDate 
                else "9999-12-31"
})}
