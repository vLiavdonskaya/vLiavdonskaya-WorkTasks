public abstract class QueueableChainJob {
  private Queueable nextJob;

  public void setNextJob(Queueable nextJob) {
    this.nextJob = nextJob;
  }

  public Id executeNextJob() {
    Id jobId = null;
    if (nextJob != null) {
      enqueueTheJob(this.nextJob);
    }

    return jobId;
  }

  private void enqueueTheJob(Queueable job) {
    try {
      if (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
        System.enqueueJob(job);
        return;
      }
    } catch (System.AsyncException e) {
      if (e.getMessage() == 'Maximum stack depth has been reached.') {
        job.execute(null);
      }
    }
  }
}
