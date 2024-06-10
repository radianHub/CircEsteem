import { LightningElement, api } from 'lwc';

import getCart from '@salesforce/apex/ProgramInvoiceController.getCart';
import createCartWithProducts from '@salesforce/apex/ProgramInvoiceController.createCartWithProducts';
import getProgram from '@salesforce/apex/ProgramInvoiceController.getProgram';

export default class ProgramInvoice extends LightningElement {
	@api cartId;
	@api programSessionId = 'a0HE1000002kPv7MAE';
	@api contactId = '003E100000NAd9eIAD';
	cart;
	program;
	frequency;

	lockBtns = false;
	loading = true;
	saving = false;

	// # LIFECYCLE HOOKS

	connectedCallback() {
		this.getCart();
		this.getProgram();
	}

	// # APEX

	getProgram() {
		getProgram({ sessionId: this.programSessionId })
			.then((r) => {
				console.log('Program', r);
				this.program = r;
				this.loading = false;
			})
			.catch((e) => {
				console.log(e);
			});
	}

	getCart() {
		getCart({ cartId: this.cartId })
			.then((r) => {
				if (r.length === 0) {
					this.createCartWithProducts();
				} else if (r.length === 1) {
					console.log('Cart', r);
					this.cart = r;
				}
			})
			.catch((e) => {
				this.createCartWithProducts();
			});
	}

	createCartWithProducts() {
		createCartWithProducts({ sessionId: this.programSessionId, contactId: this.contactId })
			.then((r) => {
				console.log('New Cart', r);
				this.cart = r;
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
		this.cart.startDate = this.program.Program_Sessions__r[0].Start_Date__c;
		this.cart.endDate = this.program.Program_Sessions__r[0].End_Date__c;

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

	// # GETTERS/SETTERS

	get isLoading() {
		return this.loading || this.saving;
	}

	get cartProducts() {
		return this.cart?.Cart_Products__r;
	}

	get paymentFrequency() {
		return this.program.Payment_Frequency__c.split(';').map((e) => {
			return { label: e, value: e };
		});
	}

	get total() {
		return this.cart ? `$${this.cart.Total__c.toFixed(2)}` : '$0.00';
	}
}
