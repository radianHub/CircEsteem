export class stripe {
	// * OBJ STRUCTURE
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

	generateOneTimePayload(obj) {
		let index = 0;
		let body = {};
		obj.items.forEach((e) => {
			body[`line_items[${index}][price_data][unit_amount_decimal]`] = e.price;
			body[`line_items[${index}][quantity]`] = e.qty;
			body[`line_items[${index}][price_data][product_data][name]`] = e.name;
			body[`line_items[${index}][price_data][currency]`] = 'usd';
			index++;
		});
		body.mode = 'payment';
		body['payment_method_types[0]'] = 'card';
		body.success_url = obj.success;
		body.cancel_url = obj.failure;

		console.log('Payload Body', body);

		return new URLSearchParams(Object.entries(body)).toString();
	}

	generateSubscriptionPayload(obj) {
		let index = 0;
		let body = {};
		obj.items.forEach((e) => {
			body[`line_items[${index}][price_data][unit_amount_decimal]`] = e.price;
			body[`line_items[${index}][quantity]`] = e.qty;
			body[`line_items[${index}][price_data][product_data][name]`] = e.name;
			body[`line_items[${index}][price_data][currency]`] = 'usd';
			body[`line_items[${index}][price_data][recurring][interval]`] = obj.frequency;
			body[`line_items[${index}][price_data][recurring][interval_count]`] = 1;
			index++;
		});
		body.mode = 'subscription';
		body['payment_method_types[0]'] = 'card';
		body['metadata[subscriptionInfo]'] = JSON.stringify({
			frequency: obj.frequency,
			length: obj.length
		});
		body.success_url = obj.success;
		body.cancel_url = obj.failure;

		console.log('Subscription Payload', body);

		return new URLSearchParams(Object.entries(body)).toString();
	}

	makeCallout(auth, payload) {
		return fetch('https://api.stripe.com/v1/checkout/sessions', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/x-www-form-urlencoded',
				Authorization: `Bearer ${auth}`,
				'Accept-Encoding': "gzip, deflate, br'",
				Accept: '*/*',
			},
			body: payload,
		}).then((resp) => resp.json());
	}
}
