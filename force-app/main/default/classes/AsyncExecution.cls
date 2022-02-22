public class AsyncExecution {
  public class GetAllUsers extends QueueableChainJob implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
      String users = ReqResIntegration.get('https://reqres.in/api/users');
      system.debug(users);

      this.executeNextJob();
    }
  }

  public class GetUser extends QueueableChainJob implements Queueable, Database.AllowsCallouts {
    String userId;

    public GetUser(String userId) {
      this.userId = userId;
    }

    public void execute(QueueableContext context) {
      String user = ReqResIntegration.get(
        'https://reqres.in/api/users/' + userId
      );
      system.debug(user);

      this.executeNextJob();
    }
  }

  public class UpdateUser extends QueueableChainJob implements Queueable, Database.AllowsCallouts {
    String user;

    public UpdateUser(String user) {
      this.user = user;
    }

    public void execute(QueueableContext context) {
      system.debug('UpdateUser');
      system.debug(this.user);

      if (user != '{}' && String.isNotBlank(user)) {
        Map<String, Object> jsonFile = (Map<String, Object>) JSON.deserializeUntyped(
          user
        );
        Map<String, Object> data = (Map<String, Object>) jsonFile.get('data');
        String userName =
          data.get('first_name') +
          ' ' +
          data.get('last_name') +
          datetime.now();
        String user = ReqResIntegration.post(
          'https://reqres.in/api/users/' + data.get('id'),
          '{"name":' +
          userName +
          '}'
        );

        system.debug(user);
      }
      this.executeNextJob();
    }
  }

  public class DelayCallbackFirst extends QueueableChainJob implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
      String user = ReqResIntegration.get(
        'https://reqres.in/api/users?delay=3'
      );

      system.debug('DelayCallbackFirst');
      system.debug(user);
      this.executeNextJob();
    }
  }

  public class DelayCallbackSecond extends QueueableChainJob implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
      String user = ReqResIntegration.get(
        'https://reqres.in/api/users?delay=3'
      );

      system.debug('DelayCallbackSecond');
      system.debug(user);
      this.executeNextJob();
    }
  }

  public class DelayCallbackThird extends QueueableChainJob implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
      system.debug('DelayCallbackThird');
      this.executeNextJob();
    }
  }
}
