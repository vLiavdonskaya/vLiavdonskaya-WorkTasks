public class AsyncExecution {
    
    @InvocableMethod(label='Call ReqRes' 
                     description='Calls ReqRes source.' 
                     category='Account')
    public static void EnqueueAllJobs(List<Integer> userId) {
        system.enqueueJob(new AsyncExecution.GetAllUsers(userId[0]));
    }
    
    public static void EnqueueJob(Queueable job) {
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
        Integer userId;
        public GetAllUsers(Integer userId) { 
            this.userId = userId;
        }
        public void execute(QueueableContext context) {
            String users = ReqResIntegration.get('https://reqres.in/api/users');
            system.debug(users);
            
            AsyncExecution.EnqueueJob(new GetUser(userId));
        }
    }
    
    public class GetUser implements Queueable, Database.AllowsCallouts {
        Integer userId;
        public GetUser(Integer userId) { 
            this.userId = userId;
        }
        
        public void execute(QueueableContext context) {
            String user = ReqResIntegration.get('https://reqres.in/api/users/' + userId);
            system.debug(user);
            
            AsyncExecution.EnqueueJob(new UpdateUser(user));
        }
    }
    
    public class UpdateUser implements Queueable, Database.AllowsCallouts {
        String user;
        public UpdateUser(String user) { 
            this.user = user;
        }
        
        public void execute(QueueableContext context) {
            Map<String, Object> jsonFile = 
                (Map<String, Object>)
                JSON.deserializeUntyped(user);
            Map<String, Object> data = 
                (Map<String, Object>)jsonFile.get('data');
            String userName = data.get('first_name') + ' ' + data.get('last_name') + datetime.now();
            String user = ReqResIntegration.post('https://reqres.in/api/users/' + data.get('id'), '{"name":'+ userName +'}');
            system.debug(user);
            
            AsyncExecution.EnqueueJob(new DelayCallbackFirst());
        }
    }
    
    public class DelayCallbackFirst implements Queueable, Database.AllowsCallouts {
        public void execute(QueueableContext context) {
            String user = ReqResIntegration.get('https://reqres.in/api/users?delay=3');
            system.debug('DelayCallbackFirst');
            system.debug(user);
            
            AsyncExecution.EnqueueJob(new DelayCallbackSecond());
        }
    }
    
    public class DelayCallbackSecond implements Queueable, Database.AllowsCallouts {
        public void execute(QueueableContext context) {
            String user = ReqResIntegration.get('https://reqres.in/api/users?delay=3');
            system.debug('DelayCallbackSecond');
            system.debug(user);
            
            AsyncExecution.EnqueueJob(new DelayCallbackThird());
        }
    }
    
    public class DelayCallbackThird implements Queueable, Database.AllowsCallouts {
        public void execute(QueueableContext context) {
            //String user = ReqResIntegration.get('https://reqres.in/api/users?delay=3');
            system.debug('DelayCallbackThird');
            //system.debug(user);
        }
    }
}