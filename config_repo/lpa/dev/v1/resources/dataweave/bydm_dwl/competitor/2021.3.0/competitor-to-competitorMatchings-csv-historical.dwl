%dw 2.0
@StreamCapable()
import * from dw::Runtime
				
fun getOperationType(parent, child) =
	if ( parent.documentActionCode != "DELETE" )
		if (child."competitorMatchingDetails.actionCode" == "ADD" or child."competitorMatchingDetails.actionCode" == "CHANGE") "Record"
		else if (child."competitorMatchingDetails.actionCode" == "DELETE") "DeleteRecord"
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

output application/xml  deferred = true, skipNullOn = "everywhere"
---
"CompetitorMatchings": ({
	(payload map ((competitor, index) -> 
	if ( getOperationType(competitor,competitor) == "Record" ) "Record" : {
			"ProductID": competitor."competitorMatchingDetails.itemId" default "",
			"LocationID": if ( competitor."competitorMatchingDetails.locationId" != null ) competitor."competitorMatchingDetails.locationId" else "",
			"LocationClusterID": if ( competitor."competitorMatchingDetails.locationClusterId" != null ) competitor."competitorMatchingDetails.locationClusterId" else "",
			"CompetitorID" : if (!isEmpty(competitor.competitorId)) (competitor.competitorId) else '',
			"CompetitorTypeID": codeListCompetitorTypeCode(competitor."competitorMatchingDetails.competitorTypeCode", codelistFlag),
			"CompetitorPrice": if ( competitor."competitorMatchingDetails.competitorPrice" != null ) competitor."competitorMatchingDetails.competitorPrice" else null,
			"Currency": if ( competitor."competitorMatchingDetails.currencyCode" != null ) competitor."competitorMatchingDetails.currencyCode" else null,
			"ActiveFrom": if(competitor."competitorMatchingDetails.effectiveFromDate" != null and competitor."competitorMatchingDetails.effectiveFromDate" != "") competitor."competitorMatchingDetails.effectiveFromDate" else "1970-01-01",
			"ActiveUpTo": if(competitor."competitorMatchingDetails.effectiveUpToDate" != null and competitor."competitorMatchingDetails.effectiveUpToDate" != "") competitor."competitorMatchingDetails.effectiveUpToDate" else "9999-12-31"
		}
	else if ( getOperationType(competitor, competitor) == "DeleteRecord" and competitor."competitorMatchingDetails.itemId" == "*UNKNOWN" and competitor.competitorId == "*UNKNOWN"
			and (competitor."competitorMatchingDetails.locationId" == "*UNKNOWN" or competitor."competitorMatchingDetails.locationClusterId" == "*UNKNOWN")
	) "DeleteAllRecords": {
			"ActiveFrom": if(competitor."competitorMatchingDetails.effectiveFromDate" != null and competitor."competitorMatchingDetails.effectiveFromDate" != "") competitor."competitorMatchingDetails.effectiveFromDate" else "1970-01-01",
			"ActiveUpTo": if(competitor."competitorMatchingDetails.effectiveUpToDate" != null and competitor."competitorMatchingDetails.effectiveUpToDate" != "") competitor."competitorMatchingDetails.effectiveUpToDate" else "9999-12-31"
		}
	else if ( getOperationType(competitor,competitor) == "DeleteRecord" ) "DeleteRecord" : {
			"ProductID": competitor."competitorMatchingDetails.itemId" default "",
			"LocationID": if ( competitor."competitorMatchingDetails.locationId" != null ) competitor."competitorMatchingDetails.locationId" else "",
			"LocationClusterID": if ( competitor."competitorMatchingDetails.locationClusterId" != null ) competitor."competitorMatchingDetails.locationClusterId" else "",
			"CompetitorID" : if (!isEmpty(competitor.competitorId)) (competitor.competitorId) else '',
			"ActiveFrom": if(competitor."competitorMatchingDetails.effectiveFromDate" != null and competitor."competitorMatchingDetails.effectiveFromDate" != "") competitor."competitorMatchingDetails.effectiveFromDate" else "1970-01-01",
			"ActiveUpTo": if(competitor."competitorMatchingDetails.effectiveUpToDate" != null and competitor."competitorMatchingDetails.effectiveUpToDate" != "") competitor."competitorMatchingDetails.effectiveUpToDate" else "9999-12-31"
		}
	else {
		}
	))
})

