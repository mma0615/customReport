import { LightningElement, api } from 'lwc';
import getReportMetadata from '@salesforce/apex/ReportComponentController.getReportMetadata';

export default class CustomReport extends LightningElement 
{
    @api reportId ='00O5w000009hZ35EAE';

    connectedCallback()
    {
        getReportMetadata({ Id: '00O5w000009hZ35EAE' })
            .then(result => {
                console.log('getReportMetadata ==> Json Result: ' + (result));
                this.error = undefined;
            })
            .catch(error => {
                console.log('getReportMetadata ==> Json Error: ' + JSON.stringify(error));
                this.error = error;
                this.data = undefined;
            });
    }

}