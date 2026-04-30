public with sharing class WarrantyController {

    @AuraEnabled
    public static void saveClaim(String vin, String vehicleType, String partName, String description, String dealerName){

        Warranty_Claim_Intake__c wc = new Warranty_Claim_Intake__c();

        wc.VIN__c = vin;
        wc.Vehicle_Type__c = vehicleType;
        wc.Part_Name__c = partName;
        wc.Issue_Description__c = description;
        wc.Dealer_Name__c = dealerName;

        insert wc;

    }
}