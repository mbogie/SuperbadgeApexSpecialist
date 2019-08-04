@IsTest
private class InstallationTests {

    static testmethod void testMaintenanceRequest() {
        //given
        List<Case> maintenanceList = new List<Case>();
        List<Case> maintenanceListAfterClosed = new List<Case>();
        Vehicle__c vehicle = new Vehicle__c(Name = 'Test', Air_Conditioner__c = true, Model__c = 'Test');
        Product2 equipment = new Product2(Name = 'Rim', Cost__c = 100, Current_Inventory__c = 10, Replacement_Part__c = true,
                Warehouse_SKU__c = 'Test', Lifespan_Months__c = 10, Maintenance_Cycle__c = 10);
        insert vehicle;
        insert equipment;
        for (Integer i = 1; i <= 300; i++) {
            Case maintenance = new Case(Subject = 'Test Subject' + i, Type = 'Routine Maintenance' + i, Status = 'New' + i,
                    Origin = 'Phone' + i, Equipment__c = equipment.Id, Vehicle__c = vehicle.Id);
            maintenanceList.add(maintenance);
        }
        insert maintenanceList;
        for (Case caseUpdate : maintenanceList) {
            caseUpdate.Status = 'Closed';
            caseUpdate.Type = 'Routine Maintenance';
            caseUpdate.Date_Due__c = date.Today().addDays(Integer.valueOf(equipment.Maintenance_Cycle__c));
            maintenanceListAfterClosed.add(caseUpdate);
        }
        //when
        Test.startTest();
        Database.SaveResult[] updateEquipment = Database.update(maintenanceListAfterClosed);
        Test.stopTest();
        //then
        system.assertEquals(300, maintenanceList.size());
        for (Database.SaveResult sa : updateEquipment) {
            System.assert(sa.isSuccess());
        }
    }

    static testmethod void testWarehouseSync() {
        //given
        String CRON_EXP = '00 00 01 * * ?';
        //when
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String jobId = System.schedule('Warehouse Test', CRON_EXP, new WarehouseSyncSchedule());
        Test.stopTest();
        //then
        CronTrigger a = [SELECT Id FROM CronTrigger WHERE NextFireTime > today];
        System.assertEquals(jobId, a.Id);
    }
}