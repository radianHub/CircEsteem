import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

let sCanvas, context;
let mDown = false;
let currPos = { x: 0, y: 0 };
let prePos = { x: 0, y: 0 };

export default class SignaturePanel extends LightningModal {
	@api imgURL;
	@api imgData;
	isAnyStroke = false;
	disableClose = true;

	constructor() {
		super();
		// Mouse Events
		this.template.addEventListener('mousedown', this.handleMousedown.bind(this));
		this.template.addEventListener('mouseup', this.handleMouseup.bind(this));
		this.template.addEventListener('mousemove', this.handleMousemove.bind(this));
		this.template.addEventListener('mouseout', this.handleMouseend.bind(this));

		// Touch Events
		this.template.addEventListener('touchstart', this.handleTouchStart.bind(this));
		this.template.addEventListener('touchend', this.handleTouchEnd.bind(this));
		this.template.addEventListener('touchmove', this.handleTouchMove.bind(this));
	}

	renderedCallback() {
		sCanvas = this.template.querySelector('canvas');
		if (FORM_FACTOR === 'Large') {
			sCanvas.width = 799;
		} else if (FORM_FACTOR === 'Medium') {
			sCanvas.width = 606;
		} else {
			sCanvas.width = 292;
		}
		context = sCanvas.getContext('2d');
	}

	// # PRIVATE METHODS

	// * DISPLAY A TOAST MESSAGE
	showToast(title, msg, variant, mode = 'dismissible') {
		const event = new ShowToastEvent({
			title: title,
			message: msg,
			variant: variant,
			mode: mode,
		});
		this.dispatchEvent(event);
	}

	// * RECORDS A DRAWING
	draw() {
		context.beginPath();
		context.moveTo(prePos.x, prePos.y);
		context.lineCap = 'round';
		context.lineWidth = 1.5;
		context.strokeStyle = '#000000'; // black
		context.lineTo(currPos.x, currPos.y);
		context.closePath();
		context.stroke();
		this.isAnyStroke = true;
	}

	// # HANDLERS

	// * STARTS A DRAWING
	handleMousedown(evt) {
		evt.preventDefault();
		mDown = true;
		this.getPos(evt);
	}

	// * STOPS A DRAWING
	handleMouseup(evt) {
		evt.preventDefault();
		mDown = false;
	}

	// * CREATES A DRAWING
	handleMousemove(evt) {
		evt.preventDefault();
		if (mDown) {
			this.getPos(evt);
			this.draw();
		}
	}

	// * ENDS A DRAWING
	handleMouseend(evt) {
		evt.preventDefault();
		mDown = false;
	}

	// * STARTS A DRAWING
	handleTouchStart(evt) {
		this.getTouchPos(evt);
	}

	// * CREATES A DRAWING
	handleTouchMove(evt) {
		evt.preventDefault();
		this.getTouchPos(evt);
		this.draw();
	}

	// * ENDS A DRAWING
	handleTouchEnd(evt) {
		let wasCanvasTouched = evt.target === sCanvas;
		if (wasCanvasTouched) {
			evt.preventDefault();
			mDown = false;
		}
	}

	// * GETS MOUSE POSITION
	getPos(evt) {
		let cRect = sCanvas.getBoundingClientRect();
		prePos = currPos;
		currPos = {
			x: evt.clientX - cRect.left,
			y: evt.clientY - cRect.top,
		};
	}

	// * GETS TOUCH POSITION
	getTouchPos(touchEvent) {
		var rect = sCanvas.getBoundingClientRect();
		prePos = currPos;
		currPos = {
			x: touchEvent.touches[0].clientX - rect.left,
			y: touchEvent.touches[0].clientY - rect.top,
		};
	}

	// * CLEARS THE SIGNATURE BOX
	clickClearBtn() {
		context.clearRect(0, 0, sCanvas.width, sCanvas.height);
	}

	// * SENDS THE SIGNATURE DATA TO THE PARENT COMPONENT
	clickSaveBtn() {
		if (this.isAnyStroke) {
			context.globalCompositeOperation = 'destination-over';
			context.fillStyle = '#FFF';
			context.fillRect(0, 0, sCanvas.width, sCanvas.height);
			this.imageURL = sCanvas.toDataURL('image/png');
			this.imageData = this.imageURL.replace(/^data:image\/(png|jp);base64,/, '');

			this.disableClose = false;
			this.close({
				signed: true,
				signatureData: {
					imgURL: this.imageURL,
					imgData: this.imageData,
				},
			});
		} else {
			this.showToast('Error', 'You must provide a signature.', 'error');
		}
	}
}