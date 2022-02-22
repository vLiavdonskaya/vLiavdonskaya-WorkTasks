public class ChainJobs {
  public ChainJobs addJob(Queueable job) {
    JobsChain.jobs.add(job);
    return this;
  }

  public void execute() {
    if (JobsChain.jobs.size() > 0) {
      for (Integer i = 0; i < JobsChain.jobs.size() - 1; i++) {
        makeQueue((QueueableChainJob) JobsChain.jobs[i], JobsChain.jobs[i + 1]);
      }
      system.enqueueJob(JobsChain.jobs[0]);
    }
  }

  public void makeQueue(QueueableChainJob job, Queueable nextJob) {
    job.setNextJob(nextJob);
  }
}
