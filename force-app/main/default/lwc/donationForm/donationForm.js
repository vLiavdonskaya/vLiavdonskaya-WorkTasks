import { LightningElement, track } from "lwc";
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
import Save from "@salesforce/label/c.Save";
import getCampaignList from "@salesforce/apex/DonationFormController.getCampaignList";
import getSalutationList from "@salesforce/apex/DonationFormController.getSalutationList";
import getCountryList from "@salesforce/apex/DonationFormController.getCountryList";
import getLanguageList from "@salesforce/apex/DonationFormController.getLanguageList";

export default class DonationForm extends NavigationMixin(LightningElement) {
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
    Save,
  };

  donationData = localStorage.getItem('Donation')
    ? JSON.parse(localStorage.getItem('Donation')) : {};

  campaigns = [];
  languages = [];
  salutations = [];
  countries = [];

  postalCodePattern = '';

  defaultCountry = 'CH';

  @track comboboxes = {
    Campaign: '',
    Language: '',
    Salutation: '',
    City: '',
    Country: this.defaultCountry
  }

  @track hasRendered = true;
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
  cities = [];

  renderedCallback() {
    if (this.hasRendered) {
      this.fillFields();
      this.hasRendered = false;
    }
  }

  connectedCallback() {
    this.getCampaigns();
    this.getSalutations();
    this.getCountries();
    this.getLanguages();
    this.donationData.hasOwnProperty('PostalCode') && this.donationData.hasOwnProperty('City')
      ? this.fillCities(this.donationData.PostalCode.value, this.donationData.City.value) : null;
    this.postalCodePattern = this.comboboxes.Country === this.defaultCountry ? '[0-9]*' : null;
  }

  getCampaigns() {
    getCampaignList()
      .then(result => {
        if (result) {
          result.forEach((item) => {
            this.campaigns = [...this.campaigns, { label: item['Name'], value: item['Id'] }];
          })
        }
      })
      .catch(error => console.error(error))
  }

  getLanguages() {
    getLanguageList()
      .then(result => {
        if (result) {
          Object.keys(result).forEach((key) => {
            this.languages = [...this.languages, { label: key, value: key }]
          })
        }
      })
      .catch(error => console.error(error))
  }

  getSalutations() {
    getSalutationList()
      .then(result => {
        if (result) {
          Object.keys(result).forEach((key) => {
            this.salutations = [...this.salutations, { label: key, value: result[key] }]
          })
        }
      })
      .catch(error => { console.error(error) })
  }

  getCountries() {
    getCountryList()
      .then(result => {
        if (result) {
          Object.keys(result).forEach((key) => {
            let country = result[key].includes(',')
              ? result[key].substring(0, result[key].indexOf(','))
              : result[key]
            this.countries = [...this.countries, {
              label: country,
              value: key
            }]
          })
        }
      })
      .catch(error => console.error(error))
  }

  postalCodeEnter(e) {
    var value = e.target.value;
    if (value) {
      this.fillCities(value)
    } else {
      this.cities = [];
      this.comboboxes.City = '';
    }
  }

  fillCities(postalCode, choosenCity = null) {
    this.allCities.forEach((city) => {
      let startCode = city.postalCode.start.substring(0, 2);
      let endCode = city.postalCode.last.substring(0, 2);
      if (postalCode.includes(startCode) || postalCode.includes(endCode)) {
        this.cities = [...this.cities, city];
        this.comboboxes.City = choosenCity ? choosenCity : city.value;
      }
    })
  }

  campaignChanged(e) {
    this.comboboxes.Campaign = e.detail.value;
  }

  languageChanged(e) {
    this.comboboxes.Language = e.detail.value;
  }

  salutationChanged(e) {
    this.comboboxes.Salutation = e.detail.value;
  }

  countryChanged(e) {
    this.comboboxes.Country = e.detail.value;
    this.postalCodePattern = this.comboboxes.Country === this.defaultCountry ? '[0-9]*' : null;
  }

  validateFields() {
    let isValid = true;
    let requiredFields = this.template.querySelectorAll('.form-field');

    requiredFields.forEach(field => {
      if (!field.checkValidity()) {
        field.reportValidity();
        isValid = false;
      }
      let isChkbx = field.type === 'checkbox';
      let cmbxValueLabel = field.outerText.replace(/[&\/\\*]/g, "");
      let valueLabel = isChkbx ? field.checked ? 'yes' : 'no' : cmbxValueLabel;

      this.donationData[field.id.replace(/[^a-zA-Z]/g, "")] =
      {
        value: isChkbx ? field.checked : field.value,
        valueLabel: valueLabel
      }
    });
    return isValid;
  }

  fillFields() {
    if (Object.keys(this.donationData).length !== 0) {
      let requiredFields = this.template.querySelectorAll('.form-field')
      requiredFields.forEach(field => {
        let prop = field.id.replace(/[^a-zA-Z]/g, "");
        field.value = this.donationData[prop].value;
      });
    }
  }

  createDonation(e) {
    e.preventDefault();
    if (this.validateFields()) {
      localStorage.setItem('Donation', JSON.stringify(this.donationData));
      this.navigateToValidationForm();
    }
  }

  navigateToValidationForm() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: 'validation_screen__c'
      }
    });
  }
}
