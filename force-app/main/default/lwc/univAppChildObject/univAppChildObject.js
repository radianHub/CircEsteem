import { LightningElement, api, track } from 'lwc';

import getChildObjectFields from '@salesforce/apex/UniversalApp.getChildObjectFields';

export default class UnivAppChildObject extends LightningElement {
	@api section;
	@api fieldSet;
	@api objectName;
	@api parentField;
	@api title;
	@api addButtonLabel;

	fieldData;

	//objectMap = new Map();
	@track records = [];

	/*recordsSample = {
		Contact: {
			parentField: 'Account',
			records: [{}, {}, {}],
		},
		CustomObj__c: {
			parentField: 'Account__c',
			records: [{}, {}, {}],
		},
	};*/

	connectedCallback() {
		this.getFields();

		//this.objectMap.set('parentField', this.parentField);
		//this.objectMap.set('records', this.records);
	}

	getFields() {
		getChildObjectFields({
			ObjectName: this.objectName,
			FieldSetName: this.fieldSet,
		})
			.then((result) => {
				if (result.error) {
					this.throwAlertEvent(result.error, 'error');
				} else if (result.fielddata) {
					this.fieldData = result.fielddata;

					this.records.push(this.createNewRecord());
				}
			})
			.catch((error) => {
				this.throwAlertEvent(JSON.stringify(error), 'error');
			});
	}

	addChild() {
		this.records.push(this.createNewRecord());
	}

	createNewRecord() {
		let newRecord = {
			sobjectType: this.objectName,
		};
		return newRecord;
	}

	throwAlertEvent(alert, alertType) {
		let errorEvent = new CustomEvent('alert', {
			detail: {
				alert: alert,
				alertType: alertType,
			},
		});
		this.dispatchEvent(errorEvent);
	}

	onChangeHandler(event) {
		let dataset = event.target.dataset;

		this.records[dataset.index][dataset.fieldapi] = event.target.value;

		let changeEvent = new CustomEvent('update', {
			detail: {
				objectName: this.objectName,
				parentField: this.parentField,
				records: this.records,
				//objectMap: JSON.stringify(this.objectMap),
			},
		});
		this.dispatchEvent(changeEvent);
	}

	get isAddChildDisabled() {
		return this.records.length >= 10;
	}

	get fieldCount() {
		return this.fieldData.length;
	}

	get fieldSizeClass() {
		let classString = 'slds-size_' & Math.floor(11 / this.fieldCount) & '-of-12';
		//let classString = 'slds-size_1-of-' + (this.fieldCount + 1);
		return classString;
	}
}