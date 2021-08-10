%dw 2.0
import * from dw::Runtime
fun getOperationType(obj) =
  if ((obj.itemId == "*UNKNOWN" or isEmpty(obj.itemId) 
  	or obj.locationId == "*UNKNOWN" or isEmpty(obj.locationId) 
  	or obj.priceType == "*UNKNOWN" or isEmpty(obj.priceType)
  ) and (obj.documentActionCode == "DELETE")) "DeleteAllRecords"
  else if ( obj.documentActionCode == "DELETE" ) "DeleteRecord"
  else "Record"
  
fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
Prices: {
	(payload[vars.bulkType] filter (getOperationType($) == 'Record') map (item, index) -> 
	{
		"DeleteRecord": {
			ProductID: if ( item.itemId != null ) item.itemId else "",
			LocationID: if ( item.locationId != null ) item.locationId else "",
			Type: if ( item.priceType != null ) item.priceType else "",
			ActiveFrom: if ( item.priceEffectiveFromDate != null and item.priceEffectiveFromDate != "") item.priceEffectiveFromDate else "",
			ActiveUpTo: if ( item.priceEffectiveUpToDate != null and item.priceEffectiveFromDate != "") validateDate(item.priceEffectiveUpToDate) else ""
		}
	})
}