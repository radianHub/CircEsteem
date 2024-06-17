import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getPricebookEntry from '@salesforce/apex/AddProductModalController.getPricebookEntry';

import CART_PRODUCT_OBJECT from '@salesforce/schema/Cart_Product__c';
import NAME_FIELD from '@salesforce/schema/Cart_Product__c.Name';
import PRICE_FIELD from '@salesforce/schema/Cart_Product__c.Price__c';
import QUANTITY_FIELD from '@salesforce/schema/Cart_Product__c.Quantity__c';
import CART_FIELD from '@salesforce/schema/Cart_Product__c.Cart__c';
import PRODUCT_FIELD from '@salesforce/schema/Cart_Product__c.Product__c';

export default class AddProductModal extends LightningModal {
	@api productId;
	@api cartId;

	product;
	quantity = 1;

	loadingData = true;
	creatingData = false;

	error;

	// # APEX

	// *
	@wire(getPricebookEntry, { pricebookEntryId: '$productId' })
	wiredGetPricebookEntry({ data, error }) {
		if (data) {
			this.product = data;

			this.loadingData = false;
			this.error = undefined;
		} else if (error) {
			this.error = error;
			this.loadingData = false;
		}
	}

	// # HANDLERS

	// *
	handleClickAddToCart() {
		this.creatingData = true;

		let fields = {};
		fields[NAME_FIELD.fieldApiName] = this.product.Name;
		fields[PRICE_FIELD.fieldApiName] = this.product.UnitPrice;
		fields[QUANTITY_FIELD.fieldApiName] = this.quantity;
		fields[CART_FIELD.fieldApiName] = this.cartId;
		fields[PRODUCT_FIELD.fieldApiName] = this.product.Product2.Id;

		let cartProduct = {
			apiName: CART_PRODUCT_OBJECT.objectApiName,
			fields: fields,
		};

		createRecord(cartProduct)
			.then((record) => {
				this.showNotification('Success', 'Added to cart', 'success');
				this.error = undefined;

				this.creatingData = false;

				this.close('success');
			})
			.catch((error) => {
				console.log('error', error);
				this.error = error;

				this.creatingData = false;
			});
	}

	// *
	handleChangeQuantity(event) {
		this.quantity = event.detail.value;
	}

	// # HANDLERS

	// * DISPLAY TOAST NOTIFICATION
	showNotification(title, message, variant, mode = 'dismissable') {
		const toast = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode,
		});
		this.dispatchEvent(toast);
	}

	// # GETTERS

	// *
	get header() {
		if (this.product) {
			return `${this.product.Name} - $${this.price}`;
		}
		return 'Add Item';
	}

	// *
	get price() {
		return this.product?.UnitPrice;
	}

	// *
	get imageURL() {
		return this.product?.Product2.DisplayUrl;
	}

	// *
	get isLoading() {
		if (this.loadingData || this.creatingData) {
			return true;
		}
		return false;
	}
}