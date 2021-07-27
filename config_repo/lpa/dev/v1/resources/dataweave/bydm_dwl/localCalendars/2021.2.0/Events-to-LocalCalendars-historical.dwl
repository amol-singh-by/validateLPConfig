%dw 2.0
import * from dw::Runtime
fun getOperationType(grpActionCode, event) =
	if ( grpActionCode.documentActionCode != "DELETE" )
		if (event.actionCode == "ADD" or event.actionCode == "CHANGE") "Record"
		else if (event.actionCode == "DELETE") "DeleteRecord"
		else "Record"
	else "DeleteRecord"

var response = payload[vars.bulkType] map (eventGroup, index) -> {
	(eventGroup.eventLocation map (eventLocation) -> {
		(if(getOperationType(eventGroup, eventLocation) != "DELETE") {
           (getOperationType(eventGroup, eventLocation)): {
			LocationID: if(eventLocation.location.primaryId != null and eventLocation.location.primaryId != "") eventLocation.location.primaryId
            else '',
			EventCalendarID: if(eventGroup.eventGroupId != null and eventGroup.eventGroupId != "") eventGroup.eventGroupId
            else '',
			ActiveFrom: if(eventLocation.effectiveFromDate != null and eventLocation.effectiveFromDate != "") (eventLocation.effectiveFromDate replace "Z" with "")
            else '1970-01-01',
			ActiveUpTo: if(eventLocation.effectiveUpToDate != null and eventLocation.effectiveUpToDate != "") (eventLocation.effectiveUpToDate replace "Z" with "")
            else '9999-12-31'
           } 
			
		} else {
			 (getOperationType(eventGroup, eventLocation)): {
            LocationID: if(eventLocation.location.primaryId != null and eventLocation.location.primaryId != "") eventLocation.location.primaryId
            else '',
			EventCalendarID: if(eventGroup.eventGroupId != null and eventLocation.location.primaryId != "") eventGroup.eventGroupId
            else '',
			ActiveFrom: if(eventLocation.effectiveFromDate != null and eventLocation.effectiveFromDate != "") (eventLocation.effectiveFromDate replace "Z" with "")
            else '1970-01-01',
			ActiveUpTo: if(eventLocation.effectiveUpToDate != null and eventLocation.effectiveUpToDate != "") (eventLocation.effectiveUpToDate replace "Z" with "")
            else '9999-12-31'
            }
        })
	}
    )
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
LocalCalendars : {(flatten([] + (response.*Record default [] map {Record : $ }) + (response.*DeleteRecord default []  map {DeleteRecord : $ })))}