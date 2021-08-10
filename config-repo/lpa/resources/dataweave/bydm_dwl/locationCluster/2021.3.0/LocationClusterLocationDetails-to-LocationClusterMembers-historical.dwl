%dw 2.0
import * from dw::Runtime
output application/xml  skipNullOn = "everywhere", deferred = true

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

fun transformLocationClusterMembers(cluster,clusterMember) = {
	Record : {
		LocationClusterID: cluster.locationClusterId default '',
		LocationID: clusterMember.locationId default '',
		ActiveFrom: if (!isEmpty(clusterMember.effectiveFromDate)) clusterMember.effectiveFromDate else '1970-01-01',
		ActiveUpTo: if (!isEmpty(clusterMember.effectiveUpToDate)) validateDate(clusterMember.effectiveUpToDate) else "9999-12-31"
	}
}
fun transformDeleteLocationClusterMembers(cluster,clusterMember) = {
	DeleteRecord : {
		LocationClusterID: cluster.locationClusterId default '',
		LocationID: clusterMember.locationId default '',
		ActiveFrom: if (!isEmpty(clusterMember.effectiveFromDate)) clusterMember.effectiveFromDate else '1970-01-01',
		ActiveUpTo: if (!isEmpty(clusterMember.effectiveUpToDate)) validateDate(clusterMember.effectiveUpToDate) else "9999-12-31"
	}
}
fun transformDeleteAllLocationClusterMembers(cluster,clusterMember) = {
	DeleteAllRecords : {
        (LocationClusterID: cluster.locationClusterId default '') if cluster.locationClusterId != null and cluster.locationClusterId != '*UNKNOWN',
		(LocationID: clusterMember.locationId default '') if clusterMember.locationId != null and clusterMember.locationId != '*UNKNOWN',
		ActiveFrom: if (!isEmpty(clusterMember.effectiveFromDate)) clusterMember.effectiveFromDate else '1970-01-01',
		ActiveUpTo: if (!isEmpty(clusterMember.effectiveUpToDate)) validateDate(clusterMember.effectiveUpToDate) else "9999-12-31"
	}
}
---
LocationClusterMembers: {
	(payload.locationCluster default [] map(cluster,index) -> {
		(cluster.locationClusterLocationDetails map (clusterMember,index) -> {
			(if (getOperationType(cluster,clusterMember) == 'DeleteRecord' and (clusterMember.locationId == '*UNKNOWN' or  cluster.locationClusterId == '*UNKNOWN'))
				transformDeleteAllLocationClusterMembers(cluster, clusterMember)
			else if (getOperationType(cluster,clusterMember) == 'DeleteRecord')	 
				transformDeleteLocationClusterMembers(cluster, clusterMember)
			else transformLocationClusterMembers(cluster,clusterMember))
		})
	})
}