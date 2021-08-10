%dw 2.0
@StreamCapable()
import * from dw::Runtime
output application/xml deferred = true, skipNullOn="everywhere"

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

fun tranformSubstitutes(substitute) =
    if ( substitute.documentActionCode == "ADD" or substitute.documentActionCode == "CHANGE_BY_REFRESH" ) tranformRecord(substitute)
   	else if ((substitute.documentActionCode == "DELETE") and (substitute."substitutionId.item" == "*UNKNOWN" or substitute."substitutionId.substituteItem" == "*UNKNOWN" or substitute."substitutionId.shipTo" == "*UNKNOWN")) tranformDeleteAllRecord(substitute)
   	else if (substitute.documentActionCode == "DELETE") tranformDeleteRecord(substitute)
   	else tranformRecord(substitute)

fun tranformDeleteAllRecord(substitute) = DeleteAllRecords : {
	ProductID : if(!isEmpty(substitute."substitutionId.item") and substitute."substitutionId.item" != "*UNKNOWN") substitute."substitutionId.item" else null,
	SubstituteProductID: if(!isEmpty(substitute."substitutionId.substituteItem") and substitute."substitutionId.substituteItem" != "*UNKNOWN") substitute."substitutionId.substituteItem" else null,
	LocationIDTarget : if(!isEmpty(substitute."substitutionId.shipTo") and substitute."substitutionId.shipTo" != "*UNKNOWN") substitute."substitutionId.shipTo" else null,
	CanBeSubstitutedFrom: if((substitute.effectiveFromDate) != null and (substitute.effectiveFromDate) != "") ((substitute.effectiveFromDate splitBy "T")[0]) else (defaultFromDate),
	CanBeSubstitutedUpTo: if((substitute.effectiveUpToDate) != null and (substitute.effectiveUpToDate) != "") validateDate((substitute.effectiveUpToDate splitBy "T")[0]) else '9999-12-31'   
}    

fun tranformDeleteRecord(substitute) = DeleteRecord : {
     ProductID : substitute."substitutionId.item" default "",
    SubstituteProductID: substitute."substitutionId.substituteItem" default "",
    (LocationIDTarget : substitute."substitutionId.shipTo") if !isBlank(substitute."substitutionId.shipTo"),
    CanBeSubstitutedFrom: if((substitute.effectiveFromDate) != null and (substitute.effectiveFromDate) != "") ((substitute.effectiveFromDate splitBy "T")[0]) else (defaultFromDate),
	CanBeSubstitutedUpTo: if((substitute.effectiveUpToDate) != null and (substitute.effectiveUpToDate) != "") validateDate((substitute.effectiveUpToDate splitBy "T")[0]) else '9999-12-31'
    
}
fun tranformRecord(substitute) = Record : {
    ProductID : substitute."substitutionId.item" default "",
    SubstituteProductID: substitute."substitutionId.substituteItem" default "",
    (LocationIDTarget : substitute."substitutionId.shipTo") if !isBlank(substitute."substitutionId.shipTo"),
    CanBeSubstitutedFrom: if((substitute.effectiveFromDate) != null and (substitute.effectiveFromDate) != "") ((substitute.effectiveFromDate splitBy "T")[0]) else (defaultFromDate),
	CanBeSubstitutedUpTo: if((substitute.effectiveUpToDate) != null and (substitute.effectiveUpToDate) != "") validateDate((substitute.effectiveUpToDate splitBy "T")[0]) else '9999-12-31'
    
}


---
Substitutes : 
({( (payload map (substitute) -> {
    (tranformSubstitutes(substitute))
})) })