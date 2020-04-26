{ 
	"responseCode": 200,
	"headers": {
		"content-type": "application/json"
	},
	"body": {
			"Status":"Completed",
			"Amendments":[{
			"Id":"a984bf3b7836410cb8c220a391f3e7c5",
			"Name":"Test",
			"BillItemId":null,
			"AmendmentReason":"Manual Amendment",
			"AgreedSampleStrengthId":null,
			"AgreedVolumeId":null,
			"ChargeBasisId":null,
			"DiscountId":null,
			"ReadingId":null,
			"ServiceItemId":null,
			"TaxClassificationId":null,
			"ManualAmendmentId":null,
			"Amount":"100",
			"DiscountAmount":"10",
			"TaxAmount":"10"
			}], 
			"Bills":
			[{
			"Id":"f5827649989547d59717e8588990f91b",
			"AccountId":"0010Y00000tzSH1QAM",
			"BillDate":"2017-12-20 00:00:00",
			"FromDate":"2017-11-01 00:00:00",
			"ToDate":"2017-12-20 00:00:00",
			"ContractId":"a000Y00000LsjXHQAZ",
			"ContractGroupId":null,
			"OriginalBillId":null,
			"BilledAmount":0.0,
			"TotalDue":null,
			"Name":"Heroku Generated Bill",
			"BillServiceTypes":
			[{
			"Id":"a984bf3b7836410cb8c220a391f3e7c8",
			"Name":null,
			"ServiceTypeId":"a0X0Y00000ICqQuUAL",
			"BillItems":
			[{
			"Id":"a984bf3b7836410cb8c220a391f3e7c1",
			"BillItemDiscounts":[{
			"Id":"a984bf3b7836410cb8c220a391f3e7c4"
			}],
			"BillItemTaxes":[{
			"Id":"a984bf3b7836410cb8c220a391f3e7c5"
			}],
			"ServiceItemId":"a0O0Y000006OwYf"			
			}],
			"TotalBilledAmount":0.0
			}],
			"BillItems":
			[{
			"Id":"a984bf3b7836410cb8c220a391f3e7c9",
			"ServiceItemId":"a0O0Y000006OwYf",
			"Amendment":{
			"Id":"a984bf3b7836410cb8c220a391f3e7c7",
			"Name":"Test"
			}
			}],
			"FinalBill":false
			}]
	}
}