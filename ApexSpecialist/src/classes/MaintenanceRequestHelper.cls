public class MaintenanceRequestHelper {

    public static void updateWorkOrders() {
        List<Case> maintenanceRequestList = new List<Case>();
        maintenanceRequestList = [select Id, case.Vehicle__c, Equipment__c, Equipment__r.Maintenance_Cycle__c, Type, Status, Subject, Origin FROM Case WHERE Id IN :Trigger.New];
        if (maintenanceRequestList.size() > 0) {
            List<Case> maintenanceRequestListToInsert = new List<Case>();
            for (Case c : maintenanceRequestList) {
                if (c.Type == 'Routine Maintenance' && c.Status == 'Closed') {
                    case newMaintenanceRequest = new Case();
                    newMaintenanceRequest.Subject = c.Subject;
                    newMaintenanceRequest.Type = 'Routine Maintenance';
                    newMaintenanceRequest.Vehicle__c = c.Vehicle__c;
                    newMaintenanceRequest.Equipment__c = c.Equipment__c;
                    newMaintenanceRequest.Date_Reported__c = Date.Today();
                    newMaintenanceRequest.Date_Due__c = Date.today().addDays(Integer.valueOf(c.Equipment__r.Maintenance_Cycle__c));
                    newMaintenanceRequest.Status = 'New';
                    newMaintenanceRequest.Origin = c.Origin;
                    maintenanceRequestListToInsert.add(newMaintenanceRequest);
                }
            }
            try {
                insert maintenanceRequestListToInsert;
            }catch (Exception err){
                System.debug(err.getMessage());
            }
        }
    }
}