/************************************************************************
* Modification Log     Developer Name   Description
* 1.0                  Vivek Verma      Test class for Schedule class N26_SendSurveyEmailsToCustomersSchedule
*
************************************************************************/
@isTest(SeeAllData =false)
public class N26_SendSrveEmailsToCstmrsScheduleTest {
	
    static testmethod void test_ScheduleMethod()
    {
        Test.startTest();
            N26_SendSurveyEmailsToCustomersSchedule schAc = new N26_SendSurveyEmailsToCustomersSchedule();
            //Test to schedule at 1am everyday
            String jobID = System.schedule('Test Schedule', '0 0 1 * * ?', schAc);
        Test.stopTest();
        System.assertNotEquals(jobID, null);
    }
}