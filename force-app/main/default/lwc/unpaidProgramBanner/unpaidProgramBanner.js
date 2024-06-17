import { LightningElement, wire, track } from "lwc";

import USER_ID from '@salesforce/user/Id';

import getUserProgramCart from '@salesforce/apex/UnpaidProgramBannerController.getUserProgramCart';

export default class UnpaidProgramBanner extends LightningElement {
	@track displayBanner

    cart;

    @wire(getUserProgramCart, { userId: USER_ID })
    wiredCart({ error, data }) {
        if (data) {
            this.cart = data.map(e => {
                return {
                    ...e,
                    uri: `/s/unpaid-program?c__session=${e.Program_Session__c}&c__contact=${e.Contact__c}&c__cart=${e.Id}`
                }
            })

            console.log('Cart', this.cart);
            
            this.displayBanner = true;
        } else if (error) {
            console.log(error);
        }
    }
}