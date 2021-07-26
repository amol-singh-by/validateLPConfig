%dw 2.0
import * from dw::Runtime
//Force Delete
var documentActionCode = 'DELETE'
var codelistFlag = Mule::p('bydm.canmodel.codeList')


fun tranformDeleteRecord(receiptLine) = DeleteRecord : {
    ReceiptID : receiptLine.pOSId default ""
}

output application/xml deferred = true, skipNullOn = "everywhere"

---
ReceiptLines : {(payload[vars.bulkType] filter ($.documentActionCode != "DELETE" ) map (receiptLine) -> {
    (tranformDeleteRecord(receiptLine))
})}