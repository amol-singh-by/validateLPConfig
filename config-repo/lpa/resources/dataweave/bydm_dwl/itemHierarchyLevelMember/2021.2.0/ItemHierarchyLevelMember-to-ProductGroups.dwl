%dw 2.0
output application/xml deferred = true, skipNullOn = "everywhere"
---
ProductGroups: {
	(payload[vars.bulkType] filter($.documentActionCode != "DELETE") map ((item, index) -> 
	Record: {
		"ProductGroupID": if ( !isEmpty(item.itemHierarchyInformation.hierarchyLevelId) ) item.itemHierarchyInformation.hierarchyLevelId else "",
		"ParentGroupID": if(!isEmpty(item.itemHierarchyInformation.ancestry[0].hierarchyLevelId)) item.itemHierarchyInformation.ancestry[0].hierarchyLevelId else null,
		"Name": if ( !isEmpty(item.itemHierarchyInformation.memberName) ) item.itemHierarchyInformation.memberName else "",
		"Description": if ( !isEmpty(item.description[0].value) ) item.description[0].value else null
	}
))
}