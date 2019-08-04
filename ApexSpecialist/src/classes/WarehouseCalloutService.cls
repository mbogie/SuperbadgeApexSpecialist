public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public class EquipmentWrapper{
        public String equipmentId;
        public Boolean replacement;
        public Integer quantity;
        public String name;
        public Integer maintenancePeriod;
        public Integer lifespan;
        public Integer cost;
        public String sku;
    }

    @future(callout=true)
    public static void runWarehouseEquipmentSync() {
        Http http= new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = Http.send(request);
        if (response.getStatusCode() == 200) {
            List<Product2> updateEquipmentList = getProducts(response);
            if (updateEquipmentList.size() > 0) {
                try {
                    insert updateEquipmentList;
                }catch (Exception err){
                    System.debug(err.getMessage());
                }
            }
        } else {
            System.debug(response.getStatusCode()+' '+response.getStatus());
        }
    }

    public static List<Product2> getProducts(HttpResponse response) {
        String JsonBody = response.getBody().replaceAll('_id', 'equipmentId');
        List<EquipmentWrapper> externalEquipments = (List<EquipmentWrapper>) JSON.deserialize(JsonBody,List<EquipmentWrapper>.class);
        List<Product2> equipmentList = new List<Product2>();
        for (EquipmentWrapper wrapper : externalEquipments) {
            Product2 equipment = new Product2();
            equipment.Cost__c = wrapper.cost;
            equipment.Lifespan_Months__c = wrapper.lifespan;
            equipment.Maintenance_Cycle__c = wrapper.maintenancePeriod;
            equipment.Name = wrapper.name;
            equipment.Current_Inventory__c = wrapper.quantity;
            equipment.Replacement_Part__c = wrapper.replacement;
            equipment.Warehouse_SKU__c = wrapper.sku;
            equipmentList.add(equipment);
        }
        return equipmentList;
    }
}