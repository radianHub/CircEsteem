import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

import { stripe } from 'c/paymentUtils';

import getSettings from '@salesforce/apex/PaymentProcessorController.getSettings';
import createAppliedCredits from '@salesforce/apex/PaymentProcessorController.createAppliedCredits';

// * CART FIELDS
import STRIPE_TRANSACTION_ID_FIELD from '@salesforce/schema/Cart__c.Stripe_Transaction_Id__c';
import ID_FIELD from '@salesforce/schema/Cart__c.Id';
import STATUS_FIELD from '@salesforce/schema/Cart__c.Status__c';

export default class PaymentProcessor extends LightningElement {
	@api paymentType;
	@api cartData;
	@api credits;
	stripe = new stripe();

	// # LIFECYCLE HOOKS

	// # APEX

	@wire(getSettings)
	wiredSettings;

	createAppliedCredits() {
		createAppliedCredits({ cartId: this.cartData.Id, appliedCreditsJson: JSON.stringify(this.credits) })
		.then(() => {
			console.log('Credits Success');
		})
		.catch((e) => {
			console.log(e);
			this.showToast('Error', e.body.message, 'error');
		})
	}

	// # PRIVATE METHODS

	showToast(title, msg, variant, mode = 'dismissible') {
		const event = new ShowToastEvent({
			title: title,
			message: msg,
			variant: variant,
			mode: mode,
		});
		this.dispatchEvent(event);
	}

	monthDiff(date1, date2) {
		let months = (date2.getFullYear() - date1.getFullYear()) * 12;
		months -= date1.getMonth() + 1;
		months += date2.getMonth();
		return months <= 0 ? 0 : months;
	}

	weekDiff(date1, date2) {
		return Math.round((date2 - date1) / (7 * 24 * 60 * 60 * 1000));
	}

	createSessionWithCoupons(data) {
		let couponIds = []
		this.credits.forEach(e => {
			let couponPayload = this.stripe.generateCouponPayload(e.value);
			this.stripe.makeCallout(data.auth, couponPayload, 'v1/coupons')
			.then((res) => {
				console.log(res);
				couponIds.push(res.id)
			})
			.catch((er) => {
				console.log(er);
				this.showToast('Error', er.message.body, 'error')
			})
		})
		let payload
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(() => {
			payload = this.paymentType === 'In Full'
				? this.stripe.generateOneTimePayload(data, couponIds)
				: this.stripe.generateSubscriptionPayload(data, couponIds)
				
			console.log('Coupon Payload ' + payload);
			this.createSession(data.auth, payload);			
		}, 3000);
	}

	createSession(auth, payload) {
		this.stripe.makeCallout(auth, payload, 'v1/checkout/sessions')
        .then((res) => {
			console.log(res);

			const fields = {};
			fields[STRIPE_TRANSACTION_ID_FIELD.fieldApiName] = res.id;
			fields[ID_FIELD.fieldApiName] = this.cartData.Id;
            fields[STATUS_FIELD.fieldApiName] = 'Checkout Initiated';

			if (this.credits.length > 0) {
				this.createAppliedCredits();
			}

            const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {
				const event = new CustomEvent('senttocheckout', {
					detail: {
						sent: true
					}
				})
				this.dispatchEvent(event)

                this.showToast(
                    'Success!',
                    'Please Complete Checkout in the New Window',
                    'success'
                );
            });
                
            window.open(res.url, '_blank');
        })
        .catch(e => {
            console.log(e);
            this.showToast('Error', e.body.message, 'error')
        })
	}

	// # HANDLERS

	@api sendPayment() {
		let data = {};
		let frequency;
		let length;

		switch (this.paymentType) {
			case 'Monthly':
				frequency = 'month';
				length = this.monthDiff(new Date(this.cartData.startDate), new Date(this.cartData.endDate));
				break;
			case 'Weekly':
				frequency = 'week';
				length = this.weekDiff(new Date(this.cartData.startDate), new Date(this.cartData.endDate));
				break;
			default:
				break;
		}

		data.items = [];
		this.cartData.Cart_Products__r.forEach((e) => {
			data.items.push({
				price:
					this.paymentType === 'In Full'
						? e.Price_Cents__c.toFixed(2)
						: (e.Price_Cents__c / length).toFixed(12),
				qty: e.Quantity__c,
				name: e.Name
			});
		});

		data.frequency = frequency;
		data.length = length;
		data.success = this.wiredSettings.data.Success_Redirect__c;
		data.failure = this.wiredSettings.data.Failure_Redirect__c;
		data.auth = this.wiredSettings.data.Bearer_Token__c;
	
		if (this.credits.length > 0) {
			this.createSessionWithCoupons(data);
		} else {
			let payload = this.paymentType === 'In Full'
				? this.stripe.generateOneTimePayload(data)
				: this.stripe.generateSubscriptionPayload(data);

			console.log('Session Payload ' + payload);
			this.createSession(data.auth, payload);
		}
	}

	// # GETTERS/SETTERS
}
