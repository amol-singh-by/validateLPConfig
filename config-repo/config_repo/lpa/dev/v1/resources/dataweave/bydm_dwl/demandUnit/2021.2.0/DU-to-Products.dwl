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
					  
output application/xml deferred = true, skipNullOn = "everywhere"				  
---
Products: {
	(payload[vars.bulkType] filter($.documentActionCode != "DELETE") map (demandUnit, index) -> 
      Record: {
		"ProductID": if ( (demandUnit.demandUnitId) != null ) (demandUnit.demandUnitId)
          else "",
		"Name": if ( (demandUnit.demandUnitId) != null ) (demandUnit.demandUnitId)
          else "",
		"Description": if ( demandUnit.demandUnitDetails.description.value != null and demandUnit.demandUnitDetails.description.value != "" ) demandUnit.demandUnitDetails.description.value
          else null,
		"UnitID": 'PCS',
		"ProductGroupID": if ( demandUnit.demandUnitHierarchyInformation.ancestry.memberId != null ) demandUnit.demandUnitHierarchyInformation.ancestry.memberId
          else "",
		"ActiveFrom": defaultFromDate,
		"ActiveUpTo": '9999-12-31'
	})
}