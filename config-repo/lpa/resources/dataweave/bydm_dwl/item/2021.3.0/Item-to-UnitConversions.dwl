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
UnitConversions: {
	(payload[vars.bulkType] filter ($.documentActionCode != 'DELETE' and (($.tradeItemUnitDescriptorCode default '') != 'PACK_OR_INNER_PACK') and ($.measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode default [] contains $.tradeItemBaseUnitOfMeasure) ) map((item,index) -> 
	Record: {
		"UnitID": codeListItemTypeCode(item.measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode[0], codelistFlag),
		"ProductID": if ( (item.itemId.primaryId) != null ) item.itemId.primaryId else '',
		"ConversionFactor": if ( item.measurementTypeConversion.ratioOfTargetPerSource[0] != null and item.measurementTypeConversion.ratioOfTargetPerSource[0] != '' ) item.measurementTypeConversion.ratioOfTargetPerSource[0] else "",
		"ActiveFrom": if ( upper(item.status.statusCode[0]) == "ACTIVE" and item.status.effectiveFromDateTime[0] != null and item.status.effectiveFromDateTime[0] != "" ) (item.status.effectiveFromDateTime[0] splitBy "T")[0] else defaultFromDate,
		"ActiveUpTo": if ( upper(item.status.statusCode[0]) == "ACTIVE" and item.status.effectiveUpToDateTime[0] != null and item.status.effectiveUpToDateTime[0] != "" ) validateDate((item.status.effectiveUpToDateTime[0] splitBy "T")[0]) else '9999-12-31'
	}
))
}