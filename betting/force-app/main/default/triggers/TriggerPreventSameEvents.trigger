trigger TriggerPreventSameEvents on Product2 (before insert) { // бессмысленный и беспощадный
    for (Product2 newEvent : Trigger.new) {
        List<Product2> oldEvents = [SELECT id,Name FROM Product2 WHERE Name =: newEvent.Name];
        if (oldEvents.size()>0) {
            newEvent.Name += oldEvents.size();
        }
    }
}
