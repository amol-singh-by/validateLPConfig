%dw 2.0
import * from dw::Runtime

var relationsPayload = payload[vars.bulkType] filter(o,i) ->(o.relationId.relationType == 'RELATION')

fun getComponentTypeObject(componentObj, searchType) = ({(componentObj filter ($.componentType == searchType))})
fun getRelatedTo(componentObj, searchType) = ({(componentObj filter ($.componentType == searchType and $.relatedTo != "*UNKNOWN"))})
fun getRelatedFrom(componentObj, searchType) = ({(componentObj filter ($.componentType == searchType and $.relatedFrom != "*UNKNOWN"))})

fun getOperationType(relation) =
	if (relation.documentActionCode == "ADD" or relation.documentActionCode == "CHANGE_BY_REFRESH") "Record"
	else if (relation.documentActionCode == "DELETE") "DeleteRecord"
	else "Record"

output application/xml deferred = true, skipNullOn = "everywhere"
---
"Relations": {(
    (relationsPayload map(relation,index) -> {
            (if ( getOperationType(relation) == "Record" ) "Record":{
                "ProductID": getComponentTypeObject(relation.relatedComponent,"ITEM").relatedTo,
				"ReferenceProductID": getComponentTypeObject(relation.relatedComponent,"ITEM").relatedFrom,
				"LocationID": getComponentTypeObject(relation.relatedComponent,"LOCATION").relatedTo,
				"ReferenceLocationID": getComponentTypeObject(relation.relatedComponent,"LOCATION").relatedFrom,
				"ProductGroupID": getComponentTypeObject(relation.relatedComponent,"HIERARCHY").relatedTo,
				"ReferenceProductGroupID": getComponentTypeObject(relation.relatedComponent,"HIERARCHY").relatedFrom,
				"Type": if ( relation.relationSubType != null ) relation.relationSubType else "",
				"ScaleFactor": if ( relation.scaleFactor != null and relation.scaleFactor != "" ) relation.scaleFactor else 1,
				"ActiveFrom": if (!isEmpty(relation.effectiveFromDate)) relation.effectiveFromDate else "1970-01-01",
				"ActiveUpTo": if (!isEmpty(relation.effectiveUpToDate)) relation.effectiveUpToDate else "9999-12-31"
           }
           else if ( getOperationType(relation) == "DeleteRecord" and isEmpty(relation.relationSubType)) "DeleteAllRecords": {
                "ProductID": getRelatedTo(relation.relatedComponent,"ITEM").relatedTo,
				"ReferenceProductID": getRelatedFrom(relation.relatedComponent,"ITEM").relatedFrom,
				"LocationID": getRelatedTo(relation.relatedComponent,"LOCATION").relatedTo,
				"ReferenceLocationID": getRelatedFrom(relation.relatedComponent,"LOCATION").relatedFrom,
				"ProductGroupID": getRelatedTo(relation.relatedComponent,"HIERARCHY").relatedTo,
				"ReferenceProductGroupID": getRelatedFrom(relation.relatedComponent,"HIERARCHY").relatedFrom,
				"ActiveFrom": if (!isEmpty(relation.effectiveFromDate)) relation.effectiveFromDate else "1970-01-01",
				"ActiveUpTo": if (!isEmpty(relation.effectiveUpToDate)) relation.effectiveUpToDate else "9999-12-31"
            }
            else if ( getOperationType(relation) == "DeleteRecord" ) "DeleteRecord" : {
                "ProductID": getRelatedTo(relation.relatedComponent,"ITEM").relatedTo,
				"ReferenceProductID": getRelatedFrom(relation.relatedComponent,"ITEM").relatedFrom,
				"LocationID": getRelatedTo(relation.relatedComponent,"LOCATION").relatedTo,
				"ReferenceLocationID": getRelatedFrom(relation.relatedComponent,"LOCATION").relatedFrom,
				"ProductGroupID": getRelatedTo(relation.relatedComponent,"HIERARCHY").relatedTo,
				"ReferenceProductGroupID": getRelatedFrom(relation.relatedComponent,"HIERARCHY").relatedFrom,
				"Type": if (relation.relationSubType != null) relation.relationSubType else "",
				"ActiveFrom": if (!isEmpty(relation.effectiveFromDate)) relation.effectiveFromDate else "1970-01-01",
				"ActiveUpTo": if (!isEmpty(relation.effectiveUpToDate)) relation.effectiveUpToDate else "9999-12-31"
            }
            else{
            })
    })
 )}