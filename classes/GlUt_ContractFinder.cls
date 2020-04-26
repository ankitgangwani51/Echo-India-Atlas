/******************************************************************************
@author    		Echo: Patrick Dixon
@date      		21 Feb 2018
@description 	Base class for Contract Finder
				Actual code is in extended classes specific to the amended object type
				eg GlUt_ReadingContractFinder
Revision(s)		Echo: Sudhir Kumar
				19 Feb 2019: AT-3489: Added virtual "retrieveContractIds" method for bulk setRecordIds
*******************************************************************************/
public virtual class GlUt_ContractFinder {
	
	public class NotImplementedException extends Exception{}

	public virtual Set<Id> retrieveContractIds(Id recordId) {
		throw new NotImplementedException('Error Not Implemented');
	}     
    
    public virtual Set<Id> retrieveContractIds(set<Id> setRecordIds) {
		throw new NotImplementedException('Error Not Implemented');
	}
}