trigger maxPerson on kunalnair__Seminar_People__c (Before insert) 
{
	if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
           	FSLAss.maxPeople(trigger.new);
        }
    }
}