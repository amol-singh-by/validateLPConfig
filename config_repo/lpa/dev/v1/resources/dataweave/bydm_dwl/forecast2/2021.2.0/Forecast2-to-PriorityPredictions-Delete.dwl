%dw 2.0
import * from dw::Runtime

var validForecastTypeCode = ["5", "6"]

fun validateDateFormat(str) = try(() -> str as Date) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

fun validateNumber(str) = try(() -> str as Number) match {
	case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}


output application/xml deferred = true, skipNullOn = "everywhere"
---
PriorityPredictions: {
	(flatten((payload[vars.bulkType] filter ((validForecastTypeCode contains $.forecastTypeCode) and $.documentActionCode != "DELETE")) default [] map (forecast) -> 
        (forecast.measure default [] map(measure, index) -> 
           DeleteAllRecords: {
          
		ProductID: if ( !isEmpty(forecast.itemId) and forecast.itemId != "*UNKNOWN" ) forecast.itemId
                else null,
		LocationID: if ( !isEmpty(forecast.locationId) and forecast.locationId != "*UNKNOWN" ) forecast.locationId
                else null,
		DayFrom: if ( !isEmpty(measure.forecastStartDate) ) measure.forecastStartDate replace "Z" with ""
                else "",
              
		DayUpTo: if ( !isEmpty(measure.forecastStartDate) and !isEmpty(validateNumber(measure.durationInMinutes)) ) (validateDateFormat(measure.forecastStartDate replace "Z" with "") + "P$(floor(measure.durationInMinutes / 1440))D") 
				else ""
              
	}
  )))
}