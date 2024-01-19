import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import getPricebookEntries from '@salesforce/apex/QQ_SearchPricebookEntries.getPricebookEntries';

export default class QqProductsSearchModal extends LightningModal {

    // Input
    @api pricebookId;
    @api currencyCode;

    // Output
    selectedEntries = [];

    @track pricebookData = [];

    dataLoaded = false;
    moreDataAvailable = false;

    keyword = null;
    totalCount;
    totalFilteredCount;
    offset;
    limit = 50;

    saveHandler() {
        this.close(this.selectedEntries);
    }

    getData(offset, resultLimit, concat) {
        getPricebookEntries({ keyword: this.keyword, pricebookId: this.pricebookId, offset: offset, resultLimit: resultLimit, currencyCode: this.currencyCode })
        .then(result => {
            let count = result.count;
            this.offset = offset;
            this.totalCount = result.totalCount;
            if (count > 0) {
                this.pricebookData = (concat) ? this.pricebookData.concat(result.records) : result.records;
            }
            this.moreDataAvailable = (this.pricebookData.length < this.totalCount) ? true : false;
            this.dataLoaded = true;
        })
        .catch(error => {
            console.log('**QQ: Error getting modal search data: '+error.message);
        });
    }

    rowSelectionHandler(event) {
        const id = event.currentTarget.dataset.id;
        const checked = event.currentTarget.checked;
        const arrayIndex = this.selectedEntries.findIndex((element) => element.id == id);
        if(checked) {
            // Add id to selectedEntries array if not already present
            if(arrayIndex == -1) {
                const entryData = this.pricebookData.find((element) => element.Id == id);
                this.selectedEntries.push({ Id : id, Name : entryData.Name, ProductCode : entryData.ProductCode, Product2Id : entryData.Product2Id, UnitPrice : entryData.UnitPrice});
            }
        } else {
            // Remove id from arry if present
            if(arrayIndex >= 0) {
                this.selectedEntries.splice(arrayIndex, 1);
            }
        }
    }

    entrySearchHandler(event) {
        this.keyword = event.currentTarget.value;
        this.getData(0, this.limit);
    }

    loadMoreRecords(event) {
        this.getData(this.offset+this.limit, this.limit, true);
    }

    connectedCallback() {
        this.getData(0, this.limit, false);
    }

}