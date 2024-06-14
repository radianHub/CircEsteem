import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import getCart from '@salesforce/apex/ProgramInvoiceController.getCart';
import createCartWithProducts from '@salesforce/apex/ProgramInvoiceController.createCartWithProducts';
import getCredits from '@salesforce/apex/ProgramInvoiceController.getCredits';

export default class ProgramInvoice extends LightningElement {
	@api recordId;
	@api cartId;
	@api programSessionId;
	@api contactId;

	cart;
	program;
	frequency;
	credits;
	appliedCredits = [];
	runningTotal;

	lockBtns = false;
	loading = true;
	saving = false;

	// # LIFECYCLE HOOKS

	connectedCallback() {
		this.programSessionId = this.programSessionId ? this.programSessionId : this.currentPageReference.state.c__session;
		this.contactId = this.contactId ? this.contactId : this.currentPageReference.state.c__contact;
		this.cartId = this.cartId ? this.cartId : this.currentPageReference.state.c__cart;
	
		console.log(this.recordId);
		if (this.recordId) {
			this.cartId = this.recordId;
		}	

		this.getCart();
	}

	// # APEX

	@wire(CurrentPageReference)
	currentPageReference;

	getCart() {
		getCart({ cartId: this.cartId })
			.then((r) => {
				if (r.length === 0) {
					this.createCartWithProducts();
				} else {
					console.log('Cart', r);
					this.contactId = this.contactId ? this.contactId : r.Contact__c;
					// this.programSessionId = this.programSessionId ? this.programSessionId : r.Program_Session__c;
					this.cart = JSON.parse(JSON.stringify(r));
					this.runningTotal = r.Total__c;
					this.getCredits();
				}
			})
			.catch((e) => {
				this.createCartWithProducts();
			})
			.finally(() => {
				setTimeout(() => {
					this.loading = false;
				}, 2000);
			})
	}

	createCartWithProducts() {
		createCartWithProducts({ sessionId: this.programSessionId, contactId: this.contactId })
			.then((r) => {
				console.log('New Cart', r);
				this.cart = r;
				this.runningTotal = r.Total__c;
				this.getCredits();
			})
			.catch((e) => {
				console.log(e);
			});
	}

	getCredits() {
		getCredits({ contactId: this.contactId })
			.then((r) => {
				if (r.length > 0) {
					this.credits = r.map((e) => {
						return {
							Id: e.Id,
							available: e.Type__c === 'Amount'
								? e.Credits_Available__c
								: this.runningTotal * (parseInt(e.Credit_Percentage__c, 10) / 100),
							type: e.Type__c
						};
					});
					console.log('Credits', this.credits);	
				}
			})
			.catch((e) => {
				console.log(e);
			});
	}

	// # PRIVATE METHODS

	validate() {
		const validLCB = [...this.template.querySelectorAll('lightning-combobox')].reduce((isValid, inp) => {
			inp.reportValidity();
			let valid = inp.checkValidity();

			return isValid && valid;
		}, true);
		return validLCB;
	}

	// # HANDLERS

	selectFrequencyOption(e) {
		this.frequency = e.currentTarget.value;
	}

	clickPayBtn() {
		this.cart.startDate = this.cart?.Program_Session__r.Start_Date__c;
		this.cart.endDate = this.cart?.Program_Session__r.End_Date__c;

		this.loading = true;
		this.lockBtns = true;
		if (this.validate()) {
			let processor = this.template.querySelector('c-payment-processor');
			processor.sendPayment();
		} else {
			this.loading = false;
			this.lockBtns = false;
		}
	}

	sentToCheckout(e) {
		this.loading = !e.detail.sent;
	}

	clickCreditBox(e) {
		if (this.appliedCredits.findIndex(i => i.id === e.currentTarget.name) > -1) {
			this.appliedCredits.splice(this.appliedCredits.findIndex(i => i.id === e.currentTarget.name), 1);
		} else {	
			if (this.appliedCredits.length === 0) {
				this.appliedCredits.push({
					id: e.currentTarget.dataset.id,
					value: this.cart.Total__c >= e.currentTarget.value ? e.currentTarget.value : this.cart.Total__c,
					type: e.currentTarget.name
				});	
			} else {
				this.appliedCredits.push({
					id: e.currentTarget.dataset.id,
					value: this.runningTotal >= e.currentTarget.value ? e.currentTarget.value : this.runningTotal,
					type: e.currentTarget.label
				});
			}
		} 
		this.runningTotal = this.cart.Total__c - this.appliedCredits.reduce((a,v) => a + parseFloat(v.value), 0)
	}

	// # GETTERS/SETTERS

	get isLoading() {
		return this.loading || this.saving;
	}

	get cartProducts() {
		return this.cart?.Cart_Products__r;
	}

	get paymentFrequency() {
		return this.cart?.Program_Session__r.Program__r.Payment_Frequency__c.split(';').map((e) => {
			return { label: e, value: e };
		});
	}

	get total() {
		return this.cart ? `$${this.runningTotal.toFixed(2)}` : '$0.00';
	}
}
