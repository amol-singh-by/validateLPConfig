%dw 2.0
import * from dw::Runtime
fun getOperationType(grpActionCode, event) =
	if ( grpActionCode.documentActionCode != "DELETE" )
		if (event.actionCode == "ADD" or event.actionCode == "CHANGE") "Record"
		else if (event.actionCode == "DELETE") "DeleteRecord"
		else "Record"
	else "DeleteRecord"

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

var response = payload[vars.bulkType] map (eventGroup, index) -> {
	(eventGroup.eventLocation map (eventLocation) -> {
		(if(getOperationType(eventGroup, eventLocation) != "DELETE") {
           (getOperationType(eventGroup, eventLocation)): {
			LocationID: if(eventLocation.location.primaryId != null and eventLocation.location.primaryId != "") eventLocation.location.primaryId
            else '',
			EventCalendarID: if(eventGroup.eventGroupId != null and eventGroup.eventGroupId != "") eventGroup.eventGroupId
            else '',
			ActiveFrom: if(eventLocation.effectiveFromDate != null and eventLocation.effectiveFromDate != "") (eventLocation.effectiveFromDate replace "Z" with "")
            else defaultFromDate,
			ActiveUpTo: if(eventLocation.effectiveUpToDate != null and eventLocation.effectiveUpToDate != "") validateDate(eventLocation.effectiveUpToDate replace "Z" with "")
            else '9999-12-31'
           }
		} else {
			 (getOperationType(eventGroup, eventLocation)): {
            LocationID: if(eventLocation.location.primaryId != null and eventLocation.location.primaryId != "") eventLocation.location.primaryId
            else '',
			EventCalendarID: if(eventGroup.eventGroupId != null and eventGroup.eventGroupId != "") eventGroup.eventGroupId
            else '',
			ActiveFrom: if(eventLocation.effectiveFromDate != null and eventLocation.effectiveFromDate != "") (eventLocation.effectiveFromDate replace "Z" with "")
            else defaultFromDate,
			ActiveUpTo: if(eventLocation.effectiveUpToDate != null and eventLocation.effectiveUpToDate != "") validateDate(eventLocation.effectiveUpToDate replace "Z" with "")
            else '9999-12-31'
            }
        })
	}
    )
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
LocalCalendars : {(flatten([] + (response.*Record default [] map {Record : $ }) + (response.*DeleteRecord default []  map {DeleteRecord : $ })))}