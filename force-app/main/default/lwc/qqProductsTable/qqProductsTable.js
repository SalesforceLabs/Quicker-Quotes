import { LightningElement, track, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import qqProductsSearchModal from 'c/qqProductsSearchModal';

import getResults from '@salesforce/apex/QQ_SearchPricebookEntries.getResults';
import getQuoteLines from '@salesforce/apex/QQ_SearchPricebookEntries.getQuoteLines';

export default class QQProductsTable extends LightningElement {

    // Input Parameters
    @api pricebookId;
    @api quoteId;
    currencyCode;

    // Output Parameters
    @api quoteLineItems;
    @api deletedQuoteLineItems = [];
    _deletedQuoteLineItems = [];

    @api searchTerm = '';
    @api searchRecords = [];
    @track showSearch = false;
    activeLineIndex = -1;
    @track multipleRecords = false;
    hasRendered = false;
    isRecordSelected = false;
    isSelectingRecord = false;
    keyResultIndex = -1;

    // Column Resizing Variables
    mouseDown = false;
    mouseStart;
    widthStart;
    parentObj;

    @track _quoteData = [];

    modalResults = [];

    get quoteData() {
        return this._quoteData;
    }

    searchChangeHandler(event) {
        this.activeLineIndex = event.currentTarget.dataset.lineindex;
        let searchString = event.target.value;
        this.request = this.searchProducts(searchString, -1);
    }

    searchProducts(searchString, lineIndex) {
        if (searchString.length >= 2) {
            getResults({ keyword: searchString, pricebookId: this.pricebookId, currencyCode: this.currencyCode })
                .then(result => {
                    let count = result.count;
                    if (count > 0) {
                        this.searchRecords = result.records;
                        this.showSearch = true;
                    } else {
                        this.showSearch = false;
                    }
                    if (lineIndex >= 0) this.template.querySelector("[data-searchinput='" + lineIndex + "']").focus();
                })
                .catch(error => {
                    console.log('**QQ: Error searching for keywords: '+error.message);
                });
        } else {
            this.searchRecords = [];
            this.showSearch = false;
            if (lineIndex >= 0) this.template.querySelector("[data-searchinput='" + lineIndex + "']").focus();
        }
    }

    recordSelected(event) {
        this.isRecordSelected = true;
        const index = event.currentTarget.dataset.index;
        const lineIndex = event.currentTarget.dataset.lineindex;
        const selectedRecord = this.searchRecords[index];
        let line = {
            Id: null,
            PricebookEntryId: selectedRecord.Id,
            Product2Id: selectedRecord.Product2Id,
            ProductCode: selectedRecord.ProductCode,
            ProductName: selectedRecord.Name,
            UnitPrice: selectedRecord.UnitPrice,
            Quantity: this._quoteData[lineIndex].Quantity,
            Discount: this._quoteData[lineIndex].Discount,
            key: lineIndex,
            EditMode: false,
            AllowDelete: true
        }
        this._quoteData[lineIndex] = line;
        this.calcLine(lineIndex);
        this.searchRecords = [];
        this.showSearch = false;
        this.searchTerm = null;
        if (lineIndex == this._quoteData.length - 1) {
            this.addLine(false);
        }
        this.reindexQuoteData();
        this._quoteData[this._quoteData.length - 1].EditMode = true;
        try {
            let _this = this;
            setTimeout(function () {
                let qs = _this.template.querySelector("[data-quantityinput='" + _this.activeLineIndex + "']");
                qs.focus();
            }, 0);
        } catch (error) {
            console.log('**QQ: Error selecting records: '+error.message);
        }

    }

    modalSearchHandler(event) {
        const lineindex = event.currentTarget.dataset.lineindex;
        qqProductsSearchModal.open({
            label: 'Products Table',
            size: 'large',
            pricebookId: this.pricebookId,
            currencyCode: this.currencyCode
        }).then((result) => {
            if (typeof result !== 'undefined') {
                if (result.length > 0) {
                    this.modalResults = result;
                    this.processModalResults();
                }
            }
        });
    }

    processModalResults() {
        this._quoteData.pop();
        this.modalResults.forEach(selectedEntry => {
            let lineIndex = this._quoteData.length;
            let line = {
                Id: null,
                PricebookEntryId: selectedEntry.Id,
                Product2Id: selectedEntry.Product2Id,
                ProductCode: selectedEntry.ProductCode,
                ProductName: selectedEntry.Name,
                UnitPrice: selectedEntry.UnitPrice,
                Quantity: null,
                Discount: null,
                key: lineIndex,
                EditMode: false,
                AllowDelete: true
            }
            this._quoteData.push(line);
            this.calcLine(lineIndex);
        });
        this.modalResults = [];
        this.searchRecords = [];
        this.showSearch = false;
        this.searchTerm = null;
        this.addLine(false);
        this.reindexQuoteData();
        this._quoteData[this._quoteData.length - 1].EditMode = true;
        try {
            let _this = this;
            setTimeout(function () {
                let qs = _this.template.querySelector("[data-quantityinput='" + _this.activeLineIndex + "']");
                qs.focus();
            }, 0);
        } catch (error) {
            console.log('**QQ: Error handling modal results: '+error.message);
        }

    }

    calcLineHandler(event) {
        const lineIndex = event.currentTarget.dataset.lineindex;
        const changedField = event.currentTarget.dataset.field;
        const changedValue = event.target.value;
        if (changedField === 'quantity') this._quoteData[lineIndex].Quantity = changedValue;
        if (changedField === 'unitprice') this._quoteData[lineIndex].UnitPrice = changedValue;
        if (changedField === 'discountpc') this._quoteData[lineIndex].Discount = changedValue;
        this.calcLine(lineIndex);
    }

    calcLine(lineIndex) {
        const discount = (this._quoteData[lineIndex].Discount) ? this._quoteData[lineIndex].Discount : 0;
        this._quoteData[lineIndex].Subtotal = this._quoteData[lineIndex].Quantity * (this._quoteData[lineIndex].UnitPrice * (100 - discount) / 100);
        this.updateFlow();
    }

    changeLineHandler(event) {
        const lineIndex = event.currentTarget.dataset.lineindex;
        this.changeLine(lineIndex);
    }

    changeLine(lineIndex) {
        this._quoteData.forEach((line, index) => {
            line.EditMode = (index == lineIndex) ? true : false;
        });
        this.activeLineIndex = lineIndex;
        this.searchTerm = this._quoteData[lineIndex].ProductName;
        this.searchProducts(this.searchTerm, lineIndex);
        this.updateFlow();
    }

    searchBlurHandler(event) {

        if (!this.isSelectingRecord) {
            if (this.activeLineIndex >= 0) this._quoteData[this.activeLineIndex].EditMode = false;
            this.searchTerm = null;
            this.searchRecords = [];
            this._quoteData[this._quoteData.length - 1].EditMode = true;

            if (this.isRecordSelected) {
                try {
                    window.setTimeout(function () {
                        // removed this one - seems to cause errors on iPad
                        // this.template.querySelector("[data-quantityinput='" + this.activeLineIndex + "']").focus();
                    }, 0);
                } catch (error) {
                    console.log('**QQ: Error handling search blur: '+error.message);
                }
                this.isRecordSelected = false;
            }
            this.showSearch = false;

        } else {
            this.isSelectingRecord = false;
        }
    }

    resultsKeyDownHandler(event) {
        if (event.key === 'Down' || event.key === 'ArrowDown') {
            event.preventDefault();
            try {
                if (this.keyResultIndex < this.searchRecords.length - 1) {
                    this.keyResultIndex++;
                    this.template.querySelector("li[data-index='" + this.keyResultIndex + "']").focus();
                }
            } catch (error) {
                console.log('**QQ: Error handling down arrow key: '+error.message);
            }
        } else if (event.key === 'Up' || event.key === 'ArrowUp') {
            event.preventDefault();
            try {
                if (this.keyResultIndex > 0) {
                    this.keyResultIndex--;
                    this.template.querySelector("li[data-index='" + this.keyResultIndex + "']").focus();
                } else {
                    this.template.querySelector("[data-searchInput='" + this.activeLineIndex + "']").focus();
                }
            } catch (error) {
                console.log('**QQ: Error handling up arrow key: '+error.message);
            }
        } else if (event.key === 'Enter' || event.key === 'Tab') {
            event.preventDefault();
            try {
                let selected = this.template.querySelector("li[data-index='" + this.keyResultIndex + "']");
                var clickEvent = document.createEvent('MouseEvents');
                clickEvent.initEvent("mousedown", true, true);
                selected.dispatchEvent(clickEvent);
            } catch (error) {
                console.log('**QQ: Error handling enter key: '+error.message);
            }
        } else if (event.key === 'Escape') {
            event.preventDefault();
            try {
                this.template.querySelector("[data-searchInput='" + this.activeLineIndex + "']").focus();
            } catch (error) {
                console.log('**QQ: Error handling escape key: '+error.message);
            }
        }
    }

    searchKeyDownHandler(event) {
        if ((event.key === 'Down' || event.key === 'ArrowDown') && this.showSearch) {
            event.preventDefault();
            try {
                this.isSelectingRecord = true;
                this.keyResultIndex = 0;
                this.template.querySelector("li[data-index='0']").focus();
            } catch (error) {
                console.log('**QQ: Error handling down arrow key (search): '+error.message);
            }
        }

    }



    addLineHandler(event) {
        this.addLine(false);
    }

    addLine(focus) {
        this._quoteData.push({
            EditMode: true,
            AllowDelete: false,
            Id: null,
            ProductCode: null,
            ProductName: null,
            Quantity: null,
            UnitPrice: null,
            Subtotal: null,
            key: this._quoteData.length
        });
        if (focus && this.hasRendered) {
            try {
                this.template.querySelector("[data-searchinput='0']").focus();
            } catch (error) {
                console.log('**QQ: Error adding line: '+error.message);
            }
        }
    }

    deleteLineHandler(event) {
        const lineIndex = event.currentTarget.dataset.lineindex;
        let entryId = event.currentTarget.dataset.id;

        this._deletedQuoteLineItems.push({ Id : entryId });

        if (this.activeLineIndex >= 0) {
            if (this.activeLineIndex == lineIndex) this.activeLineIndex = -1;
            else if (this.activeLineIndex > lineIndex) this.activeLineIndex--;
        }
        this._quoteData.splice(lineIndex, 1);
        this.reindexQuoteData();
    }

    shiftLineHandler(event) {
        const lineIndex = parseInt(event.currentTarget.dataset.lineindex);
        this.arrayShifter(lineIndex, lineIndex + 1);
    }

    unshiftLineHandler(event) {
        const lineIndex = parseInt(event.currentTarget.dataset.lineindex);
        this.arrayShifter(lineIndex, lineIndex - 1);
    }

    arrayShifter(oldIndex, newIndex) {
        this._quoteData.splice(newIndex, 0, this._quoteData.splice(oldIndex, 1)[0]);
        this.reindexQuoteData();
    }

    reindexQuoteData() {
        this._quoteData.forEach((line, index) => {
            line.key = index;
            line.First = (index == 0 ? true : false);
            line.Last = (index == this._quoteData.length - 2 ? true : false);
        });
        this.multipleRecords = (this._quoteData.length > 2) ? true : false;
        this.updateFlow();
    }

    resizeMouseDown(event) {
        event.preventDefault();
        const target = event.target;
        let parentObj = target.parentNode;
        while (parentObj.tagName != 'TH') {
            parentObj = parentObj.parentNode;
        }
        this.parentObj = parentObj;
        this.mouseStart = event.clientX;
        this.widthStart = parentObj.offsetWidth;
        this.mouseDown = true;
    }

    resizeDrag(event) {
        if (this.mouseDown) {
            event.preventDefault();
            const start = parseFloat(this.mouseStart);
            const end = parseFloat(event.clientX);
            const diff = parseFloat(end - start);
            const oldWidth = parseFloat(this.widthStart);
            const newWidth = oldWidth + diff;
            this.parentObj.style.width = newWidth + 'px';
        }
    }

    resizeMouseUp(event) {
        event.preventDefault();
        if (this.mouseDown) this.mouseDown = false;
    }


    updateFlow() {
        let quoteData = [];
        this._quoteData.forEach((line, index) => {
            if (index < this.quoteData.length - 1) {
                quoteData.push({
                    Id: line.Id,
                    QuoteId: this.quoteId,
                    PricebookEntryId: line.PricebookEntryId,
                    Product2Id: line.Product2Id,
                    Quantity: (line.Quantity) ? line.Quantity : 1,
                    UnitPrice: line.UnitPrice,
                    Discount: line.Discount
                });
            }
        });
        this.deletedQuoteLineItems = this._deletedQuoteLineItems;
        this.dispatchEvent(new FlowAttributeChangeEvent('quoteLineItems', quoteData));
        this.dispatchEvent(new FlowAttributeChangeEvent('deletedQuoteLineItems', this.deletedQuoteLineItems));
    }

    processQuoteLines() {

        getQuoteLines({ quoteId: this.quoteId })
            .then(result => {
                let parsedData = JSON.parse(result);
                if(parsedData.currencyCode) this.currencyCode = parsedData.currencyCode;
                parsedData.quoteLines.forEach((quoteLine, index) => {
                    const lineIndex = this._quoteData.length;
                    this._quoteData.push({
                        Id: quoteLine.Id,
                        PricebookEntryId: quoteLine.PricebookEntryId,
                        Product2Id: quoteLine.Product2Id,
                        ProductCode: quoteLine.Product2.ProductCode,
                        ProductName: quoteLine.Product2.Name,
                        UnitPrice: quoteLine.PricebookEntry.UnitPrice,
                        Quantity: quoteLine.Quantity,
                        Discount: quoteLine.Discount,
                        key: lineIndex,
                        EditMode: false,
                        AllowDelete: true
                    });
                    this.calcLine(lineIndex);
                });
                this.addLine(false);

            })
            .catch(error => {
                console.log('**QQ: Error initializing Quote Lines: '+error.message);
            });

    }

    connectedCallback() {
        this.processQuoteLines();
    }

    renderedCallback() {
        if (!this.hasRendered && this._quoteData.length == 1) {
            try {
                this.template.querySelector("[data-searchinput='0']").focus();
                this.hasRendered = true;
            } catch (error) {
                console.log('**QQ: Error rendering Products Table: '+error.message);
            }
        }
    }


}