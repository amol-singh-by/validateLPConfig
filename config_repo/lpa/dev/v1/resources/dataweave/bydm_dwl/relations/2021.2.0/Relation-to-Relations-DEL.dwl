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

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

var relationsPayload = payload[vars.bulkType] filter(o,i) ->(o.relationId.relationType == 'RELATION')

fun getComponentTypeObject(componentObj, searchType) = ({(componentObj filter ($.componentType == searchType))})

fun getOperationType(relation) =
	if ( relation.documentActionCode != "DELETE" ) "DeleteRecord"
	else if ( relation.documentActionCode == "DELETE" ) "Record"
	else "DeleteRecord"

output application/xml deferred = true, skipNullOn = "everywhere"
---
Relations: {
	(relationsPayload map() -> if (getOperationType($) == "DeleteRecord") DeleteRecord: {
		"ProductID": getComponentTypeObject($.relatedComponent,"ITEM").relatedTo,
		"ReferenceProductID": getComponentTypeObject($.relatedComponent,"ITEM").relatedFrom,
		"LocationID": getComponentTypeObject($.relatedComponent,"LOCATION").relatedTo,
		"ReferenceLocationID": getComponentTypeObject($.relatedComponent,"LOCATION").relatedFrom,
		"ProductGroupID": getComponentTypeObject($.relatedComponent,"HIERARCHY").relatedTo,
		"ReferenceProductGroupID": getComponentTypeObject($.relatedComponent,"HIERARCHY").relatedFrom,
		"Type": if ($.relationSubType != null) $.relationSubType else "",
		"ActiveFrom": if (!isEmpty($.effectiveFromDate)) $.effectiveFromDate else defaultFromDate,
		"ActiveUpTo": if (!isEmpty($.effectiveUpToDate)) validateDate($.effectiveUpToDate) else "9999-12-31"
	} else {
	})
}