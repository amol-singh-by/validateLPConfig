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
			(
            if ( getOperationType(eventGroup, event) != "DeleteRecord" ) 
            (getOperationType(eventGroup, event)): {
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
             'DeleteRecord': {
				EventCalendarID: if ( eventGroup.eventGroupId != null ) eventGroup.eventGroupId
                  else '',
				Name: if ( eventGroup.name != null ) eventGroup.name
                  else '',
				EventDay: if ( eventDate.eventDate != null ) (eventDate.eventDate replace "Z" with "")
                  else ''
			}
      )  }),

      (if (getOperationType(eventGroup, event) == "DeleteRecord" and !isEmpty(event.eventDateRange) 
        and (!isEmpty(event.eventDateRange.beginDate) and !isEmpty(event.eventDateRange.endDate))
        or (eventGroup.eventGroupId == "*UNKNOWN" or event.eventName == "*UNKNOWN")) {
                'DeleteAllRecords' : event.eventDateRange map {
                EventCalendarID: if(!isEmpty(eventGroup.eventGroupId) and eventGroup.eventGroupId != "*UNKNOWN") eventGroup.eventGroupId else null,
                Name: if(!isEmpty(event.eventName) and event.eventName != "*UNKNOWN") event.eventName else null,                
                EventDayFrom: if(!isEmpty($.beginDate)) $.beginDate else "",
                EventDayUpTo: if(!isEmpty($.endDate)) $.endDate else ""
                }  
            } else {})


	})
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
Events : {(flatten([] + 
(response.*Record default [] map {Record : $ }) + 
(response.*DeleteRecord default []  map {DeleteRecord : $ }) +
(response.*DeleteAllRecords default []  map {DeleteAllRecords : $ })
))}