%dw 2.0
output application/xml deferred = true, skipNullOn = "everywhere"
---
EventCalendars: {
	(payload[vars.bulkType] filter ($.documentActionCode != 'DELETE') map (eventGroup, index) -> 
      "Record": {
		(EventCalendarID: if((eventGroup.eventGroupId) != null and (eventGroup.eventGroupId) != "") eventGroup.eventGroupId
            else ''),
		(Name: if((eventGroup.name) != null and (eventGroup.name) != "") eventGroup.name
            else ''),
		(Description: if(eventGroup.description.value != null and eventGroup.description.value != "") eventGroup.description.value
            else null)
	})
}
