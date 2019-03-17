/************************************************************************
* Modification Log     Developer Name   Description
* 1.0                  Vivek Verma      Batch sending surveys to our customers over the Salesforce Service Cloud
*										
*
************************************************************************/
global class N26_SendSurveyEmailsToCustomers implements Database.Batchable<sObject>, Database.Stateful {
	//Query string containing dynamic query
	String query;
	// Contact list to store eligible Contacts for sending email
    Set<Id> customerIdsSet;
    //List of Contacts, successful sends will be updated with Survey_Date as NULL
    List<Contact> contactsToBeProcessed;
    /*Variable to store the number of Contacts processed in each batch will be used to set the Email Sending limit 
   	this variable will retain values are Database.stateful is being used 
    */
    Integer emailSendLimit;

	global N26_SendSurveyEmailsToCustomers(String qry) {
		//instantiate the declared variables here
		this.query = qry;
		this.customerIdsSet = new Set<Id>();
		this.contactsToBeProcessed = new List<Contact>();
		this.emailSendLimit = 0;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Contact> scope) {
		System.debug('N26_SendSurveyEmailsToCustomers::Execute');
		List<Contact> contactsToUpdate = new List<Contact>();
		//Integer storing number of contacts processed in current batch
		Integer thisBatchsContactsToBeProcessedSize = 0;
		
		//For Contacts coming in current Batch
		for(Contact con : scope){	

			//this Contact meets criteria for Survey to be sent
			if( con.Survey_Date__c < System.Today() ){

				System.debug('N26_SendSurveyEmailsToCustomers::Adding Contact:: ' +con);		
				customerIdsSet.add(con.Id);
				contactsToBeProcessed.add(con);
				//Incrementing the Limit of Email sending globally
				emailSendLimit++;
				//Keeping the count of number of contacts to be processed in current batch
				thisBatchsContactsToBeProcessedSize++;
			}

		}//end of for loop

		try{

			//Querying the EmailTemplate used
			EmailTemplate et = [Select id from EmailTemplate where name = 'Send Survey' Limit 1];
	 		System.debug('N26_SendSurveyEmailsToCustomers::Execute::EmailTemplate ID:: ' +et.Id);
	 		System.debug('N26_SendSurveyEmailsToCustomers::Execute::customerIdsSet:: ' +customerIdsSet);

	 		//Converting Set to List : Set was used to avoid duplicate Id, 
	 		//& conversion is required to align with method : setTargetObjectIds signature
			List<Id> customerIdsList = new List<Id>(customerIdsSet);
			System.debug('N26_SendSurveyEmailsToCustomers::Execute::customerIdsList:: ' +customerIdsList);

			//Assuming the daily limit as 1,000 : to send MassEmails
			//This will keep check the remaining limit of Emails to be sent(considering 1000 as the daily limit)
			Integer remainingLimitOfEmailsToSend = 1000 - emailSendLimit;
			Messaging.reserveMassEmailCapacity(remainingLimitOfEmailsToSend);

			//Perform Email sending here
			Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
			mail.setTargetObjectIds(customerIdsList);
			mail.setSenderDisplayName('N26 Admin');
			mail.setTemplateId(et.id);
			Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });

			//now we have the emails sent result
			System.debug('N26_SendSurveyEmailsToCustomers::Execute::results:: ' +results);

			// If Email Sending was successful : Update Survey_Date__c field on only processed Contact records
    		if(results[0].success){
    			//Looping through the current Batch records & updating their Survey_Date fields
    			for( Integer i = (emailSendLimit -thisBatchsContactsToBeProcessedSize) ; i<emailSendLimit ; i++ ){
    				//Email Successfully sent, update the Survey_Date on Contacts
	        		System.debug('N26_SendSurveyEmailsToCustomers::Execute::contactsToBeProcessed[i]::  ' +contactsToBeProcessed[i]);
	        		System.debug('N26_SendSurveyEmailsToCustomers::Execute::contactsToBeProcessed[i].Survey_Date__c:: ' +contactsToBeProcessed[i].Survey_Date__c);
	        		Contact con = new Contact(Id = contactsToBeProcessed[i].Id);
	            	con.Survey_Date__c = null;
	            	contactsToUpdate.add(con);
    			}
        	}
        	if( contactsToUpdate.size() > 0 && contactsToUpdate!= null){
        		System.debug('Updating these contacts for Survey_Date:: ' +contactsToUpdate);
        		upsert contactsToUpdate;
        	}

		}catch(Exception ex){
			System.debug('Exception occured while sending--> ' +ex);
		 	/* We can create an Error log record with the Exception details so that failed records can be picked again via
		 	a retry mechanism for the next day. By having a daily scheduled job resend the message at 0000h*/
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('N26_SendSurveyEmailsToCustomers::Finish method'); 
	}//end of finish
	
}