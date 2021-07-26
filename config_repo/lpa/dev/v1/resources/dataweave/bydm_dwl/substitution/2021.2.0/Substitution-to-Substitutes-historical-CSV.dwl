%dw 2.0
@StreamCapable()
import * from dw::Runtime
output application/xml deferred = true, skipNullOn="everywhere"

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}

fun tranformSubstitutes(substitute) =
    if ( substitute.documentActionCode == "ADD" or substitute.documentActionCode == "CHANGE_BY_REFRESH" ) tranformRecord(substitute)
   	else if ( substitute.documentActionCode == "DELETE" ) tranformDelete(substitute)
   	else tranformRecord(substitute)

fun tranformDeleteAllRecord(substitute) = DeleteAllRecords : {
    CanBeSubstitutedFrom : substitute.effectiveFromDate default "",
    CanBeSubstitutedUpTo : substitute.effectiveUpToDate default ""
}    

fun tranformDelete(substitute) = if ((substitute."substitutionId.item" default "") == "DELETE_ALL_SUBSTITUTIONS")
tranformDeleteAllRecord(substitute) else tranformDeleteRecord(substitute)


fun tranformDeleteRecord(substitute) = DeleteRecord : {
     ProductID : substitute."substitutionId.item" default "",
    SubstituteProductID: substitute."substitutionId.substituteItem" default "",
    (LocationIDTarget : substitute."substitutionId.shipTo") if !isBlank(substitute."substitutionId.shipTo"),
    CanBeSubstitutedFrom: if((substitute.effectiveFromDate) != null and (substitute.effectiveFromDate) != "") ((substitute.effectiveFromDate splitBy "T")[0]) else "1970-01-01",
	CanBeSubstitutedUpTo: if((substitute.effectiveUpToDate) != null and (substitute.effectiveUpToDate) != "") validateDate((substitute.effectiveUpToDate splitBy "T")[0]) else '9999-12-31'
    
}
fun tranformRecord(substitute) = Record : {
    ProductID : substitute."substitutionId.item" default "",
    SubstituteProductID: substitute."substitutionId.substituteItem" default "",
    (LocationIDTarget : substitute."substitutionId.shipTo") if !isBlank(substitute."substitutionId.shipTo"),
    CanBeSubstitutedFrom: if((substitute.effectiveFromDate) != null and (substitute.effectiveFromDate) != "") ((substitute.effectiveFromDate splitBy "T")[0]) else "1970-01-01",
	CanBeSubstitutedUpTo: if((substitute.effectiveUpToDate) != null and (substitute.effectiveUpToDate) != "") validateDate((substitute.effectiveUpToDate splitBy "T")[0]) else '9999-12-31'
    
}


---
Substitutes : 
({( (payload map (substitute) -> {
    (tranformSubstitutes(substitute))
})) })