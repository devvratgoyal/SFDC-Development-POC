/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-05-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   08-05-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class OpportunitySetController {
    
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(new OpportunitiesSelector().selectSObjectsById(new set<Id>{}));
            }
            return setCon;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<Opportunity> getOpportunities() {
        return (List<Opportunity>) setCon.getRecords();
    }

    public PageReference applyDiscounts() {
        try {
            // Apply discount entered to the selected Opportunities
            Decimal discountPercentage = 10.5;
            OpportunitiesService.applyDiscounts(
               // Tip: Creating a Map from an SObject list gives easy access to the Ids (keys)
               new Map<Id,SObject>(setCon.getSelected()).keySet(), discountPercentage
            );
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }          
        return null;               
    }
    
}