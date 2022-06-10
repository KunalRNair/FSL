public class FSLAss 
{
	public static void maxPeople(List<kunalnair__Seminar_People__c> seminarPerson)
    {
        
        List<sObject> countPerson=[select count(id)coun,kunalnair__Seminar__c from kunalnair__Seminar_People__c group by kunalnair__Seminar__c];
        List<kunalnair__Waiting_List__c> waitList=[select kunalnair__person__c,kunalnair__Seminar__c,kunalnair__Seminar__r.kunalnair__Product__c  from kunalnair__Waiting_List__c];
        List<kunalnair__seminar__c> seminars=[select name,kunalnair__product__c,kunalnair__Unique__c from kunalnair__seminar__c];
        
        List<kunalnair__Complete_Seminar__c> completeSem=[select name from kunalnair__Complete_Seminar__c];
        
        
        boolean get=true;
        
        for(kunalnair__Seminar_people__c semPer: seminarPerson)
        {
            for(kunalnair__Complete_Seminar__c com:completeSem)
            {
                if(com.name==semPer.kunalnair__Seminar__c)
                {
                    semPer.addError('Overbooked');
                }
            }
            
            for(sObject countPer:countPerson)
            {
                integer count=(integer)countPer.get('coun');
                
                
                
             	if( semPer.kunalnair__Seminar__c  ==  countPer.get('kunalnair__Seminar__c')&& count > 12 )
                {
                    System.debug(count);
                    
                    for(kunalnair__Waiting_List__c check:waitList)
                    {
                        for(kunalnair__seminar__c sem:seminars)
                        {
                            
                            if(  semPer.kunalnair__Seminar__c==sem.Id  &&  sem.kunalnair__Product__c == check.kunalnair__Seminar__r.kunalnair__Product__c  && semPer.kunalnair__Seminar__c!=check.kunalnair__Seminar__c)
                            {
                                semPer.addError('A product can have one waiting list');
                            }    
                            
                        }
                    }
                    
                    
                    
                    if(count == 15)
                    {
                        	System.debug('In');
                        
                        	for(kunalnair__Seminar__c sem:seminars)
                            {
                                
                                if(semPer.kunalnair__Seminar__c==sem.id)
                                {
                                    kunalnair__Complete_Seminar__c completed= new kunalnair__Complete_Seminar__c(name=sem.id);
                                    insert completed;
                                    
                                    System.debug('In Again');
                                    decimal unique=0;
                                    unique=sem.kunalnair__Unique__c+1;
                                    kunalnair__Seminar__c semi=new kunalnair__Seminar__c(name=sem.name+'new',kunalnair__Product__c=sem.kunalnair__Product__c,kunalnair__Unique__c=sem.kunalnair__Unique__c+1);
                                    
                                    
                                    insert semi;
                                    
                                    
                                    
                                    List<kunalnair__Seminar_People__c> oldSemPeop=[select name,kunalnair__person__c,kunalnair__seminar__c from kunalnair__Seminar_People__c where kunalnair__seminar__c= :sem.Id order by createdDate Desc limit 3];
                                    
                                    for(kunalnair__Seminar_People__c old:oldSemPeop)
                                    {
                                        old.kunalnair__seminar__c=semi.id;
                                    }
                                    
                                    update oldSemPeop;
                                    
                                    
                                    delete [select id from kunalnair__Waiting_List__c where kunalnair__Seminar__c = :semPer.kunalnair__Seminar__c ];
                                    
                                    semPer.kunalnair__Seminar__c=semi.Id;
                                    
                                    get=true;
                                }
                            }

                    }
                    else
                    {
                        kunalnair__Waiting_List__c newWait=new kunalnair__Waiting_List__c(kunalnair__person__c=semPer.kunalnair__person__c, kunalnair__seminar__c = semPer.kunalnair__Seminar__c);
                        waitList.add(newWait);
                    }
                	count++;
                }   
            }
        }
        if(!get)
        {
         	upsert waitList;   
        }
    }
}