export class stripe {
	// * sessionObj Structure
	// * {
	// *     success_url: www.123.com,
	// *     cancel_url: www.123.com,
	// *     auth: 123456789,
	// *     frequency: 'month'/'week',
	// *     length: 6 (months/weeks),
	// *     items: [
	// *         {
	// *             price: 123456 (in cents),
	// *             qty: 1,
	// *             name: 'Product Name'
	// *         }
	// *     ]
	// * }

	generateCouponPayload(amt) {
		let body = {
			amount_off: amt * 100,
			duration: 'once',
			currency: 'usd'
		};
		return new URLSearchParams(Object.entries(body)).toString();
	}

	generateOneTimePayload(sessionObj) {
		return this.generateOneTimePayload(sessionObj, null);
	}

	generateOneTimePayload(sessionObj, coupons) {
		let index = 0;
		let body = {};
		sessionObj.items.forEach((e) => {
			body[`line_items[${index}][price_data][unit_amount_decimal]`] = e.price;
			body[`line_items[${index}][quantity]`] = e.qty;
			body[`line_items[${index}][price_data][product_data][name]`] = e.name;
			body[`line_items[${index}][price_data][currency]`] = 'usd';
			index++;
		});
		body.mode = 'payment';
		body['payment_method_types[0]'] = 'card';
		body.success_url = sessionObj.success;
		body.cancel_url = sessionObj.failure;

		
		if (coupons) {
			index = 0;
		coupons.forEach(e => {
			body[`discounts[${index}][coupon]`] = e;
			index++;
		})
		}	
				
		console.log('Payload Body', body);
		return new URLSearchParams(Object.entries(body)).toString();
	}

	generateSubscriptionPayload(sessionObj) {
		return this.generateSubscriptionPayload(sessionObj, null);
	}

	generateSubscriptionPayload(sessionObj, coupons) {
		let index = 0;
		let body = {};
		sessionObj.items.forEach((e) => {
			body[`line_items[${index}][price_data][unit_amount_decimal]`] = e.price;
			body[`line_items[${index}][quantity]`] = e.qty;
			body[`line_items[${index}][price_data][product_data][name]`] = e.name;
			body[`line_items[${index}][price_data][currency]`] = 'usd';
			body[`line_items[${index}][price_data][recurring][interval]`] = sessionObj.frequency;
			body[`line_items[${index}][price_data][recurring][interval_count]`] = 1;
			index++;
		});
		body.mode = 'subscription';
		body['payment_method_types[0]'] = 'card';
		body['metadata[subscriptionInfo]'] = JSON.stringify({
			frequency: sessionObj.frequency,
			length: sessionObj.length
		});
		body.success_url = sessionObj.success;
		body.cancel_url = sessionObj.failure;

		if (coupons) {
			index = 0;
			coupons.forEach(e => {
				body[`discounts[${index}][coupon]`] = e;
				index++;
			})
		}

		console.log('Subscription Payload', body);

		return new URLSearchParams(Object.entries(body)).toString();
	}

	makeCallout(auth, payload, uri, method='POST') {
		return fetch('https://api.stripe.com/' + uri, {
			method: method,
			headers: {
				'Content-Type': 'application/x-www-form-urlencoded',
				Authorization: `Bearer ${auth}`,
				'Accept-Encoding': "gzip, deflate, br'",
				Accept: '*/*',
			},
			body: payload ? payload : null,
		}).then((resp) => resp.json());
	}
}
