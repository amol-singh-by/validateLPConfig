%dw 2.0
@StreamCapable()
import * from dw::Runtime

fun getOperationType(itemLocation) =
	if ( itemLocation.documentActionCode == "ADD" or itemLocation.documentActionCode == "CHANGE_BY_REFRESH" ) "Record"
	else if ( itemLocation.documentActionCode == "DELETE" and (itemLocation."itemLocationId.item.primaryId" == "*UNKNOWN" or itemLocation."itemLocationId.location.primaryId" == "*UNKNOWN")) "DeleteAllRecords"
	else if ( itemLocation.documentActionCode == "DELETE" ) "DeleteRecord"
	else "Record"
    
var codelistFlag = Mule::p('bydm.canmodel.codeList')
fun codeListItemTypeCode(value, codelistFlag) = codelistFlag match {
    case str: "ERROR" -> if((value) != null) 
							jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value) 
						  else ''
    else ->   try(() ->  jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

fun codeListTimeMeasurementTypeCode(value) = codelistFlag match {
    case str: "ERROR" -> if((value) != null) 
							jda::CodeMap::keyLookupWithDefault(vars.codeMap.TimeMeasurementTypeCode, "TimeMeasurementTypeCode", value, value) 
						  else ''
    else -> try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.TimeMeasurementTypeCode, "TimeMeasurementTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
StockParameters: {
	((payload filter (()-> ($.includesStockParameters default false))) map((stockP,stockPIndex) ->
		(getOperationType(stockP)):
			if ( getOperationType(stockP) == "Record" ) {
		ProductID: if ( stockP."itemLocationId.item.primaryId" != null ) stockP."itemLocationId.item.primaryId" else "",
		LocationID: if ( stockP."itemLocationId.location.primaryId" != null ) stockP."itemLocationId.location.primaryId" else "",
		UnitID: codeListItemTypeCode(stockP."effectiveInventoryParameters.minimumSafetyStockQuantity.measurementUnitCode", codelistFlag),
		MinQuantity: stockP."effectiveInventoryParameters.minimumSafetyStockQuantity.value" default null,
		MaxQuantity: stockP."planningParameters.maximumOnHandQuantity.value" default null,
		MinNumberExpirationDays: if ( !isEmpty(stockP."perishableParameters.minimumShelfLifeDuration.value") ) (codeListTimeMeasurementTypeCode(stockP."perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode") as Number * stockP."perishableParameters.minimumShelfLifeDuration.value" as Number) else null,
		ActiveFrom: if ( !isEmpty(stockP.effectiveFromDate) ) stockP.effectiveFromDate else "1970-01-01",
		ActiveUpTo: if ( !isEmpty(stockP.effectiveUpToDate) ) stockP.effectiveUpToDate else "9999-12-31"
	} else if ( getOperationType(stockP) == "DeleteRecord" ) {
		ProductID: if ( stockP."itemLocationId.item.primaryId" != null ) stockP."itemLocationId.item.primaryId" else "",
		LocationID: if ( stockP."itemLocationId.location.primaryId" != null ) stockP."itemLocationId.location.primaryId" else "",
		UnitID: codeListItemTypeCode(stockP."effectiveInventoryParameters.minimumSafetyStockQuantity.measurementUnitCode", codelistFlag),
		ActiveFrom: if ( !isEmpty(stockP.effectiveFromDate) ) stockP.effectiveFromDate else "1970-01-01",
		ActiveUpTo: if ( !isEmpty(stockP.effectiveUpToDate) ) stockP.effectiveUpToDate else "9999-12-31"
	} else {
		ProductID: if ( !isEmpty(stockP."itemLocationId.item.primaryId") and stockP."itemLocationId.item.primaryId" != "*UNKNOWN" ) stockP."itemLocationId.item.primaryId" else null,
		LocationID: if ( !isEmpty(stockP."itemLocationId.location.primaryId") and stockP."itemLocationId.location.primaryId" != "*UNKNOWN" ) stockP."itemLocationId.location.primaryId" else null,
		UnitID: if ( !isEmpty(stockP."effectiveInventoryParameters.minimumSafetyStockQuantity.measurementUnitCode") ) codeListItemTypeCode(stockP."effectiveInventoryParameters.minimumSafetyStockQuantity.measurementUnitCode", codelistFlag)
			else null,
		ActiveFrom: if ( !isEmpty(stockP.effectiveFromDate) ) stockP.effectiveFromDate else "1970-01-01",
		ActiveUpTo: if ( !isEmpty(stockP.effectiveUpToDate) ) stockP.effectiveUpToDate else "9999-12-31"
	}
	))
}