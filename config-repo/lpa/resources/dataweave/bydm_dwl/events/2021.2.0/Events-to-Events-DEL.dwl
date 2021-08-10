%dw 2.0

var response = payload[vars.bulkType] filter ($.documentActionCode != "DELETE") map (eventGroup, index) -> {
    (eventGroup.event filter($.actionCode != "DELETE") map (event) -> {
			(
             if ( !isEmpty(event.eventDateRange) 
        		  and (!isEmpty(event.eventDateRange.beginDate) and !isEmpty(event.eventDateRange.endDate))
        	     ) {
                'DeleteAllRecords' : event.eventDateRange map {
                EventCalendarID: if(!isEmpty(eventGroup.eventGroupId) and eventGroup.eventGroupId != "*UNKNOWN") eventGroup.eventGroupId else null,
                Name: if(!isEmpty(event.eventName) and event.eventName != "*UNKNOWN") event.eventName else null,                
                EventDayFrom: if(!isEmpty($.beginDate)) $.beginDate else "",
                EventDayUpTo: if(!isEmpty($.endDate)) $.endDate else ""
                }  
            }
            else
              {
			}
      )  
	})
}

output application/xml  skipNullOn = "everywhere"
---
Events : {(flatten([] + 
(response.*DeleteAllRecords default []  map {DeleteAllRecords : $ })
))}