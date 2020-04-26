/******************************************************************************
@author         Echo: Romul Mittal
@date           11 Apr 2018
@description    This is to check assignment rule checkbox when case is created.
@revision(s)        
*******************************************************************************/

trigger CaseTrigger on Case (after insert) {

    Set<Id> caseIdSet = new Set<Id>();
    for(Case c : trigger.new) {
        caseIdSet.add(c.Id);
    }

    List<Case> caseList = new List<Case>();

    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.AssignmentRuleHeader.useDefaultRule = true;

    for(Case c : [SELECT Id FROM Case WHERE Id IN: caseIdSet]) {
        c.setOptions(dmo);
        caseList.add(c);
    }

    update caseList;
}