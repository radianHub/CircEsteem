import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import getCart from '@salesforce/apex/ShopController.getCart';
import createCart from '@salesforce/apex/ShopController.createCart';
import getPricebookEntries from '@salesforce/apex/ShopController.getPricebookEntries';

import AddProductModal from 'c/addProductModal';
import ViewCart from 'c/viewCart';

export default class Shop extends LightningElement {
	cart;
	pricebookEntries;

	loadingCart = true;
	loadingPricebookEntries = true;
	creatingData = false;

	error = undefined;

	// # APEX

	// *
	@wire(getCart)
	wiredGetCart(value) {
		this.wiredCart = value;
		let { data, error } = value;

		if (data) {
			if (data.length === 1) {
				this.cart = data[0];
			}
			if (data.length === 0) {
				this.createCart();
			}

			this.loadingCart = false;
			this.error = undefined;
		} else if (error) {
			console.log('error', error);
			this.error = error;
			this.loadingCart = false;
		}
	}

	// *
	createCart() {
		createCart()
			.then((result) => {
				this.cart = result;
				this.creatingData = false;
			})
			.catch((error) => {
				console.log('error', error);
				this.creatingData = false;
			});
	}

	// *
	@wire(getPricebookEntries)
	wiredGetPricebookEntries({ data, error }) {
		if (data) {
			this.pricebookEntries = data;

			this.loadingPricebookEntries = false;
			this.error = undefined;
		} else if (error) {
			console.log('error', error);
			this.error = error;
			this.loadingPricebookEntries = false;
		}
	}

	// # HANDLERS

	// *
	handleClickProduct(event) {
		AddProductModal.open({
			productId: event.currentTarget.dataset.id,
			cartId: this.cart.Id,
		}).then((result) => {
			if (result === 'success') {
				refreshApex(this.wiredCart);
			}
		});
	}

	// *
	handleClickCart() {
		ViewCart.open({
			cartId: this.cart.Id,
			size: 'small',
			onremoveproductevent: (event) => {
				refreshApex(this.wiredCart);
			},
		}).then((result) => {
			refreshApex(this.wiredCart);
		});
	}

	// # GETTERS

	// *
	get isLoading() {
		if (this.loadingData || this.creatingData) {
			return true;
		}
		return false;
	}
}