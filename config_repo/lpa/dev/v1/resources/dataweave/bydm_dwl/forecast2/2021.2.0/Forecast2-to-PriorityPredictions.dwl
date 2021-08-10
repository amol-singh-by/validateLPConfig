%dw 2.0
import * from dw::Runtime

var validForecastTypeCode = ["5", "6"]

fun getOperationType(forecast) =
    if ( forecast.documentActionCode == "ADD" or forecast.documentActionCode == "CHANGE_BY_REFRESH" ) "Record"
   else if ( (forecast.documentActionCode == "DELETE") and (forecast.itemId == "*UNKNOWN" or forecast.locationId == "*UNKNOWN") ) "DeleteAllRecords"
   else if ( forecast.documentActionCode == "DELETE" ) "DeleteRecord" 
   else "Record"

fun validateDateFormat(str) = try(() -> str as Date) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

fun validateNumber(str) = try(() -> str as Number) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemTypeCode(value, codelistFlag) =
  codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)
    else ''
    else -> try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
PriorityPredictions: {
	(flatten((payload[vars.bulkType] filter (validForecastTypeCode contains $.forecastTypeCode)) default [] map (forecast) -> 
        (forecast.measure default [] map(measure, index) -> 
        (getOperationType(forecast)):
          if ( getOperationType(forecast) == "Record" ) {
		ProductID: if ( forecast.itemId != null ) forecast.itemId
                else "",
		LocationID: if ( forecast.locationId != null ) forecast.locationId
                else "",
		Day: if ( measure.forecastStartDate != null ) measure.forecastStartDate replace "Z" with ""
                else "",
		Mean: if ( measure.quantity.value != null ) measure.quantity.value
                else "",
		UnitID: codeListItemTypeCode(measure.quantity.measurementUnitCode, codelistFlag),
		Reason: if ( forecast.forecastOverrideReason != null ) forecast.forecastOverrideReason
                else null
	}
          else if ( getOperationType(forecast) == "DeleteRecord" ) {
		ProductID: if ( forecast.itemId != null ) forecast.itemId
                else "",
		LocationID: if ( forecast.locationId != null ) forecast.locationId
                else "",
		Day: if ( measure.forecastStartDate != null ) measure.forecastStartDate replace "Z" with ""
                else ""
	}	else {
		ProductID: if ( !isEmpty(forecast.itemId) and forecast.itemId != "*UNKNOWN" ) forecast.itemId
                else null,
		LocationID: if ( !isEmpty(forecast.locationId) and forecast.locationId != "*UNKNOWN" ) forecast.locationId
                else null,
		DayFrom: if ( measure.forecastStartDate != null ) measure.forecastStartDate replace "Z" with ""
                else "",
		DayUpTo: if ( !isEmpty(measure.forecastStartDate) and !isEmpty(validateDateFormat(measure.forecastStartDate replace "Z" with "")) and !isEmpty(validateNumber(measure.durationInMinutes)) ) (validateDateFormat(measure.forecastStartDate replace "Z" with "") + "P$(floor(measure.durationInMinutes / 1440))D") 
				else ""
	})))
}