import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import Amount from '@salesforce/label/c.Amount';
import Campaign from '@salesforce/label/c.Campaign';
import Language from '@salesforce/label/c.Language';
import Salutation from '@salesforce/label/c.Salutation';
import CompanyName from '@salesforce/label/c.CompanyName';
import FirstName from "@salesforce/label/c.FirstName";
import LastName from "@salesforce/label/c.LastName";
import Street from "@salesforce/label/c.Street";
import PostalCodeComplement from '@salesforce/label/c.PostalCodeComplement';
import PostalCode from "@salesforce/label/c.PostalCode";
import City from "@salesforce/label/c.City";
import Country from "@salesforce/label/c.Country";
import SubscribeToNewsletter from "@salesforce/label/c.SubscribeToNewsletter";
import Email from "@salesforce/label/c.Email";
import Phone from "@salesforce/label/c.Phone";
import Cancel from "@salesforce/label/c.Cancel";
import Return from "@salesforce/label/c.Return";
import Validate from "@salesforce/label/c.Validate";
import createDonation from "@salesforce/apex/Donation.createDonation";
import checkJobStatus from "@salesforce/apex/Donation.checkJobStatus";
import setCommunityDonationStatus from "@salesforce/apex/Donation.setCommunityDonationStatus";

export default class ValidationForm extends NavigationMixin(LightningElement) {
    labels = {
        Amount,
        Campaign,
        Language,
        Salutation,
        CompanyName,
        FirstName,
        LastName,
        Street,
        PostalCodeComplement,
        PostalCode,
        City,
        Country,
        SubscribeToNewsletter,
        Email,
        Phone,
        Cancel,
        Return,
        Validate
    };

    donationData = {};

    @track loadingValidation = false;
    @track jobId;
    @track donationId;

    connectedCallback() {
        this.parseData()
    }

    parseData() {
        var donation = JSON.parse(localStorage.getItem('Donation'));
        console.log(donation)
        if (donation) {
            Object.keys(donation).forEach(key => {
                let valueLabel = donation[key].valueLabel;
                let value = donation[key].value;
                this.donationData[key] = {
                    valueLabel: valueLabel != '' ? valueLabel : value,
                    value: value
                }
            })
        } else {
            this.initError('Failed to load data!');
            this.donationData = undefined;
        }
    }

    cancelClick() {
        localStorage.clear('Donation');
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'DonationForm__c'
            }
        });
    }

    returnClick() {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'DonationForm__c'
            }
        });
    }

    validateClick() {
        this.loadingValidation = true;
        this.buttonsDisabled(true);
        var donation = {};
        Object.keys(this.donationData).forEach(key => {
            donation[key] = this.donationData[key].value;
        })
        console.log(JSON.stringify(donation))
        if (Object.keys(donation).length !== 0) {
            createDonation({ donation: JSON.stringify(donation) })
                .then(result => {
                    if (result) {
                        console.log(result);
                        this.jobId = result.jobId;
                        this.donationId = result.donationId;
                        this.deferCheckJob();
                    }
                })
                .catch(error => { this.initError(error) })
        }
    }

    deferCheckJob() {
        setTimeout(() => {
            this.checkJob()
        }, 3000)
    }

    checkJob() {
        checkJobStatus({ jobId: this.jobId })
            .then(result => {
                var jobStatus = {};
                if (result) {
                    result.forEach(item => jobStatus = item);
                    console.log(jobStatus)
                    if (Object.keys(jobStatus).length != 0) {
                        let inProcess = (
                            jobStatus.Status != 'Aborted'
                            && jobStatus.Status != 'Completed'
                            && jobStatus.Status != 'Failed')

                        if (inProcess) {
                            this.deferCheckJob();
                        } else {
                            this.setCommunityDonationStatus(jobStatus.Status == 'Completed' ? 'Converted' : 'Failed');
                            jobStatus.Status == 'Completed'
                                ? this.initSuccess('Donation successfully converted!')
                                : jobStatus.Status == 'Failed'
                                    ? this.initError(jobStatus.ExtendedStatus)
                                    : this.initLoadingEnd();
                            setTimeout(() => {
                                this.navigateToHome();
                            }, 1500)
                        }
                    }
                }
            })
            .catch(error => this.initError(error))
    }

    navigateToHome() {
        localStorage.clear('Donation');
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Home'
            }
        });
    }

    setCommunityDonationStatus(status) {
        setCommunityDonationStatus({ donationId: this.donationId, status: status })
            .then(result => { console.log(result) })
            .catch((error) => console.error(error))
    }

    buttonsDisabled(disable) {
        var buttons = this.template.querySelectorAll('.main-button');
        buttons.forEach((button) => {
            button.disabled = disable;
        })
    }

    showToastMessage(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        })
        this.dispatchEvent(event)
    }

    initError(message) {
        console.error(message);
        this.loadingValidation = false;
        this.buttonsDisabled(false);
        this.showToastMessage('Error', message, 'error');
    }

    initSuccess(message) {
        this.loadingValidation = false;
        this.buttonsDisabled(false);
        this.showToastMessage('Success', message, 'success');
    }

    initLoadingEnd() {
        this.loadingValidation = false;
        this.buttonsDisabled(false);
    }
}