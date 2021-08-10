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

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemTypeCode(value, codelistFlag) =
  codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)
    else ''
    else -> try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ItemTypeCode, "ItemTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

output application/xml deferred = true, skipNullOn = "everywhere"
---
Products: {
	(payload[vars.bulkType] filter ($.documentActionCode != 'DELETE' and (($.tradeItemUnitDescriptorCode default '') != 'PACK_OR_INNER_PACK')) map (item, index) -> 
      Record: {
		"ProductID": if ( item.itemId.primaryId != null ) item.itemId.primaryId
          else '',
		"Name": if ( (item.itemId.itemName) != null ) (item.itemId.itemName)
          else '',
		"Description": if ( item.description.value != null and item.description.value != "" ) item.description.value
          else null,
		"UnitID": codeListItemTypeCode(item.tradeItemBaseUnitOfMeasure, codelistFlag),
		"ProductGroupID": if ( item.classifications.itemFamilyGroup != null ) item.classifications.itemFamilyGroup
          else '',
		"IsKeyValueItem": if ( item.classifications.isKeyValueItem != null ) item.classifications.isKeyValueItem else null,
		"SalesClassification": if ( item.retailDetails.salesClassification != null ) item.retailDetails.salesClassification else null,
		"Seasonality": if ( item.classifications.itemSeason != null ) item.classifications.itemSeason else null,
		"Size ": if ( item.tradeItemMeasurements.size[0].descriptiveSize.value != null ) item.tradeItemMeasurements.size[0].descriptiveSize.value else null,
		"Color": if ( item.apparelInformation.colour.colourDescription[0].value != null ) item.apparelInformation.colour.colourDescription[0].value else null,
		"Brand ": if ( item.classifications.brandName != null ) item.classifications.brandName else null,
		"Volume": if ( item.tradeItemMeasurements.inBoxCubeDimension.value != null ) item.tradeItemMeasurements.inBoxCubeDimension.value else null,
		"Weight": if ( item.tradeItemMeasurements.tradeItemWeight.grossWeight.value != null ) item.tradeItemMeasurements.tradeItemWeight.grossWeight.value else null,
		"Style": if ( item.apparelInformation.style != null ) item.apparelInformation.style else null,
		"Gender": if ( item.classifications.consumerSegment != null ) item.classifications.consumerSegment else null,
		"Quality": if ( item.classifications.itemQuality != null ) item.classifications.itemQuality else null,
		"Fabric": if ( item.apparelInformation.material != null ) item.apparelInformation.material else null,
		"Sustainability": if ( item.classifications.sustainability != null ) item.classifications.sustainability else null,
		"Gtin": if ( !isEmpty(item.itemId.additionalTradeItemId) ) (item.itemId.additionalTradeItemId filter  $.typeCode == "GTIN_14")[0].value else null,
		"ActiveFrom": if ( item.status.effectiveFromDateTime[0] != null and item.status.effectiveFromDateTime[0] != "" ) (item.status.effectiveFromDateTime[0] splitBy "T")[0]
          else defaultFromDate,
		"ActiveUpTo": if ( item.status.effectiveUpToDateTime[0] != null and item.status.effectiveUpToDateTime[0] != "" ) validateDate((item.status.effectiveUpToDateTime[0] splitBy "T")[0])
          else '9999-12-31'
	})
}