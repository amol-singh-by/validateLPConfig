%dw 2.0
@StreamCapable()

output application/xml  deferred = true, skipNullOn = "everywhere"
---
"Competitors": {
	"Record" : payload filter ($.documentActionCode != 'DELETE' and $.competitorId != "*UNKNOWN") map ((competitor , index) -> {
		"CompetitorID" : if (!isEmpty(competitor.competitorId)) (competitor.competitorId) else '',
		"Name" : if (!isEmpty(competitor.competitorName)) (competitor.competitorName) else '',
		("Description" : competitor.description) if (!isEmpty(competitor.description))
	})
}