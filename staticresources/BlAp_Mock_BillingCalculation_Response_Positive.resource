{ 
	"responseCode": 200,
	"headers": {
		"content-type": "application/json"
	},
	"body": {
		"Response": {
			"BlIn_BillCalcResponseContainer":{ 
				"Bills" : [ {
					"BillServiceTypes" : [ {
						"BillItems" : [ {
						"BilledAmount" : "100",
						"ToDate" : "date.newInstance(2017, 10, 09)",
						"FromDate" : "date.newInstance(2017, 10, 01)",
						"ChargeBasisValue" : "789",
						"VolumeUsed" : "876",
						"ReadingId" : "objReading.id",
						"RateBandId" : "objRate.id",
						"BillItemId" : "objBillItem.id",
						"ServiceItemId" : "objServiceItem,id",
						"Name" : "Test Bill Item",
						"Id" : "objBillItem.id"
					} ],
					"ServiceTypeId" : "objServiceType.id",
					"Name" : "Test Bill Service",
					"Id" : "objBillServiceType.id"
					} ],
					"TotalDue" : "6789",
					"OriginalBillId" : "objBill.id",
					"ContractGroupId" : "objContract2.id",
					"ContractId" : "objContract2.id",
					"AccountId" : "objAccount.id",
					"Name" : "TestBill",
					"Id" : "objBill.id"
					} ],
				"Status" : "Completed"
			}
		}
	}
}