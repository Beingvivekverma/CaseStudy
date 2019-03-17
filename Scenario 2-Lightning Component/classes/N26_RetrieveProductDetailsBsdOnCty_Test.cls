/************************************************************************
* Modification Log     Developer Name   Description
* 1.0                  Vivek Verma      Test class for the Apex Class N26_RetrieveProductDetailsBasedOnCountry
*
************************************************************************/
@isTest(SeeAllData= false)
private class N26_RetrieveProductDetailsBsdOnCty_Test {

	@isTest static void test_returnProductDetailsUsingWrapper() {
		// create test data
		Contact con = createContact();
		
		Test.startTest();
        	N26_RetrieveProductDetailsBasedOnCountry.returnProductDetailsUsingWrapper(con.Id);
		Test.stopTest();

	}

	static Contact createContact(){
		//Create Contact & return
		Contact con = new Contact();
		con.LastName = 'Test Contact';
		con.Product__c = 'Standard';
		con.Home_Country__c = 'UK';
		con.Language__c = 'en';
		insert con;
		return con;
	}

}