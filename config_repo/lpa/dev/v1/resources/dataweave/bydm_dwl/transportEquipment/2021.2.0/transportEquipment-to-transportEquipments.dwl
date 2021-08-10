%dw 2.0
output application/xml deferred = true, skipNullOn = "everywhere"
---
TransportEquipments : {(payload[vars.bulkType] filter($.documentActionCode != "DELETE") map (transportEquipment) -> using (usageThresholdValues = transportEquipment.usageThresholdValues) {
        Record : {
            TransportEquipmentID : if (!isEmpty(transportEquipment.transportEquipmentId)) (transportEquipment.transportEquipmentId) else '',
            (Description : transportEquipment.description.value) if (!isEmpty(transportEquipment.description.value))
        }
    })}