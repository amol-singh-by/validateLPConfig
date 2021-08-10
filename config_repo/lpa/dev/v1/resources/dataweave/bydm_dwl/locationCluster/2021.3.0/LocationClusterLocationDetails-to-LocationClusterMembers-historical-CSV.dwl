%dw 2.0
import * from dw::Runtime
output application/xml  skipNullOn = "everywhere", deferred = true

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

fun getOperationType(parent, child) =
	if ( parent.documentActionCode != "DELETE" )
		if (child.'locationClusterLocationDetails.actionCode' == "ADD" or child.'locationClusterLocationDetails.actionCode' == "CHANGE") "Record"
		else if (child.'locationClusterLocationDetails.actionCode' == "DELETE") "DeleteRecord"
		else "Record"
	else "DeleteRecord"

fun transformLocationClusterMembers(cluster) = {
	Record: {
		LocationClusterID: cluster.locationClusterId default '',
		LocationID: cluster.'locationClusterLocationDetails.locationId' default null,
		ActiveFrom: if (!isEmpty(cluster.'locationClusterLocationDetails.effectiveFromDate')) cluster.'locationClusterLocationDetails.effectiveFromDate' else '1970-01-01',
		ActiveUpTo: if (!isEmpty(cluster.'locationClusterLocationDetails.effectiveUpToDate')) validateDate(cluster.'locationClusterLocationDetails.effectiveUpToDate') else '9999-12-31'
	}
}
fun transformDeleteLocationClusterMembers(cluster) = {
	DeleteRecord: {
		LocationClusterID: cluster.locationClusterId default '',
		LocationID: cluster.'locationClusterLocationDetails.locationId' default null,
		ActiveFrom: if (!isEmpty(cluster.'locationClusterLocationDetails.effectiveFromDate')) cluster.'locationClusterLocationDetails.effectiveFromDate' else '1970-01-01',
		ActiveUpTo: if (!isEmpty(cluster.'locationClusterLocationDetails.effectiveUpToDate')) validateDate(cluster.'locationClusterLocationDetails.effectiveUpToDate') else '9999-12-31'
	}
}
fun transformDeleteAllLocationClusterMembers(cluster) = {
	DeleteAllRecords: {
		(LocationClusterID: cluster.locationClusterId default '') if  cluster.locationClusterId != null and cluster.locationClusterId != '*UNKNOWN',
		(LocationID: cluster.'locationClusterLocationDetails.locationId' default null) if cluster.'locationClusterLocationDetails.locationId' != null and cluster.'locationClusterLocationDetails.locationId' != '*UNKNOWN',
        ActiveFrom: if (!isEmpty(cluster.'locationClusterLocationDetails.effectiveFromDate')) cluster.'locationClusterLocationDetails.effectiveFromDate' else '1970-01-01',
		ActiveUpTo: if (!isEmpty(cluster.'locationClusterLocationDetails.effectiveUpToDate')) validateDate(cluster.'locationClusterLocationDetails.effectiveUpToDate') else '9999-12-31'
	}
}
---
LocationClusterMembers: {
	(payload default [] map(cluster,index) -> {
			(if (getOperationType(cluster, cluster) == 'DeleteRecord' and (cluster.'locationClusterLocationDetails.locationId' == '*UNKNOWN' or cluster.locationClusterId == '*UNKNOWN') ) 
				transformDeleteAllLocationClusterMembers(cluster)
			else if (getOperationType(cluster, cluster) == 'DeleteRecord') 
				transformDeleteLocationClusterMembers(cluster)
			else transformLocationClusterMembers(cluster))
	})
}

