# Quicker Quotes

Quicker Quotes aims to simplify the Salesforce standard quoting process.  It provides a sample flow that captures the minimal information needed to create a related opportunity and quote, and includes a quick-entry Products Table.  After adding the products, quantities and discounts, the flow automatically generates a PDF ready to send to the customer.

## Installation Requirements & Setup

* The component should only be installed in orgs after the Quoting functionality has been turned on (Setup -> Quote Settings -> Enable)
* Following install, add the "New Quicker Quote" action to any Account Page Layouts you want to initiate Quicker Quotes from.
* The first time the action is run the Flow will prompt the user to enter default settings for the component, such as the Opportunity Stage Name to use, the default Quote validity time, and the Quote Document template to use.

## Components

Quicker Quotes includes a few custom components:

qqProductsTable: Custom Lightning Web Component (LWC) that streamlines the entry of Quote Line Items

QQ_CreateQuotePDF: Custom Apex Action to generate the PDF quote

QQ_NavigateToRecord: Flow Action Component to redirect the user to the newly created Quote at the end of the flow.
