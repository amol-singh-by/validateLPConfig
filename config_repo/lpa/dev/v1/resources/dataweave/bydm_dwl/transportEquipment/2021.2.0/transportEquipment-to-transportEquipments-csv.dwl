%dw 2.0
@StreamCapable()
output application/xml  deferred = true, skipNullOn = "everywhere"

---
TransportEquipments : {
	"Record" : payload filter($.documentActionCode != "DELETE") map ((transportEquipment , index) -> {
		TransportEquipmentID : if (!isEmpty(transportEquipment."transportEquipmentId")) (transportEquipment."transportEquipmentId") else '',
		(Description : transportEquipment."description.value") if (!isEmpty(transportEquipment."description.value"))
	})
}