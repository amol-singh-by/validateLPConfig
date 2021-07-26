%dw 2.0

fun getOperationType(grpActionCode, event) =
	if ( grpActionCode.documentActionCode != "DELETE" )
		if (event.actionCode == "ADD" or event.actionCode == "CHANGE") "Record"
		else if (event.actionCode == "DELETE") "DeleteRecord"
		else "Record"
	else "DeleteRecord"

var response = payload[vars.bulkType] map (eventGroup, index) -> {
	(eventGroup.event map (event) -> {
		(event.eventDate map (eventDate) -> {
			(getOperationType(eventGroup, event)): 
            if ( getOperationType(eventGroup, event) != "DeleteRecord" ) {
				EventCalendarID: if ( eventGroup.eventGroupId != null ) eventGroup.eventGroupId
                  else '',
				Name: if ( eventGroup.name != null ) trim(eventGroup.name)
                  else '',
				Description: if ( event.description.value != null and event.description.value != "" ) trim(event.description.value)
                  else null,
				EventDay: if ( eventDate.eventDate != null ) (eventDate.eventDate replace "Z" with "")
                  else '',
				PublicHoliday: if ( eventDate.isPublicHoliday != null ) eventDate.isPublicHoliday
                  else ''
			}
            else
              {
				EventCalendarID: if ( eventGroup.eventGroupId != null ) eventGroup.eventGroupId
                  else '',
				Name: if ( eventGroup.name != null ) eventGroup.name
                  else '',
				EventDay: if ( eventDate.eventDate != null ) (eventDate.eventDate replace "Z" with "")
                  else ''
			}
		})
	})
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
Events : {(flatten([] + (response.*Record default [] map {Record : $ }) + (response.*DeleteRecord default []  map {DeleteRecord : $ })))}