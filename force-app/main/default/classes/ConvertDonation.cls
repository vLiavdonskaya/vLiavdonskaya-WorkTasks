public class ConvertDonation implements Queueable {
    private CommunityDonation__c donationToConvert = new CommunityDonation__c();
   
    public ConvertDonation(CommunityDonation__c donationToConvert) {
        this.donationToConvert = donationToConvert;
    }
    
    public void execute(QueueableContext context) {
        Donation.convertDonation(this.donationToConvert);
    }
}