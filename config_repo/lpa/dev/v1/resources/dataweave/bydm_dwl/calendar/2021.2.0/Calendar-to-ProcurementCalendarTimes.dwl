%dw 2.0
import * from dw::Runtime
output application/xml deferred = true, skipNullOn = "everywhere"

var numberOfDays = Mule::p('calendar.offset.noOfdays') as Number default 28
var dateRange = vars.dateRangeMap default []

fun findDatesByDayOfWeek(dayOfWeek) = flatten(dayOfWeek default [] map {
	date : (dateRange[$] default [])
}.date) 

fun getCalendarAttr(pattern,attrName) = try(() -> ( (pattern.calendarAttribute default [] filter $.attributeType == attrName)[0].value default null) as Number) match {
    case theOutput if(theOutput.success ~= false) -> 0
else -> $.result
}


fun formCalendarResponse(startDate,endTime,calendar,pattern) = do {

var startDateWithoutTimezone = (startDate)[0 to 9]
var timeZone = (calendar.calendarStartDate)[10 to 15] default "+00:00"
var startDateTime = (((startDateWithoutTimezone as Date) as String {format: "yyyy-MM-dd'T'" ++ if (!isEmpty(endTime)) (endTime)  else "00:00:00"}) ++ timeZone)
var endDateTime = (((startDateWithoutTimezone as Date) as String {format: "yyyy-MM-dd'T'" ++ if (!isEmpty(endTime)) (endTime)  else "23:59:59"}) ++ timeZone)
---
{
	ProcurementCalendarID: calendar.calendarId,
	FinalOrderTime : (startDateTime + |PT0M|)  as String {format : "yyyy-MM-dd'T'HH:mm:ssXXX"},
    (ExpectedArrival : (endDateTime + (("PT" ++ getCalendarAttr(pattern,'1002') ++ "M") as Period))  as String {format : "yyyy-MM-dd'T'HH:mm:ssXXX"}) if (!isEmpty(getCalendarAttr(pattern,'1002')) and calendar.documentActionCode != 'DELETE'),
	(ExpectedAvailability : (endDateTime + (("PT" ++ getCalendarAttr(pattern,'1003') ++ "M") as Period))  as String {format : "yyyy-MM-dd'T'HH:mm:ssXXX"}) if (!isEmpty(getCalendarAttr(pattern,'1003')) and  calendar.documentActionCode != 'DELETE'),
	(FinalPickingTime : (endDateTime + (("PT" ++ getCalendarAttr(pattern,'1004') ++ "M") as Period))  as String {format : "yyyy-MM-dd'T'HH:mm:ssXXX"}) if (!isEmpty(getCalendarAttr(pattern,'1004')) and calendar.documentActionCode != 'DELETE')
	
	
}
		
}

fun getEndTime(pattern,calendar) = (flatten(pattern.calendarAttribute default []) filter $.attributeType == '1001')[0].endTime default "23:59:59"

fun transformProcCalRecords(calendar,recordType) = ((recordType) : (calendar.pattern) default [] map using ( pattern = $,endTime = getEndTime($,calendar) ) {
	(if ( pattern != null and pattern.patternFrequencyCode == 'DAY_OF_WEEK' ) {
		(findDatesByDayOfWeek(pattern.patternFrequency.weekly.dayOfWeek distinctBy $) filter ((($ >= (calendar.calendarStartDate[0 to 9])) and ($ <= ((calendar.calendarEndDate[0 to 9]) default (((calendar.calendarStartDate[0 to 9] as Date) + ("P$(numberOfDays)D" as Period)) as String {
			format: "yyyy-MM-dd"
		}))))) default [] map {
			(recordType) : formCalendarResponse($,endTime,calendar,pattern)
		})
	} else if ( pattern != null and pattern.patternFrequencyCode == 'SINGLE_DAY' ) {
		([calendar.calendarStartDate[0 to 9]] map {
			(recordType) : formCalendarResponse($,endTime,calendar,pattern)
		})
	} else ((findDatesByDayOfWeek(['EVERYDAY_DATE_RANGE'] default []) filter ((($ >= (calendar.calendarStartDate[0 to 9])) and ($ <= (calendar.calendarEndDate[0 to 9] default (((calendar.calendarStartDate[0 to 9] as Date) + ("P$(numberOfDays)D" as Period)) as String {
		format: "yyyy-MM-dd"
	}))))) map {
		(recordType) : formCalendarResponse($,endTime,calendar,pattern)
	})))
})


fun handleDeleteAllAction(calendar) = {
	(ProcurementCalendarID: calendar.calendarId) if (!isEmpty(calendar.calendarId) and (calendar.calendarId as String) != "DELETE_ALL_PROCCALTIMES"),
	FinalOrderTimeFrom: if ( !isEmpty(calendar.calendarStartDate) ) (formCalendarResponse(((calendar.calendarStartDate[0 to 9])),getEndTime(calendar.pattern,calendar),calendar,calendar.pattern).FinalOrderTime) else '',
	FinalOrderTimeUpTo: if ( !isEmpty(calendar.calendarStartDate) ) (formCalendarResponse(calendar.calendarEndDate[0 to 9] default (((calendar.calendarStartDate[0 to 9] as Date) + "P$(numberOfDays)D" as Period) as String {
		format: "yyyy-MM-dd"
	}),getEndTime(calendar.pattern,calendar),calendar,calendar.pattern).FinalOrderTime) else ''
}        
     

fun insertRecordPayload(calendar) = if(!isEmpty(calendar.calendarStartDate)) transformProcCalRecords(calendar,'Record').Record else Record : {
    "ProcurementCalendarID" : calendar.calendarId default "", "FinalOrderTime" : ""}


fun applyOperation(calendar) =
if ( calendar.calendarType == "PROCUREMENT" and (calendar.documentActionCode == "DELETE") ) {
	'DeleteAllRecords': handleDeleteAllAction(calendar)
} else  insertRecordPayload(calendar)

---
ProcurementCalendarTimes : {(flatten (payload.calendar filter(($.calendarType == "PROCUREMENT")) map ((calendar) -> 
 applyOperation(calendar) )))}