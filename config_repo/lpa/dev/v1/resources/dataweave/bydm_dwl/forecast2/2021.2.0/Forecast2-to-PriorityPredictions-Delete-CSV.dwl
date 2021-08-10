%dw 2.0
import * from dw::Runtime
@StreamCapable()

var validForecastTypeCode = ["5", "6"]

fun validateDateFormat(str) = try(() -> str as Date) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

fun validateNumber(str) = try(() -> str as Number) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}


output application/xml  deferred = true, skipNullOn = "everywhere"
---
PriorityPredictions: ({
	((payload filter ((validForecastTypeCode contains $.forecastTypeCode))  and $.documentActionCode != 'DELETE') map () -> 
        DeleteAllRecords: {
            ProductID: if ( !isEmpty($.itemId) and $.itemId != "*UNKNOWN" ) $.itemId
                else null,
		LocationID: if ( !isEmpty($.locationId) and $.locationId != "*UNKNOWN" ) $.locationId
                else null,
		DayFrom: if (!isEmpty($."measure.forecastStartDate")) $."measure.forecastStartDate" replace "Z" with ""
                else "",
		DayUpTo: if ( !isEmpty($."measure.forecastStartDate") and !isEmpty(validateNumber($."measure.durationInMinutes")) ) (validateDateFormat($."measure.forecastStartDate" replace "Z" with "") + "P$(floor($.'measure.durationInMinutes' / 1440))D") 
				else ""
        }
         )
})

