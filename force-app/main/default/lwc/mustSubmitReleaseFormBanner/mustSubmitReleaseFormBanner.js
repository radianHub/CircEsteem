import { LightningElement, track, wire } from 'lwc';
import needsNewReleaseFormSubmission from '@salesforce/apex/ContactService.needsNewReleaseFormSubmission';

export default class MustSubmitReleaseFormBanner extends LightningElement {

    @track displayBanner;


    @wire(needsNewReleaseFormSubmission)
    wiredNeedsNewReleaseFormSubmission(value) {
        let {data, error} = value;
        
        if(data) {
            this.displayBanner = data;
        }
        
    }

    
}