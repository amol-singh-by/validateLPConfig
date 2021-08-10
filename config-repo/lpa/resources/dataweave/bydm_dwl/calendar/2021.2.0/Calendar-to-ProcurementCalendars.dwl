%dw 2.0
output application/xml deferred = true, skipNullOn = "everywhere"
import * from dw::Runtime

fun ProcCal(calendar) = 
	Record: 
		if ( calendar.documentActionCode != "DELETE" ) {
	ProcurementCalendarID: if ( calendar.calendarId != null ) calendar.calendarId
			else "",
	Name: if ( calendar.name != null ) calendar.name
			else "",
	Description: if ( calendar.description.value != null and calendar.description.value != "" ) calendar.description.value
			else null
}
		else null

---
ProcurementCalendars : {(payload[vars.bulkType] filter ($.calendarType == "PROCUREMENT" and $.documentActionCode != "DELETE") map ((item) -> ProcCal(item)))}
