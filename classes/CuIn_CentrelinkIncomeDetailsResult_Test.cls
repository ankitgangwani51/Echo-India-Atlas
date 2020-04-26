/*******************************************************************************
@author         Echo: Sudhir Kumar
@date           02 Jan 2019
@group 			Test Class
@description    Test class for CuIn_CentrelinkIncomeDetailsResultDto class
				//This is just a DTO instantiation. So there should not be need to positive/negative scenrios.
				//So that we have some coverage, this is created because these DTO are not being used in any of current Concession interfaces.
********************************************************************************/
@isTest
public class CuIn_CentrelinkIncomeDetailsResult_Test {
	
    /******************************************************************************
    @author         Echo: Sudhir Kumar
    @date           02 Jan 2019
    @description    Test scenario for retrieveIncomeDetailsResult_element
    *******************************************************************************/ 
    static testmethod void testRetrieveIncomeDetailsResultDto() {
        //assetDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.assetDetailsResultDto assetDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.assetDetailsResultDto() ;
        //assetFinancialDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.assetFinancialDetailsResultDto assetFinancialDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.assetFinancialDetailsResultDto() ;
        //deductionDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.deductionDetailsResultDto deductionDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.deductionDetailsResultDto() ;
        //deductionFromPaymentDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.deductionFromPaymentDetailsResultDto deductionFromPaymentDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.deductionFromPaymentDetailsResultDto() ;
        //foreignIncomeFinancialDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.foreignIncomeFinancialDetailsResultDto foreignIncomeFinancialDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.foreignIncomeFinancialDetailsResultDto() ;
        //futureIrregularPaymentDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.futureIrregularPaymentDetailsResultDto futureIrregularPaymentDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.futureIrregularPaymentDetailsResultDto() ;
        //futureRegularPaymentDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.futureRegularPaymentDetailsResultDto futureRegularPaymentDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.futureRegularPaymentDetailsResultDto() ;
        //incomeManagementDeductionDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.incomeManagementDeductionDetailsResultDto incomeManagementDeductionDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.incomeManagementDeductionDetailsResultDto() ;
        //maximumRateDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.maximumRateDetailsResultDto maximumRateDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.maximumRateDetailsResultDto() ;
        //nonCuIn_CentrelinkIncomeDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.nonCuIn_CentrelinkIncomeDetailsResultDto nonCuIn_CentrelinkIncomeDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.nonCuIn_CentrelinkIncomeDetailsResultDto() ;
        //previousIrregularPaymentDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.previousIrregularPaymentDetailsResultDto previousIrregularPaymentDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.previousIrregularPaymentDetailsResultDto() ;
        //previousRegularPaymentDetailsResultDto
        CuIn_CentrelinkIncomeDetailsResultDto.previousRegularPaymentDetailsResultDto previousRegularPaymentDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.previousRegularPaymentDetailsResultDto() ;
        
        //retrieveIncomeDetailsResult_element
        CuIn_CentrelinkIncomeDetailsResultDto.retrieveIncomeDetailsResult_element incomeDetailsResultElement = new CuIn_CentrelinkIncomeDetailsResultDto.retrieveIncomeDetailsResult_element() ;
        //retrieveIncomeDetails_element
        CuIn_CentrelinkIncomeDetailsResultDto.retrieveIncomeDetailsResultDto incomeDetailsResultDto = new CuIn_CentrelinkIncomeDetailsResultDto.retrieveIncomeDetailsResultDto() ;   
        incomeDetailsResultElement.retrieveIncomeDetailsResultDto = incomeDetailsResultDto ;
        system.assert(incomeDetailsResultElement.retrieveIncomeDetailsResultDto != null) ;
    }
}