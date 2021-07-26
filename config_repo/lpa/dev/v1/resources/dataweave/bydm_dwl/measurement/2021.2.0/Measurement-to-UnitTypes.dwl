%dw 2.0
output application/xml deferred = true, skipNullOn = "everywhere"
---
"UnitTypes": {(
    (payload[vars.bulkType] filter($.documentActionCode != "DELETE") map(measurement,index) -> {
        (measurement.measurementUnitCodeInformation map (muci,index) -> {
            "Record": {
				("UnitID": muci.measurementUnitCode.measurementUnitCode) if (!isEmpty(muci.measurementUnitCode.measurementUnitCode)),
				("UnitID": muci.measurementUnitCode.timeMeasurementUnitCode) if (!isEmpty(muci.measurementUnitCode.timeMeasurementUnitCode)),
				("UnitID": muci.measurementUnitCode.currencyCode) if (!isEmpty(muci.measurementUnitCode.currencyCode)),
				(flatten(muci.*measurementUnitCodeDescription) filter $.descriptionType == "SHORT_TEXT" map {
					"Name": $.value
				}),
				(flatten(muci.*measurementUnitCodeDescription) filter $.descriptionType == "SINGULAR_LABEL" map {
					"Description": $.value
				})
			}
        })
    })
 )}
