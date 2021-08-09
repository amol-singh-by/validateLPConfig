%dw 2.0
output application/xml deferred = true, skipNullOn = "everywhere"
---
LocationClusters : {
     (payload.locationCluster default [] filter ($.documentActionCode != 'DELETE' and $.locationClusterId != '*UNKNOWN') map(cluster,index) -> {
         Record : {
             LocationClusterID : cluster.locationClusterId default '',
             Name : cluster.clusterName default '',
             Description : cluster.clusterDescription default null,
             Type : cluster.clusterTypeCode default ''
         }
     })
}
