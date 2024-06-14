// TODO: HANDLE FOR INTERNAL USERS
import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { refreshApex } from '@salesforce/apex';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';

import getCart from '@salesforce/apex/ViewCartController.getCart';
import getCredits from '@salesforce/apex/ViewCartController.getCredits';

// * USER FIELDS
import USER_ID from '@salesforce/user/Id';
import CONTACT_ID from '@salesforce/schema/User.ContactId';

// * CART FIELDS
// import STRIPE_TRANSACTION_ID_FIELD from '@salesforce/schema/Cart__c.Stripe_Transaction_Id__c';
// import ID_FIELD from '@salesforce/schema/Cart__c.Id';
// import STATUS_FIELD from "@salesforce/schema/Cart__c.Status__c";

// import getSettings from '@salesforce/apex/ViewCartController.getSettings';


export default class ViewCart extends LightningModal {
	@api recordId;
	@api cartId;
	
	contactId;
	cart;
	credits;
	appliedCredits = [];
	runningTotal;

	loadingData = true;
	deletingData = false;

	error;

	connectedCallback() {
		if (this.recordId) {
			this.cartId = this.recordId;
		}
	}

	// # APEX

	@wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
	wiredUser({ data, error }) {
		if (data) {
			console.log('ContactId', data);
			this.contactId = data.fields.ContactId.value;
		} else if (error) {
			console.log(error);
		}
	}

	// *
	
	@wire(getCart, { cartId: '$cartId' })
	wiredGetCart(value) {
		this.wiredCart = value;
		let { data, error } = value;

		if (data) {
			console.log('wiredGetCart', data);
			this.cart = data;
			this.runningTotal = this.cart.Total__c;

			this.loadingData = false;
			this.error = undefined;
		} else if (error) {
			console.log('error', error);
			this.error = error;
		}
	}

	@wire(getCredits, { contactId: '$contactId'})
	wiredCredits({ data, error }) {
		if (data) {
			this.credits = data;
			this.credits = this.credits.filter(i => i.Type__c === 'Amount');
			console.log(this.credits);
		} else if (error) {
			console.log(error);
		}
	}

	// * MOVED TO PAYMENT PROCESSOR
	// @wire(getSettings)
	// wiredSetting;

	// cartCheckout() {
		
	// 	let body = "";
		
	// 	let currentItem = 0;
	// 	body += encodeURIComponent("cancel_url") 
	// 	+ "=" + 
	// 	encodeURIComponent("https://circesteem--eddev.sandbox.my.site.com/s/shop") + "&";
			
	// 	body += encodeURIComponent("success_url") 
	// 	+ "=" + 
	// 	encodeURIComponent("https://circesteem--eddev.sandbox.my.site.com/s/shop") + "&";
		
	// 	this.cart.Cart_Products__r.forEach((product) => {
	// 		body += encodeURIComponent("line_items[" 
	// 		+ currentItem + 
	// 		"][price_data][currency]") 
	// 		+ "=" + 
	// 		encodeURIComponent("usd") + 
	// 		"&";
			
	// 		body += encodeURIComponent("line_items[" 
	// 		+ currentItem + 
	// 		"][price_data][product_data][name]") 
	// 		+ "=" + 
	// 		encodeURIComponent(product.Name) + 
	// 		"&";
			
	// 		body += 
	// 		encodeURIComponent("line_items[" 
	// 		+ currentItem + 
	// 		"][price_data][unit_amount]") 
	// 		+ "=" + encodeURIComponent(String(product.Price_Cents__c)) + 
	// 		"&";
			
	// 		body += 
	// 		encodeURIComponent("line_items[" 
	// 		+ currentItem + 
	// 		"][quantity]") 
	// 		+ "=" + 
	// 		encodeURIComponent(String(product.Quantity__c)) + 
	// 		"&";
	
	// 		console.log(currentItem);
	// 		currentItem++;
	// 	});
	// 	body += 
	// 	encodeURIComponent("payment_method_types[0]") 
	// 	+ "=" + 
	// 	encodeURIComponent("card") + 
	// 	"&";

	// 	body += 
	// 	encodeURIComponent("mode") 
	// 	+ "=" + encodeURIComponent("payment") + "&";
		
	// 	body = body.slice(0, -1);
		
		
	// 	console.log(this.wiredSetting.data.Bearer_Token__c);
	// 	let authorization = 'Bearer ' + this.wiredSetting.data.Bearer_Token__c;
	// 	console.log(authorization);

	// 	const response = fetch('https://api.stripe.com/v1/checkout/sessions', {
	// 		method: "POST",
	// 		headers: {
	// 			"Content-Type": "application/x-www-form-urlencoded",
	// 			Authorization: `Bearer ${this.wiredSetting.data.Bearer_Token__c}`,
	// 			"Accept-Encoding": "gzip, deflate, br'",
	// 			Accept: '*/*',
	// 		},
	// 		body: body
	// 	}).then((resp)=> resp.json())
	// 		.then(repos => {
	// 			this.loadingData = false;
	// 			console.log(repos);
	// 			const fields = {};
	// 			fields[STRIPE_TRANSACTION_ID_FIELD.fieldApiName] = repos.id;
	// 			fields[ID_FIELD.fieldApiName] = this.cartId;
	// 			fields[STATUS_FIELD.fieldApiName] = 'Checkout Initiated';

	// 			const recordInput = {
	// 				fields,
	// 			};

	// 			updateRecord(recordInput)
	// 			.then(() => {
					
	// 				this.loadingData = false;
	// 				const toastEvent = new ShowToastEvent({
	// 					title: 'Success!',
	// 					message: 'Please Complete Checkout in the New Window',
	// 					variant: 'success'
	// 				});
	// 				this.dispatchEvent(toastEvent);
	// 			})
				
	// 			window.open(repos.url, "_blank");
	// 			this.close();
	// 		});	
	// }

	// # HANDLERS

	// *
	handleClickDelete(event) {
		this.deletingData = true;

		deleteRecord(event.currentTarget.dataset.id)
			.then((result) => {
				this.deletingData = false;

				this.loadingData = true;
				refreshApex(this.wiredCart);

				const removeProductEvent = new CustomEvent('removeproductevent');
				this.dispatchEvent(removeProductEvent);
			})
			.catch((error) => {
				this.error = error;
				this.deletingData = false;
			});
	}

	// *
	handleClickCheckout() {
		this.loadingData = true;
		// this.cartCheckout(); 
		let processor = this.template.querySelector('c-payment-processor')
		processor.sendPayment();
	}

	// *
	sentToCheckout(e) {
		this.loadingData = !e.detail.sent;
	}

	// *
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
					type: e.currentTarget.name
				});
			}
		} 
		this.runningTotal = this.cart.Total__c - this.appliedCredits.reduce((a,v) => a + parseFloat(v.value), 0)
	}

	// # HELPERS
	

	// # GETTERS

	// *
	get isLoading() {
		if (this.loadingData || this.creatingData) {
			return true;
		}
		return false;
	}

	// *
	get cartProducts() {
		return this.cart?.Cart_Products__r;
	}

	get header() {
		let header = this.cart ? `Total: $${this.runningTotal}` : `Total: $0.00`;
		return header;
	}
}