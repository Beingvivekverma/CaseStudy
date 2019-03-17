/************************************************************************
* Modification Log     Developer Name   Description
* 1.0                  Vivek Verma      Apex Class for N26_CustomersProductInfoToAgents component
*
************************************************************************/
public with sharing class N26_RetrieveProductDetailsBasedOnCountry {

/******************************************************************************************************************
* Details                                                     Description
* Method Name : returnProductDetailsUsingWrapper              Method returning product details in a wrapper to show on UI
* Return Type : Wrapper of type TablesDetailsWrapper          Wrapper containing variables with values coming from backend tables
******************************************************************************************************************/
    @AuraEnabled
    public static TablesDetailsWrapper returnProductDetailsUsingWrapper(Id recordId){
        
        //Wrapper object : will store details of respective Customer record
        TablesDetailsWrapper wrapperObj = new TablesDetailsWrapper();
        List<GetCustomerProductDetail__mdt> costTableValueList;
        List<GetCustomerProductDetail__mdt> atmTableValueList;
        List<GetCustomerProductDetail__mdt> cardCostTableValueList;
        try{

            //If the recordId of the record is passed from the UI
            if( (recordId!= null && !String.isBlank(String.valueOf(recordId)) ) ){

                System.debug('N26_RetrieveProductDetailsBasedOnCountry::returnProductDetailsUsingWrapper::recordId:: ' +recordId);

                Contact con = [SELECT Product__c, Home_Country__c 
                                FROM Contact
                                WHERE ID = :recordId];

                //If Contact retrieved is not Null
                if( con != null){
                    //If the Product & Home Country values are non empty/null for this Contact
                    if( (con.Product__c!= null && !String.isBlank(con.Product__c)) && (con.Home_Country__c!= null && !String.isBlank(con.Home_Country__c)) ){

                        //retrieve Customer's specific Product detail based on Product & HomeCountry values: by using the CustomMetadata record
                        costTableValueList = [Select Value__c 
                                                FROM GetCustomerProductDetail__mdt
                                                WHERE Home_Country__c = :con.Home_Country__c AND Product__c = :con.Product__c AND TypeOfTable__c = 'Cost'];     
                    
                        atmTableValueList = [Select Value__c 
                                                FROM GetCustomerProductDetail__mdt
                                                WHERE Home_Country__c = :con.Home_Country__c AND Product__c = :con.Product__c AND TypeOfTable__c = 'ATM'];     
                    
                        cardCostTableValueList = [Select Value__c 
                                                    FROM GetCustomerProductDetail__mdt
                                                    WHERE Home_Country__c = :con.Home_Country__c AND Product__c = :con.Product__c AND TypeOfTable__c = 'Card'];
                    }

                }

                //Populating Wrapper object based on CustomMetadata values
                if(costTableValueList.size() > 0 && costTableValueList != null){
                    System.debug('N26_RetrieveProductDetailsBasedOnCountry::returnProductDetailsUsingWrapper::costTableValueList[0].Value__c:: ' +costTableValueList[0].Value__c);
                    wrapperObj.costPerCalendarMonth = costTableValueList[0].Value__c;
                }
                if(atmTableValueList.size() > 0 && atmTableValueList != null){
                    System.debug('N26_RetrieveProductDetailsBasedOnCountry::returnProductDetailsUsingWrapper::atmTableValueList[0].Value__c:: ' +atmTableValueList[0].Value__c);
                    wrapperObj.atmFeeInOtherCurr = atmTableValueList[0].Value__c;
                }
                if(cardCostTableValueList.size() > 0 && cardCostTableValueList != null){
                    System.debug('N26_RetrieveProductDetailsBasedOnCountry::returnProductDetailsUsingWrapper::cardCostTableValueList[0].Value__c:: ' +cardCostTableValueList[0].Value__c);
                    wrapperObj.cardReplacementCost = cardCostTableValueList[0].Value__c;
                }

            }


        }catch(Exception ex){
            System.debug('Exception occured in Backend code:: ' +ex);
            //We can use Error Log custom object to log Errors once occured
        }

        return wrapperObj;
    }    

    //Wrapper class storing variables with values coming from Backend tables
     public class TablesDetailsWrapper {
        @AuraEnabled
        public String costPerCalendarMonth;
        @AuraEnabled
        public String atmFeeInOtherCurr;
        @AuraEnabled
        public String cardReplacementCost;
    } 
    
}