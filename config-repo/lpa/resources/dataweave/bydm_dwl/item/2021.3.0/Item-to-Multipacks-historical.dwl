%dw 2.0
import * from dw::Runtime

fun getOperationType(documentActionCode) =
  if ( documentActionCode == "ADD" or documentActionCode == "CHANGE_BY_REFRESH" ) "Record"
  else if ( documentActionCode == "DELETE" ) "DeleteRecord"
  else "Record"
  
output application/xml deferred = true, skipNullOn = "everywhere"
---
"Multipacks": {(
    (payload[vars.bulkType] filter ((($.tradeItemUnitDescriptorCode default '') == 'PACK_OR_INNER_PACK') and $.childItem.quantityOfChildren  != null and $.childItem.quantityOfChildren as Number <= 1) map(item,index) -> {
            (if ( getOperationType(item.documentActionCode) == "Record" ) "Record":{
                "MultipackProductID": item.itemId.primaryId default "",
				"ItemProductID": item.childItem.childTradeItem[0].primaryId default "",
				"NumberOfItems": item.childItem.childTradeItem[0].quantityOfNextLowerLevelTradeItem default "",
				"ActiveFrom": if ( item.status != null and (item.status[0].effectiveFromDateTime) != null and (item.status[0].effectiveFromDateTime) != "" ) (item.status[0].effectiveFromDateTime splitBy "T")[0] else '1970-01-01',
				"ActiveUpTo": if ( item.status != null and (item.status[0].effectiveUpToDateTime) != null and (item.status[0].effectiveUpToDateTime) != "" ) (item.status[0].effectiveUpToDateTime splitBy "T")[0] else '9999-12-31'
           }
            else if ( getOperationType(item.documentActionCode) == "DeleteRecord" and (item.itemId.primaryId == "*UNKNOWN" or item.childItem.childTradeItem[0].primaryId == "*UNKNOWN")
            ) "DeleteAllRecords": {
                "MultipackProductID": if (item.itemId.primaryId != "*UNKNOWN") item.itemId.primaryId else null,
				"ItemProductID": if (item.childItem.childTradeItem[0].primaryId != "*UNKNOWN") item.childItem.childTradeItem[0].primaryId else null,
				"ActiveFrom": if ( item.status != null and (item.status[0].effectiveFromDateTime) != null and (item.status[0].effectiveFromDateTime) != "" ) (item.status[0].effectiveFromDateTime splitBy "T")[0] else '1970-01-01',
				"ActiveUpTo": if ( item.status != null and (item.status[0].effectiveUpToDateTime) != null and (item.status[0].effectiveUpToDateTime) != "" ) (item.status[0].effectiveUpToDateTime splitBy "T")[0] else '9999-12-31'
            }
            else if ( getOperationType(item.documentActionCode) == "DeleteRecord" ) "DeleteRecord" : {
                "MultipackProductID": item.itemId.primaryId default "",
				"ItemProductID": item.childItem.childTradeItem[0].primaryId default "",
				"ActiveFrom": if ( item.status != null and (item.status[0].effectiveFromDateTime) != null and (item.status[0].effectiveFromDateTime) != "" ) (item.status[0].effectiveFromDateTime splitBy "T")[0] else '1970-01-01',
				"ActiveUpTo": if ( item.status != null and (item.status[0].effectiveUpToDateTime) != null and (item.status[0].effectiveUpToDateTime) != "" ) (item.status[0].effectiveUpToDateTime splitBy "T")[0] else '9999-12-31'
            }
            else{
            })
    })
 )}