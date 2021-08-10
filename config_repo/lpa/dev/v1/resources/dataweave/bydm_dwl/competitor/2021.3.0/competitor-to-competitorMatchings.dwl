%dw 2.0
@StreamCapable()
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
					
fun getOperationType(parent, child) =
	if ( parent.documentActionCode != "DELETE" )
		if (child.actionCode == "ADD" or child.actionCode == "CHANGE") "Record"
		else if (child.actionCode == "DELETE") "DeleteRecord"
		else "Record"
	else "DeleteRecord"

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListCompetitorTypeCode(value, codelistFlag) = codelistFlag match {
    case str: "ERROR" -> if((value) != null) 
							jda::CodeMap::keyLookupOptional(vars.codeMap.CompetitorTypeCode, "CompetitorTypeCode", value default "") 
						  else ''
    else ->  if((jda::CodeMap::keyLookupOptional(vars.codeMap.CompetitorTypeCode, "CompetitorTypeCode", value default "")) != null) 
				jda::CodeMap::keyLookupOptional(vars.codeMap.CompetitorTypeCode, "CompetitorTypeCode", value default "") 
			 else value
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
 "CompetitorMatchings": {(
    (payload[vars.bulkType] map(competitor,index) -> {
        (competitor.competitorMatchingDetails map (cm,index) -> {
            (if ( getOperationType(competitor,cm) == "Record" ) "Record":{
                "ProductID": cm.itemId default "",
                "LocationID": if ( cm.locationId != null ) cm.locationId else "",
                "LocationClusterID": if ( cm.locationClusterId != null ) cm.locationClusterId else "",
                "CompetitorID" : if (!isEmpty(competitor.competitorId)) (competitor.competitorId) else '',
                "CompetitorTypeID": codeListCompetitorTypeCode(cm.competitorTypeCode, codelistFlag),
                "CompetitorPrice": if ( cm.competitorPrice != null ) cm.competitorPrice else null,
                "Currency": if ( cm.currencyCode != null ) cm.currencyCode else null,
                "ActiveFrom": if(cm.effectiveFromDate != null and cm.effectiveFromDate != "") cm.effectiveFromDate else defaultFromDate,
                "ActiveUpTo": if(cm.effectiveUpToDate != null and cm.effectiveUpToDate != "") validateDate(cm.effectiveUpToDate) else "9999-12-31"
            }
            else if ( getOperationType(competitor, cm) == "DeleteRecord" and cm.itemId == "*UNKNOWN" and competitor.competitorId == "*UNKNOWN"
                and (cm.locationId == "*UNKNOWN" or cm.locationClusterId == "*UNKNOWN")
            ) "DeleteAllRecords": {
                "ActiveFrom": if(cm.effectiveFromDate != null and cm.effectiveFromDate != "") cm.effectiveFromDate else defaultFromDate,
                "ActiveUpTo": if(cm.effectiveUpToDate != null and cm.effectiveUpToDate != "") validateDate(cm.effectiveUpToDate) else "9999-12-31"
            }
            else if ( getOperationType(competitor,cm) == "DeleteRecord" ) "DeleteRecord" : {
                "ProductID": cm.itemId default "",
                "LocationID": if ( cm.locationId != null ) cm.locationId else "",
                "LocationClusterID": if ( cm.locationClusterId != null ) cm.locationClusterId else "",
                "CompetitorID" : if (!isEmpty(competitor.competitorId)) (competitor.competitorId) else '',
                "ActiveFrom": if(cm.effectiveFromDate != null and cm.effectiveFromDate != "") cm.effectiveFromDate else defaultFromDate,
                "ActiveUpTo": if(cm.effectiveUpToDate != null and cm.effectiveUpToDate != "") validateDate(cm.effectiveUpToDate) else "9999-12-31"
            }
            else{
            })
        })
    })
 )}