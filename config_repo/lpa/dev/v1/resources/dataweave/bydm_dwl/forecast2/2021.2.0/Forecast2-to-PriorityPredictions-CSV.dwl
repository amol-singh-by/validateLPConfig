%dw 2.0
import * from dw::Runtime
@StreamCapable()

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

output application/xml  deferred = true, skipNullOn = "everywhere"
---
PriorityPredictions: ({
	((payload filter (validForecastTypeCode contains $.forecastTypeCode)) map () -> 
        (getOperationType($)): 
         if ( getOperationType($) == "Record" ) {
		ProductID: if ( $.itemId != null ) $.itemId
                else "",
		LocationID: if ( $.locationId != null ) $.locationId
                else "",
		Day: if ( $."measure.forecastStartDate" != null ) $."measure.forecastStartDate" replace "Z" with ""
                else "",
		Mean: if ( $."measure.quantity.value" != null ) $."measure.quantity.value"
                else "",
		UnitID: codeListItemTypeCode($."measure.quantity.measurementUnitCode", codelistFlag),
		Reason: if ( $.forecastOverrideReason != null ) $.forecastOverrideReason
                else null
	}
        else if ( getOperationType($) == "DeleteRecord" ) {
		ProductID: if ( $.itemId != null ) $.itemId
                else "",
		LocationID: if ( $.locationId != null ) $.locationId
                else "",
		Day: if ( $."measure.forecastStartDate" != null ) $."measure.forecastStartDate" replace "Z" with ""
                else ""
	}
		else {
		ProductID: if ( !isEmpty($.itemId) and $.itemId != "*UNKNOWN" ) $.itemId
                else null,
		LocationID: if ( !isEmpty($.locationId) and $.locationId != "*UNKNOWN" ) $.locationId
                else null,
		DayFrom: if ( $."measure.forecastStartDate" != null ) $."measure.forecastStartDate" replace "Z" with ""
                else "",
		DayUpTo: if ( !isEmpty($."measure.forecastStartDate") and !isEmpty(validateDateFormat($."measure.forecastStartDate" replace "Z" with "")) and !isEmpty(validateNumber($."measure.durationInMinutes")) ) (validateDateFormat($."measure.forecastStartDate" replace "Z" with "") + "P$(floor($.'measure.durationInMinutes' / 1440))D") 
				else ""
	})
})
