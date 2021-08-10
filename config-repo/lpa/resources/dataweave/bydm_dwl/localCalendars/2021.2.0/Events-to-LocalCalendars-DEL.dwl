%dw 2.0
import * from dw::Runtime

var entityDatePolicy = (vars.entityConfig.targetEntities filter $.name == vars.fullLPEntityName)[0].datePolicy
var entityIncrementalDate = (vars.entityConfig.targetEntities filter $.name == vars.fullLPEntityName)[0].incrementalDate

var defaultFromDate =  if (p("useGlobalDatePolicy.value")) 
	(if (p("useGlobalDatePolicy.datePolicy") == "NEXT_DAY") 
								(now() as Date) + ("P" ++ (p("useGlobalDatePolicy.incrementalDate") default 0) as String ++ "D") as Period
					  		else (now() as Date))
else if (!p("useGlobalDatePolicy.value")) 
	(if (entityDatePolicy == "NEXT_DAY") 
								(now() as Date) + ("P" ++ (entityIncrementalDate default 0) as String ++ "D") as Period
					  		else (now() as Date))

else ""

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

var response = payload[vars.bulkType] filter ($.documentActionCode != "DELETE") map (eventGroup, index) -> {
	(eventGroup.eventLocation filter($.actionCode != "DELETE") map (eventLocation) -> {
		( 
            "DeleteAllRecords" : {
            EventCalendarID: if(eventGroup.eventGroupId != null and eventGroup.eventGroupId != "" and eventGroup.eventGroupId != "*UNKNOWN") eventGroup.eventGroupId
            else null,
            LocationID: if(eventLocation.location.primaryId != null and eventLocation.location.primaryId != "" and eventLocation.location.primaryId != "*UNKNOWN") eventLocation.location.primaryId
            else null,
            ActiveFrom: if(eventLocation.effectiveFromDate != null and eventLocation.effectiveFromDate != "") (eventLocation.effectiveFromDate replace "Z" with "") 
            else defaultFromDate,
            ActiveUpTo: if(eventLocation.effectiveUpToDate != null and eventLocation.effectiveUpToDate != "") (eventLocation.effectiveUpToDate replace "Z" with "")
            else "9999-12-31"
            } 
		)
	  }
   )
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
LocalCalendars : {(flatten([] + 
(response.*DeleteAllRecords default [] map {DeleteAllRecords : $ }) 
))}