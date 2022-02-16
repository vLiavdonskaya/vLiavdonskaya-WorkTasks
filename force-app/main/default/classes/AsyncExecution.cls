public class AsyncExecution {
    public class Requests {
        @InvocableVariable
        (label='AccountId' 
         description='Account Id' 
         required=true)
        public String accountId;
    }
    
    @InvocableMethod
    (label='Call ReqRes' 
     description='Calls ReqRes source.' 
     category='Account')
    public static void enqueueAllJobs(List<Requests> requestList) {
        String accountId = requestList[0].accountId;
        system.enqueueJob(new AsyncExecution.GetAllUsers(requestList[0].accountId));
    }
    
    public static void enqueueTheJob(Queueable job) {
        try{
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                System.enqueueJob(job);
                return;
            }
        } catch(System.AsyncException e) {
            if(e.getMessage() == 'Maximum stack depth has been reached.') {
                job.execute(null);
            } 
        }
    }
    
    public class GetAllUsers implements Queueable, Database.AllowsCallouts {
        String userId;
        public Boolean chain = true;
        
        public GetAllUsers(String userId) { 
            this.userId = userId;
        }
        
        public void execute(QueueableContext context) {
            String users = ReqResIntegration.get('https://reqres.in/api/users');
            system.debug(users);
            
            if(chain) AsyncExecution.enqueueTheJob(new GetUser(userId));
        }
    }
    
    public class GetUser implements Queueable, Database.AllowsCallouts {
        String userId;
        public Boolean chain = true;
        
        public GetUser(String userId) { 
            this.userId = userId;
        }
        
        public void execute(QueueableContext context) {
            String user = ReqResIntegration.get('https://reqres.in/api/users/' + userId);
            system.debug(user);
            
            if(chain) AsyncExecution.enqueueTheJob(new UpdateUser(user));
        }
    }
    
    public class UpdateUser implements Queueable, Database.AllowsCallouts {
        String user;
        public Boolean chain = true;
        
        public UpdateUser(String user) { 
            this.user = user;
        }
        
        public void execute(QueueableContext context) {
            if(user != '{}') {
                Map<String, Object> jsonFile = 
                    (Map<String, Object>)
                    JSON.deserializeUntyped(user);
                Map<String, Object> data = 
                    (Map<String, Object>)jsonFile.get('data');
                String userName = data.get('first_name') + ' ' + data.get('last_name') + datetime.now();
                String user = ReqResIntegration.post('https://reqres.in/api/users/' + data.get('id'), '{"name":'+ userName +'}');
                
                system.debug(user); 
                
                if(chain) AsyncExecution.enqueueTheJob(new DelayCallbackFirst());
            }
        }
    }
    
    public class DelayCallbackFirst implements Queueable, Database.AllowsCallouts {
        public Boolean chain = true;
        
        public void execute(QueueableContext context) {
            String user = ReqResIntegration.get('https://reqres.in/api/users?delay=3');
            system.debug('DelayCallbackFirst');
            system.debug(user);
            
            if(chain) AsyncExecution.enqueueTheJob(new DelayCallbackSecond());
        }
    }
    
    public class DelayCallbackSecond implements Queueable, Database.AllowsCallouts {
        public Boolean chain = true;
        
        public void execute(QueueableContext context) {
            String user = ReqResIntegration.get('https://reqres.in/api/users?delay=3');
            
            system.debug('DelayCallbackSecond');
            system.debug(user);
            
            if(chain) AsyncExecution.enqueueTheJob(new DelayCallbackThird());
        }
    }
    
    public class DelayCallbackThird implements Queueable, Database.AllowsCallouts {
        public void execute(QueueableContext context) {
            system.debug('DelayCallbackThird');
        }
    }
}