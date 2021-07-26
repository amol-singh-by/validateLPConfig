%dw 2.0
import * from dw::Runtime
output application/xml deferred = true, skipNullOn = "everywhere"

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

fun checkLocationType(value) =
  if ( value.parentParty.parentRole == "SUPPLIER" ) "EXTERNAL_SUPPLIER"
  else if ( value.parentParty.parentRole == "CUSTOMER" ) "THIRD_PARTY"
  else if ( value.parentParty.parentRole == "CORPORATE_ENTITY" ) 
  	codeListLocationTypeCode(value.basicLocation.locationTypeCode, codelistFlag)
  else "CE_DUMMYTYPE"
  
fun codeListLocationTypeCode(value, codelistFlag) = codelistFlag match {
    case str: "ERROR" -> if((value) != null) 
							jda::CodeMap::keyLookupOptional(vars.codeMap.LocationTypeCode, "LocationTypeCode", value default "") 
						  else ''
    else ->  try(() -> jda::CodeMap::keyLookupOptional(vars.codeMap.LocationTypeCode, "LocationTypeCode", value default "")) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

fun validateDate(date) = try(() -> date as Date) match {
        case theOutput if(theOutput.success ~= false) -> ''
else -> $.result
}
	

var codelistFlag = Mule::p('bydm.canmodel.codeList')

fun codeListIsoTypeCode(value, codelistFlag) =
  codelistFlag match {
	case str: "ERROR" -> if ( (value) != null ) jda::CodeMap::keyLookupWithDefault(vars.codeMap.ISOTypeCode, "ISOTypeCode", value, value)
    else ''
    else -> try(() -> jda::CodeMap::keyLookupWithDefault(vars.codeMap.ISOTypeCode, "ISOTypeCode", value, value)) match {
		case theOutput if(theOutput.success ~= false) -> value
else -> $.result
	}
}

---
Locations : {(payload[vars.bulkType] filter($.documentActionCode != "DELETE") map (value) -> {
			Record: {
				LocationID: if ( value.locationId != null ) value.locationId
		          else "",
				Name: if ( value.basicLocation.locationName != null ) value.basicLocation.locationName
		          else "",
				Description: if ( value.basicLocation.description.value != null and value.basicLocation.description.value != "" ) value.basicLocation.description.value
		          else null,
				Type: checkLocationType(value) default "",
				Country: codeListIsoTypeCode(value.basicLocation.address.countryCode, codelistFlag),
				PostalCode: if ( value.basicLocation.address.postalCode != null ) value.basicLocation.address.postalCode
		          else "",
				City: if ( value.basicLocation.address.city != null ) value.basicLocation.address.city
		          else "",
				Street: if ( value.basicLocation.address.streetAddressOne? and sizeOf(value.basicLocation.address.streetAddressOne splitBy (" ")) > 1 ) (([1 to (sizeOf(value.basicLocation.address.streetAddressOne splitBy (" ")) - 1)] map (value.basicLocation.address.streetAddressOne splitBy (" "))[$])[0] joinBy " " default "")
		          else if ( value.basicLocation.address.streetAddressOne? and sizeOf(value.basicLocation.address.streetAddressOne splitBy (" ")) == 1 ) (value.basicLocation.address.streetAddressOne default "")
		          else null,
				(HouseNumber: if ( (value.basicLocation.address.streetAddressOne splitBy (" "))[0] != null ) (value.basicLocation.address.streetAddressOne splitBy (" "))[0]
          			else null) if (value.basicLocation.address.streetAddressOne? and sizeOf(value.basicLocation.address.streetAddressOne splitBy (" ")) > 1),
				TimeZone: null,
				Region: if ( value.basicLocation.address.state != null and value.basicLocation.address.state != "" ) value.basicLocation.address.state
		          else null,
				SubRegion: if ( value.basicLocation.address.addressRegion != null and value.basicLocation.address.addressRegion != "" ) value.basicLocation.address.addressRegion
		          else null,
				Latitude: if ( value.basicLocation.address.geographicalCoordinates.latitude != null and value.basicLocation.address.geographicalCoordinates.latitude != "" ) value.basicLocation.address.geographicalCoordinates.latitude
		          else null,
				Longitude: if ( value.basicLocation.address.geographicalCoordinates.longitude != null and value.basicLocation.address.geographicalCoordinates.longitude != "" ) value.basicLocation.address.geographicalCoordinates.longitude
		          else null,
				Altitude: null,
				StorageArea: if ( value.logisticDetails.storageAreaSize.value != null and value.logisticDetails.storageAreaSize.value != "" ) value.logisticDetails.storageAreaSize.value
		          else null,
				SalesArea: if ( value.retailDetails.salesAreaSize.value != null and value.retailDetails.salesAreaSize.value != "" ) value.retailDetails.salesAreaSize.value
		          else null,
				ParkingCapacity: if (value.retailDetails.parkingCapacity != null and value.retailDetails.parkingCapacity != "" ) value.retailDetails.parkingCapacity 
		          else null,
		        Brand: if (value.basicLocation.banner != null and value.basicLocation.banner != "" ) value.basicLocation.banner 
		          else null,
		        Format: if (value.retailDetails.storeFormat != null and value.retailDetails.storeFormat != "" ) value.retailDetails.storeFormat 
		          else null,
				OpenDate: null,
				FinalDate: null,
				ActiveFrom: if ( value.basicLocation.status.effectiveFromDate[0] != null and value.basicLocation.status.effectiveFromDate[0] != "" ) (value.basicLocation.status.effectiveFromDate[0] replace "Z" with "")
		          else defaultFromDate,
				ActiveUpTo: if ( value.basicLocation.status.effectiveUpToDate[0] != null and value.basicLocation.status.effectiveUpToDate[0] != "" ) validateDate(value.basicLocation.status.effectiveUpToDate[0] replace "Z" with "")
		          else "9999-12-31"
		}
})}