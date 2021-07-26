%dw 2.0
import * from dw::Runtime

fun getOperationType(stocks) =
	if ( stocks.documentActionCode == "ADD" or stocks.documentActionCode == "CHANGE_BY_REFRESH" ) "Record"
	else if ( stocks.documentActionCode == "DELETE" ) "DeleteRecord"
	else "Record"
    
var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemTypeCode(value, codelistFlag) = codelistFlag match {
    case str: "ERROR" -> if((value) != null) 
							jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value) 
						  else ''
    else ->  try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
"Stocks": {(
    (payload[vars.bulkType] map (stocks,index) -> {
            (if ( getOperationType(stocks) == "Record" ) "Record":{
                ProductID: if ( stocks.itemId != null ) stocks.itemId else "",
				LocationID: if ( stocks.locationId != null ) stocks.locationId else "",
				ValidDay: if ( stocks.availableForSupplyDate != null ) stocks.availableForSupplyDate replace "Z" with "" else "",
				ValidDayUpTo: if ( stocks.availableForSupplyEndDate != null and stocks.availableForSupplyEndDate != "" and vars.stocksLazyMode) stocks.availableForSupplyEndDate else null,
				Timestamp: if ( stocks.onHandPostDateTime != null ) stocks.onHandPostDateTime else null,
				Type: "INVENTORY",
				UnitID: codeListItemTypeCode( stocks.quantity.measurementUnitCode, codelistFlag),
				Quantity: if ( stocks.quantity.value != null ) stocks.quantity.value else "",
				ExpirationDay: if ( stocks.bestBeforeDate != null and stocks.bestBeforeDate != "" ) stocks.bestBeforeDate replace "Z" with  "" else null
            }
            else if ( getOperationType(stocks) == "DeleteRecord" and vars.stocksLazyMode and (stocks.itemId == "*UNKNOWN" or stocks.locationId == "*UNKNOWN")
            ) "DeleteAllRecords": {
                ProductID: if ( stocks.itemId != null and stocks.itemId != "*UNKNOWN") stocks.itemId else null,
				LocationID: if ( stocks.locationId != null and stocks.locationId != "*UNKNOWN" ) stocks.locationId else null,
				ValidDay: if ( stocks.availableForSupplyDate != null ) stocks.availableForSupplyDate replace "Z" with "" else "",
				ValidDayUpTo: if ( stocks.availableForSupplyEndDate != null and stocks.availableForSupplyEndDate != "" ) stocks.availableForSupplyEndDate else null,
				Timestamp: if ( stocks.onHandPostDateTime != null ) stocks.onHandPostDateTime else null,
				Type: "INVENTORY",
				UnitID: codeListItemTypeCode( stocks.quantity.measurementUnitCode, codelistFlag)
            }
            else if ( getOperationType(stocks) == "DeleteRecord" and vars.stocksLazyMode) "DeleteRecord" : {
                ProductID: if ( stocks.itemId != null ) stocks.itemId else "",
				LocationID: if ( stocks.locationId != null ) stocks.locationId else "",
				ValidDay: if ( stocks.availableForSupplyDate != null ) stocks.availableForSupplyDate replace "Z" with "" else "",
				ValidDayUpTo: if ( stocks.availableForSupplyEndDate != null and stocks.availableForSupplyEndDate != "" ) stocks.availableForSupplyEndDate else null,
				Timestamp: if ( stocks.onHandPostDateTime != null ) stocks.onHandPostDateTime else null,
				Type: "INVENTORY",
				UnitID: codeListItemTypeCode( stocks.quantity.measurementUnitCode, codelistFlag)
            }
            else{
            })
    })
 )}
