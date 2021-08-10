%dw 2.0
import * from dw::core::Arrays

var numberOfDays = Mule::p('calendar.offset.noOfdays') as Number default 28
var dateRange = vars.dateRangeMap default []

fun findDatesByDayOfWeek(dayOfWeek) = flatten(dayOfWeek default [] map {
	date : (dateRange[$])
}.date)

fun processRecord(startDate, item_rl,item_c,item_p,item_ca,index_ca) = Record: {
					"LocationID": if ( item_rl.primaryId != null ) item_rl.primaryId else "",
					"ValidDay": if ( startDate != null ) getDate(startDate)  else "",
					"Description": if ( item_c.description != null and item_c.description != "" ) item_c.description.value else null,
					"IsOpen": getIsOpen(item_p),
					"PeriodCounter": index_ca + 1 default 1,
					"OpeningTime": if ( item_p.calendarAttribute != null ) getDate(startDate) ++ "T" ++ item_ca.startTime ++ getTimeZone(startDate) else (now() >>"UTC") as String {
						format: "yyyy-MM-dd'T'08:00:00xxx"
					},
					"ClosingTime": if ( item_p.calendarAttribute != null ) getDate(startDate) ++ "T" ++ item_ca.endTime ++ getTimeZone(startDate) else (now() >>"UTC") as String {
						format: "yyyy-MM-dd'T'20:00:00xxx"
					}
				}


fun getIsOpen(value) = if (!isEmpty(value.isHoliday)) (!value.isHoliday) else if (value.calendarAttribute.attributeType contains "1") true else false

var calendar = (payload[vars.bulkType]) filter ((item, index) -> item.calendarType == "OPEN_HOURS")
var filtervar = calendar.pattern map ($.calendarAttribute) map ($ filter($.attributeType == "1"))
fun getDate(value) = slice((value splitBy (/-|\+/)), 0, 3) joinBy "-"
fun getTimeZone(value) = (if ( value[10] != null ) value[10] else "+") ++ (if ( sizeOf(value splitBy (/-|\+/)) != 3 ) ((value splitBy (/-|\+/))[-1]) else "00:00")


output application/xml deferred = true, skipNullOn = "everywhere"

---
OpeningHours : {((flatten({
	(calendar filter($.documentActionCode != "DELETE") map ((item_c,index_c) ->  
        {
            (flatten((item_c.relatedLocation) map ((item_rl,index_rl) -> 
            {
                ((item_c.pattern) map (item_p,index_p) -> {
                    ((item_p.calendarAttribute) default [1] map (item_ca,index_ca)  ->        
                
                (if(item_p != null and item_p.patternFrequencyCode == 'DAY_OF_WEEK') {
                    
                    Record1 : (findDatesByDayOfWeek(item_p.patternFrequency.weekly.dayOfWeek) filter ((($ >= ((item_c.calendarStartDate[0 to 9] default (now() as String {format: "yyyy-MM-dd"})))) and 
($ <= (item_c.calendarEndDate[0 to 9] default ((now()) as String {format: "yyyy-MM-dd"}))))) map {
                            (processRecord($,item_rl,item_c,item_p,item_ca,index_ca))
                        }).Record
                } else if(item_p != null and item_p.patternFrequencyCode == 'EVERY_DAY') {
                    Record1 : (findDatesByDayOfWeek(['EVERYDAY_DATE_RANGE'] default []) filter ((($ >= ((item_c.calendarStartDate[0 to 9] default (now() as String {format: "yyyy-MM-dd"})))) and 
($ <= (item_c.calendarEndDate[0 to 9] default ((now()) as String {format: "yyyy-MM-dd"}))))) map {
                            (processRecord($,item_rl,item_c,item_p,item_ca,index_ca))
                        }).Record
                } else {
                    Record1 : (([item_c.calendarStartDate[0 to 9]]) map {
                            (processRecord($,item_rl,item_c,item_p,item_ca,index_ca))
                        }).Record
                })    
              )})
            }
            )))
        }
    ))
}.*Record1)) map {
	Record : $
})}