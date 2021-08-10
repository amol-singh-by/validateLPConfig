%dw 2.0
import * from dw::Runtime

fun getOperationType(parent) =
  if (parent.documentActionCode != "DELETE")
    "Record"
  else
    "DeleteRecord"

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListItemLocationTypeCode(value, codelistFlag) =
  codelistFlag match {
    case str: "ERROR" -> if ((value) != null)
      jda::CodeMap::keyLookupOptional(vars.codeMap.ItemLocationTypeCode, "ItemLocationTypeCode", value default "")
    else
      ''
    else -> try(() -> jda::CodeMap::keyLookupOptional(vars.codeMap.ItemLocationTypeCode, "ItemLocationTypeCode", value default "")) match {
      case theOutput if theOutput.success ~= false -> value
      else -> $.result
    }
  }
output application/xml  deferred=true, skipNullOn="everywhere"
---

  Assignments: {
    ((payload[vars.bulkType] filter (() -> (($.includesAvailability default 'false') ~= 'true'))) map (item, index) -> {
      (item.availability map (avail, index) -> if ((getOperationType(item) == "DeleteRecord") and (item.itemLocationId.item.primaryId == "*UNKNOWN" or item.itemLocationId.location.primaryId == "*UNKNOWN" or avail."type" == "*UNKNOWN"))

            "DeleteAllRecords": {
              "ProductID": 
                if (!isEmpty(item.itemLocationId.item.primaryId) and (item.itemLocationId.item.primaryId != "*UNKNOWN"))
                  item.itemLocationId.item.primaryId
                else
                  null,
              "LocationID": 
                if (!isEmpty(item.itemLocationId.location.primaryId) and (item.itemLocationId.location.primaryId != "*UNKNOWN"))
                  item.itemLocationId.location.primaryId
                else
                  null,
              "Type": 
                if (!isEmpty(avail."type") and (avail."type" != "*UNKNOWN"))
                  codeListItemLocationTypeCode(avail."type", codelistFlag)
                else
                  null,
              "ActiveFrom": 
                if (!isEmpty(avail.effectiveFromDate))
                  avail.effectiveFromDate
                else
                  "1970-01-01",
              "ActiveUpTo": 
                if (!isEmpty(avail.effectiveUpToDate))
                  avail.effectiveUpToDate
                else
                  "9999-12-31"
            }

        else

            (getOperationType(item)): {
              "ProductID": 
                if (item.itemLocationId.item.primaryId != null)
                  item.itemLocationId.item.primaryId
                else
                  "",
              "LocationID": 
                if (item.itemLocationId.location.primaryId != null)
                  item.itemLocationId.location.primaryId
                else
                  "",
              "Type": codeListItemLocationTypeCode(avail."type", codelistFlag),
              "ActiveFrom": 
                if (!isEmpty(avail.effectiveFromDate))
                  avail.effectiveFromDate
                else
                  "1970-01-01",
              "ActiveUpTo": 
                if (!isEmpty(avail.effectiveUpToDate))
                  avail.effectiveUpToDate
                else
                  "9999-12-31"
            }
      )
    })
  }
