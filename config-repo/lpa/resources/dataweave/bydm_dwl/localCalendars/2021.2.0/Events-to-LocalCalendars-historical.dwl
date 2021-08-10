%dw 2.0
import * from dw::Runtime

fun getOperationType(grpActionCode, eventLocation) =
	if ( grpActionCode.documentActionCode != "DELETE" )
		if (eventLocation.actionCode == "ADD" or eventLocation.actionCode == "CHANGE") "Record"
		else if (eventLocation.actionCode == "DELETE") "DeleteRecord"
		else "Record"
	else "DeleteRecord"

var response = payload[vars.bulkType] map (eventGroup, index) -> {
	(eventGroup.eventLocation map (eventLocation) -> {
		(if(getOperationType(eventGroup, eventLocation) != "DeleteRecord") {
           (getOperationType(eventGroup, eventLocation)): {
			LocationID: if(eventLocation.location.primaryId != null and eventLocation.location.primaryId != "") eventLocation.location.primaryId
            else '',
			EventCalendarID: if(eventGroup.eventGroupId != null and eventGroup.eventGroupId != "") eventGroup.eventGroupId
            else '',
			ActiveFrom: if(eventLocation.effectiveFromDate != null and eventLocation.effectiveFromDate != "") (eventLocation.effectiveFromDate replace "Z" with "")
            else "1970-01-01",
			ActiveUpTo: if(eventLocation.effectiveUpToDate != null and eventLocation.effectiveUpToDate != "") eventLocation.effectiveUpToDate replace "Z" with ""
            else '9999-12-31'
           }
		} 
		else if(getOperationType(eventGroup, eventLocation) == "DeleteRecord"
			and (eventLocation.effectiveFromDate? and eventLocation.effectiveUpToDate?)
			or (eventGroup.eventGroupId == "*UNKNOWN" or eventLocation.location.primaryId == "*UNKNOWN")
				) 
			"DeleteAllRecords": {
            (getOperationType(eventGroup, eventLocation)) : {
            EventCalendarID: if(eventGroup.eventGroupId != null and eventGroup.eventGroupId != "" and eventGroup.eventGroupId != "*UNKNOWN") eventGroup.eventGroupId
            else null,
            LocationID: if(eventLocation.location.primaryId != null and eventLocation.location.primaryId != "" and eventLocation.location.primaryId != "*UNKNOWN") eventLocation.location.primaryId
            else null,
            ActiveFrom: if(eventLocation.effectiveFromDate != null and eventLocation.effectiveFromDate != "") (eventLocation.effectiveFromDate replace "Z" with "") 
            else "1970-01-01",
            ActiveUpTo: if(eventLocation.effectiveUpToDate != null and eventLocation.effectiveUpToDate != "") (eventLocation.effectiveUpToDate replace "Z" with "")
            else "9999-12-31"
            }
        }.DeleteRecord
		else {
			 (getOperationType(eventGroup, eventLocation)): {
            LocationID: if(eventLocation.location.primaryId != null and eventLocation.location.primaryId != "") eventLocation.location.primaryId
            else '',
			EventCalendarID: if(eventGroup.eventGroupId != null and eventGroup.eventGroupId != "") eventGroup.eventGroupId
            else '',
			ActiveFrom: if(eventLocation.effectiveFromDate != null and eventLocation.effectiveFromDate != "") (eventLocation.effectiveFromDate replace "Z" with "")
            else "1970-01-01",
			ActiveUpTo: if(eventLocation.effectiveUpToDate != null and eventLocation.effectiveUpToDate != "") eventLocation.effectiveUpToDate replace "Z" with ""
            else '9999-12-31'
            }
        })
	}
    )
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
LocalCalendars : {(flatten([] + 
(response.*Record default [] map {Record : $ }) + 
(response.*DeleteRecord default []  map {DeleteRecord : $ }) +
(response.*DeleteAllRecords default [] map {DeleteAllRecords : $ }) 
))}