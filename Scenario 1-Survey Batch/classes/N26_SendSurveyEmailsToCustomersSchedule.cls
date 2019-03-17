/************************************************************************
* Modification Log     Developer Name   Description
* 1.0                  Vivek Verma      Schedule class for the Batch class N26_SendSurveyEmailsToCustomers
*
************************************************************************/
public class N26_SendSurveyEmailsToCustomersSchedule implements Schedulable{

    public void execute (SchedulableContext sc){
        
       	String query = 'SELECT Id,To_Send__c,Language__c, Is_German__c, Survey_Date__c from Contact where Survey_Date__c != null';
        N26_SendSurveyEmailsToCustomers batchObj = new N26_SendSurveyEmailsToCustomers(query);
        Database.executeBatch(batchObj, 200);
   
    }  
}