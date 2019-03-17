/************************************************************************
* Modification Log     Developer Name   Description
* 1.0                  Vivek Verma      Test class for the Batch class N26_SendSurveyEmailsToCustomers
*										Testing both the positive and negative scenarios
*
************************************************************************/
@isTest(SeeAllData= false)
private class N26_SendSurveyEmailsToCustomers_Test {
	
	@isTest static void test_EmailSendCase() {
		// create test data
		List<Contact> conList = createContacts(10);
		
		String query = 'SELECT Id, Language__c, Is_German__c, Survey_Date__c from Contact where Survey_Date__c != null';
		Test.startTest();
        	N26_SendSurveyEmailsToCustomers batchObj = new N26_SendSurveyEmailsToCustomers(query);
        	Database.executeBatch(batchObj, 10);
		Test.stopTest();

		Contact conRes = [Select Id, Survey_Date__c from Contact limit 1];
		System.assertEquals(conRes.Survey_Date__c, null);
	}
	
	@isTest static void test_EmailSendExceptionCase() {
		// create test data
		List<Contact> conList = createContacts(1500);
		
		String query = 'SELECT Id, Language__c, Is_German__c, Survey_Date__c from Contact where Survey_Date__c != null';
		Test.startTest();
        	N26_SendSurveyEmailsToCustomers batchObj = new N26_SendSurveyEmailsToCustomers(query);
        	Database.executeBatch(batchObj, 1500);
		Test.stopTest();

		Contact conRes = [Select Id, Survey_Date__c from Contact limit 1];
		System.assertNotEquals(conRes.Survey_Date__c, null);
	}

	static List<Contact> createContacts(Integer count){

		List<Contact> conList = new List<Contact>();

		for(Integer i=0; i<count ; i++){
			Contact con = new Contact();
			con.LastName = 'Test ' + String.valueOf(i);
			if( Math.mod(i, 2) == 0){
				con.Language__c = 'en';
			}
			else{
				con.Language__c = 'de';
			}
			con.Survey_Date__c = System.today() -2;
			conList.add(con);
		}

		if(conList.size() >0 && conList!=null){
			insert conList;
		}

		return conList;
	}
	
}