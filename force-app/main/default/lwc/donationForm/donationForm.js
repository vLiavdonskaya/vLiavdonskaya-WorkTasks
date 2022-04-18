import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Save from "@salesforce/label/c.Save";

import SALUTATION_FIELD from '@salesforce/schema/Contact.Salutation';
import COUNTRY_FIELD from '@salesforce/schema/Contact.MailingCountryCode';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import getCampaignList from "@salesforce/apex/DonationFormController.getCampaignList";
import getLanguageList from "@salesforce/apex/DonationFormController.getLanguageList";
import getMapOfLabelsPerObject from "@salesforce/apex/DonationFormController.getMapOfLabelsPerObject";


export default class DonationForm extends LightningElement {

  @track hasRendered = true;
  @track loading = false;
  @track validated = false;
  @track defaultCountry = 'CH';
  @track donationData = {};
  customLabels = { Save };
  labels = {};
  campaigns = [];
  languages = [];
  salutations = [];
  countries = [];
  cities = [];
  allCities = [
    { label: 'Zürich', value: 'Zürich', postalCode: { start: '8000', last: '8099' } },
    { label: 'Geneva', value: 'Geneva', postalCode: { start: '1200', last: '1227' } },
    { label: 'Basel', value: 'Basel', postalCode: { start: '4000', last: '4000' } },
    { label: 'Lausanne', value: 'Lausanne', postalCode: { start: '1000', last: '1033' } },
    { label: 'Bern', value: 'Bern', postalCode: { start: '3000', last: '3030' } },
    { label: 'Winterthur', value: 'Winterthur', postalCode: { start: '8400', last: '8545' } },
    { label: 'Lucerne', value: 'Lucerne', postalCode: { start: '6000', last: '6000' } },
    { label: 'St. Gallen', value: 'St. Gallen', postalCode: { start: '9000', last: '9042' } },
    { label: 'Lugano', value: 'Lugano', postalCode: { start: '6900', last: '6979' } },
    { label: 'Biel/Bienne', value: 'Biel/Bienne', postalCode: { start: '2500', last: '2510' } },
    { label: 'Thun', value: 'Thun', postalCode: { start: '3600', last: '3645' } },
    { label: 'Bellinzona', value: 'Bellinzona', postalCode: { start: '6500', last: '6500' } },
    { label: 'Köniz', value: 'Köniz', postalCode: { start: '3098', last: '3098' } },
    { label: 'Fribourg', value: 'Fribourg', postalCode: { start: '1700', last: '1700' } },
    { label: 'La Chaux-de-Fonds', value: 'La Chaux-de-Fonds', postalCode: { start: '2300', last: '2300' } },
    { label: 'Schaffhausen', value: 'Schaffhausen', postalCode: { start: '8200', last: '8231' } },
    { label: 'Chur', value: 'Chur', postalCode: { start: '7000', last: '7074' } },
    { label: 'Vernier', value: 'Vernier', postalCode: { start: '1214', last: '1220' } },
    { label: 'Uster', value: 'Uster', postalCode: { start: '8610', last: '8610' } },
    { label: 'Sion', value: 'Sion', postalCode: { start: '1950', last: '1993' } },
  ];
  postalCodePattern = '';

  connectedCallback() {
    this.loading = true;
  }

  @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
  contactInfo;

  @wire(getPicklistValues,
    {
      recordTypeId: '$contactInfo.data.defaultRecordTypeId',
      fieldApiName: SALUTATION_FIELD
    })
  wiredSalutations({ error, data }) {
    if (data) {
      data.values.forEach(item => {
        this.salutations = [...this.salutations, {
          label: item.label,
          value: item.value
        }]
      });
    } else if (error) {
      this.salutations = undefined;
      this.initError('Failed to load salutations!');
    }
    this.loading = false;
  }

  @wire(getPicklistValues,
    {
      recordTypeId: '$contactInfo.data.defaultRecordTypeId',
      fieldApiName: COUNTRY_FIELD
    })
  wiredCountries({ error, data }) {
    if (data) {
      data.values.forEach(item => {
        this.countries = [...this.countries, { label: item.label, value: item.value }]
      })
    } else if (error) {
      this.countries = undefined;
      this.initError('Failed to load countries!');
    }
  }

  @wire(getLanguageList)
  wiredLanguages({ error, data }) {
    if (data) {
      Object.keys(data).forEach((key) => {
        this.languages = [...this.languages, { label: key, value: key }]
      })
    } else if (error) {
      this.languages = undefined;
      this.initError('Failed to load languages!');
    }
  }

  @wire(getCampaignList)
  wiredCampaigns({ error, data }) {
    if (data) {
      data.forEach((item) => {
        this.campaigns = [...this.campaigns, { label: item['Name'], value: item['Id'] }];
      })
    } else if (error) {
      this.campaigns = undefined;
      this.initError('Failed to load campaigns!');
    }
  }

  @wire(getMapOfLabelsPerObject, { objectAPIName: 'CommunityDonation__c' })
  wiredLabels({ error, data }) {
    if (data) {
      if (Object.keys(data).length > 0) {
        Object.keys(data).forEach(key => {
          this.labels[data[key].replaceAll(" ", "")] = data[key]
          this.donationData[data[key].replaceAll(" ", "")] = '';
        })
        if (this.donationData.hasOwnProperty('Country')) {
          this.donationData.Country = this.defaultCountry;
          this.postalCodePattern = '[0-9]*';
        }
      }
    } else if (error) {
      this.labels = undefined;
      this.donationData = undefined;
      this.initError('Failed to load labels!');
    }
  }

  postalCodeEnter(e) {
    var value = e.target.value;
    this.cities = [];
    if (value) {
      this.fillCities(value)
    }
  }

  fillCities(postalCode, choosenCity = null) {
    this.allCities.forEach((city) => {
      let startCode = city.postalCode.start.substring(0, 2);
      let endCode = city.postalCode.last.substring(0, 2);

      if (postalCode.includes(startCode) || postalCode.includes(endCode)) {
        console.log(city)
        this.cities = [...this.cities, city];
        this.donationData.City = choosenCity ? choosenCity : city.value;
      }
    })
  }

  campaignChanged(e) {
    this.donationData.Campaign = e.detail.value;
  }

  languageChanged(e) {
    this.donationData.Language = e.detail.value;
  }

  salutationChanged(e) {
    this.donationData.Salutation = e.detail.value;
  }

  countryChanged(e) {
    this.donationData.Country = e.detail.value;
    this.postalCodePattern = this.defaultCountry === this.donationData.Country ? '[0-9]*' : null;
  }

  createDonation(e) {
    e.preventDefault();
    this.validateFields()
    this.validated ? this.readFields() : null;
  }

  readFields() {
    let formFields = this.template.querySelectorAll('.form-field');

    formFields.forEach(field => {
      let isChkbx = field.type === 'checkbox';
      let cmbxValueLabel = field.outerText.replace(/[&\/\\*]/g, "");
      let valueLabel = isChkbx ? field.checked ? 'yes' : 'no' : cmbxValueLabel;

      this.donationData[field.id.replace(/[^a-zA-Z]/g, "")] =
      {
        value: isChkbx ? field.checked : field.value,
        valueLabel: valueLabel
      }
    })
  }

  validateFields() {
    let isValid = true;
    let requiredFields = this.template.querySelectorAll('.required-field');

    requiredFields.forEach(field => {
      if (!field.checkValidity()) {
        field.reportValidity();
        isValid = false;
      }
    });
    this.validated = isValid;
  }

  cancelHandler(e) {
    this.validated = e.detail.validated
    this.cities = [];
    Object.keys(this.donationData).forEach(key => {
      this.donationData[key] = key === 'Country' ? this.defaultCountry : '';
    })
  }

  returnHandler(e) {
    this.validated = e.detail.validated
    this.fillFields();
  }

  fillFields() {
    if (Object.keys(this.donationData).length !== 0) {
      Object.keys(this.donationData).forEach(key => {
        this.donationData[key] = this.donationData[key].hasOwnProperty('value')
          ? this.donationData[key].value : '';
      });
    }
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
    this.showToastMessage('Error', message, 'error');
  }
}


