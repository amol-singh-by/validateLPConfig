%dw 2.0

output application/xml deferred = true, skipNullOn = "everywhere"
---
Products: ({
	(payload[vars.bulkType] filter($.documentActionCode != "DELETE") map (demandUnit, index) -> 
      Record: {
		"ProductID": if ( (demandUnit.demandUnitId) != null ) (demandUnit.demandUnitId)
          else "",
		"Name": if ( (demandUnit.demandUnitId) != null ) (demandUnit.demandUnitId)
          else "",
		"Description": if ( (demandUnit.demandUnitDetails.descriptionvalue.value) != null ) (demandUnit.demandUnitDetails.description.value)
          else null,
		"UnitID": 'PCS',
		"ProductGroupID": if ( demandUnit.demandUnitHierarchyInformation.ancestry.memberId != null ) demandUnit.demandUnitHierarchyInformation.ancestry.memberId
          else "",
		"ActiveFrom": "1970-01-01",
		"ActiveUpTo": '9999-12-31'
	})
})
