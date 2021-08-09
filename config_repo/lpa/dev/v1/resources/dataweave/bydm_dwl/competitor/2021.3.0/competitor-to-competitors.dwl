%dw 2.0
@StreamCapable()
import * from dw::Runtime
output application/xml deferred = true, skipNullOn = "everywhere"
---
"Competitors": {
	(payload[vars.bulkType] filter ($.documentActionCode != 'DELETE' and $.competitorId != "*UNKNOWN") map (competitor, index) -> 
	"Record" : {
		"CompetitorID" : if (!isEmpty(competitor.competitorId)) (competitor.competitorId) else '',
		"Name" : if (!isEmpty(competitor.competitorName)) (competitor.competitorName) else '',
		("Description" : competitor.description) if (!isEmpty(competitor.description))
	})
}