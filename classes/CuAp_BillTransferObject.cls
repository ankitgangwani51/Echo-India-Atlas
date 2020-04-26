/******************************************************************************
    @author         Dependra Singh 
    @date           22 Oct 2018
    @description    Class is used to create payload of bill transfer. 
					Also we are sending same payload at Heroku end.
	@Revisions		13 Dec 2018 , Tarun Gupta , AT-4502,4504,4505 , Added new parameter - LicenseId
    *******************************************************************************/
public with sharing class CuAp_BillTransferObject{
    public BillTransfers[] BillTransfers;
	
   /******************************************************************************
    @author         Dependra Singh 
    @date           22 Oct 2018
    @description    Sub class of Bill transfer payload
    *******************************************************************************/
    public class BillTransfers {
        public Bills[] Bills;
        public String BillCalculationId;	//
        public String TransferFromContractId;	//
        public String TransferToContractId;	//
        public String TransferReason;	//
        public String LocationId;	//
        public String LicenseId;	//
        /******************************************************************************
		@author         Dependra Singh 
		@date           22 Oct 2018
		@param 			List<Id> selectedBillIds, 
						String strContractToTransferId, 
						String contractId, 
						String strBillTransferReason,
						string strLocationId, 
						string strbillCalculationId
		@description    constructor Sub class of Bill transfer payload
		*******************************************************************************/
        public BillTransfers(List<Id> selectedBillIds, String strContractToTransferId, String contractId, String strBillTransferReason,
                             string strLocationId, string strbillCalculationId, string strLicenseId) {
            
            Bills = new List<Bills>();
            if(selectedBillIds != null && !selectedBillIds.isEmpty()){
               for (Id objId : selectedBillIds) {
                   Bills.add(new Bills(objId));
                 }
             }                      
            TransferFromContractId = contractId;
            TransferToContractId = strContractToTransferId;
            TransferReason = strBillTransferReason;
            BillCalculationId = strbillCalculationId;
            LocationId = strLocationId;
            LicenseId = strLicenseId;
        } 
    }
    /******************************************************************************
    @author         Dependra Singh 
    @date           22 Oct 2018
    @description    Sub class of Bill transfer payload
    *******************************************************************************/
    public class Bills{
        public Id BillId;
        public Bills(Id selectedBillIds){
            BillId = selectedBillIds;
        }
    }  

}