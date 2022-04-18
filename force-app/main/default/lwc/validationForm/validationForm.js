import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Cancel from "@salesforce/label/c.Cancel";
import Return from "@salesforce/label/c.Return";
import Validate from "@salesforce/label/c.Validate";
import createCommunityDonation from "@salesforce/apex/DonationFormController.createCommunityDonation"

export default class ValidationForm extends LightningElement {
    @api labels;
    @api donationData;
    @track loading = false;
    previewDonation = {};
    customLabels = { Cancel, Return, Validate };
    COUNTRY_FIELD = 'Country';

    connectedCallback() {
        this.loading = true;
        this.parseData()
    }

    parseData() {
        if (this.donationData) {
            Object.keys(this.donationData).forEach(key => {
                let valueLabel = this.donationData[key] ? this.donationData[key].valueLabel : '';
                let value = this.donationData[key] ? this.donationData[key].value : '';
                this.previewDonation[key] = {
                    valueLabel: valueLabel != '' ? valueLabel : value,
                    value: value
                }
            })
        } else {
            this.initError('Failed to load data!');
            this.previewDonation = undefined;
        }
        this.loading = false;
    }

    validateClick() {
        this.buttonsDisabled(true);
        var donation = {};

        Object.keys(this.donationData).forEach(key => {
            if (!!this.donationData[key]) donation[key + "__c"] = this.donationData[key] ? this.donationData[key].value : '';
        })
        if (Object.keys(donation).length !== 0) {
            createCommunityDonation({ donation: JSON.stringify(donation) })
                .then(result => {
                    this.initSuccess('Donation successfully created!');
                    setTimeout(() => {
                        this.cancelClick();
                    }, 1500) 
                })
                .catch(error => { this.initError(error) })
        }
    }

    cancelClick() {
        this.initEvent("cancelevent", { validated: false })
    }

    returnClick() {
        this.initEvent("returnevent", { validated: false })
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
        this.buttonsDisabled(false);
        this.showToastMessage('Error', message, 'error');
    }

    initSuccess(message) {
        this.buttonsDisabled(false);
        this.showToastMessage('Success', message, 'success');
    }

    initLoadingEnd() {
        this.loadingValidation = false;
        this.buttonsDisabled(false);
    }

    initEvent(name, value) {
        const event = new CustomEvent(name, {
            detail: value
        });

        this.dispatchEvent(event);
    }
}