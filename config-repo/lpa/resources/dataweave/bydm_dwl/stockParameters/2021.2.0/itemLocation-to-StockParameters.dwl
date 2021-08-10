%dw 2.0
import * from dw::Runtime

var entityDatePolicy = (vars.entityConfig.targetEntities filter $.name == vars.fullLPEntityName)[0].datePolicy
var entityIncrementalDate = (vars.entityConfig.targetEntities filter $.name == vars.fullLPEntityName)[0].incrementalDate

var defaultFromDate =  if (p("useGlobalDatePolicy.value")) 
	(if (p("useGlobalDatePolicy.datePolicy") == "NEXT_DAY") 
								(now() as Date) + ("P" ++ (p("useGlobalDatePolicy.incrementalDate") default 0) as String ++ "D") as Period
					  		else (now() as Date))

else if (!p("useGlobalDatePolicy.value")) 
	(if (entityDatePolicy == "NEXT_DAY") 
								(now() as Date) + ("P" ++ (entityIncrementalDate default 0) as String ++ "D") as Period
					  		else (now() as Date))

else ""


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
StockParameters: {
	((payload[vars.bulkType] filter (() -> (($.includesStockParameters default 'false') ~= 'true'))) map () -> 
          if ( getOperationType($.documentActionCode) == "Record" ) "Record": {
		"ProductID": if ( $.itemLocationId.item.primaryId != null ) $.itemLocationId.item.primaryId
                else "",
		"LocationID": if ( $.itemLocationId.location.primaryId != null ) $.itemLocationId.location.primaryId
                else "",
		"UnitID": codeListItemTypeCode($.effectiveInventoryParameters[0].minimumSafetyStockQuantity.measurementUnitCode),
		"MinQuantity": if ( $.effectiveInventoryParameters.minimumSafetyStockQuantity.value != null and $.effectiveInventoryParameters.minimumSafetyStockQuantity.value != "" ) $.effectiveInventoryParameters.minimumSafetyStockQuantity.value
                else null,
		"MaxQuantity": if ( $.planningParameters.maximumOnHandQuantity.value != null and $.planningParameters.maximumOnHandQuantity.value != "" ) $.planningParameters.maximumOnHandQuantity.value
                else null,
		"MinNumberExpirationDays": if ( $.perishableParameters.minimumShelfLifeDuration.value != null and $.perishableParameters.minimumShelfLifeDuration.value != "" ) (codeListTimeMeasurementTypeCode($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode) as Number * $.perishableParameters.minimumShelfLifeDuration.value as Number)
                else null,
		"ActiveFrom": if ( $.effectiveFromDate != null and $.effectiveFromDate != "" ) $.effectiveFromDate 
                else defaultFromDate,
		"ActiveUpTo": if ( $.effectiveUpToDate != null and $.effectiveUpToDate != "" ) $.effectiveUpToDate 
                else "9999-12-31"
	}
          else if ( getOperationType($.documentActionCode) == "DeleteRecord" and ($.itemLocationId.item.primaryId == "*UNKNOWN" or $.itemLocationId.location.primaryId == "*UNKNOWN") ) "DeleteAllRecords": {
		"ProductID": if ( !isEmpty($.itemLocationId.item.primaryId) and $.itemLocationId.item.primaryId != "*UNKNOWN" ) $.itemLocationId.item.primaryId
                else null,
		"LocationID": if ( !isEmpty($.itemLocationId.location.primaryId) and $.itemLocationId.location.primaryId != "*UNKNOWN" ) $.itemLocationId.location.primaryId
                else null,
		"UnitID": if (!isEmpty($.effectiveInventoryParameters[0].minimumSafetyStockQuantity.measurementUnitCode)) codeListItemTypeCode($.effectiveInventoryParameters[0].minimumSafetyStockQuantity.measurementUnitCode) 
				else null,
		"ActiveFrom": if ( $.effectiveFromDate != null and $.effectiveFromDate != "" ) $.effectiveFromDate 
                else defaultFromDate,
		"ActiveUpTo": if ( $.effectiveUpToDate != null and $.effectiveUpToDate != "" ) $.effectiveUpToDate 
                else "9999-12-31"
	} else "DeleteRecord": {
		"ProductID": if ( $.itemLocationId.item.primaryId != null ) $.itemLocationId.item.primaryId
                else "",
		"LocationID": if ( $.itemLocationId.location.primaryId != null ) $.itemLocationId.location.primaryId
                else "",
		"UnitID": codeListItemTypeCode($.effectiveInventoryParameters[0].minimumSafetyStockQuantity.measurementUnitCode),
		"ActiveFrom": if ( $.effectiveFromDate != null and $.effectiveFromDate != "" ) $.effectiveFromDate 
                else defaultFromDate,
		"ActiveUpTo": if ( $.effectiveUpToDate != null and $.effectiveUpToDate != "" ) $.effectiveUpToDate 
                else "9999-12-31"
	})
}
