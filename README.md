# Quicker Quotes

Quicker Quotes aims to simplify the Salesforce standard quoting process.  It provides a sample flow that captures the minimal information needed to create a related opportunity and quote, and includes a quick-entry Products Table.  After adding the products, quantities and discounts, the flow automatically generates a PDF ready to send to the customer.


## Installation Requirements & Setup

* The component should only be installed in orgs after the Quoting functionality has been turned on (Setup -> Quote Settings -> Enable)
* Following install, add the "New Quicker Quote" action to any Account, Opportunity, and Contact Page Layouts you want to initiate Quicker Quotes from.
* You can also add the New Quicker Quote global action to any global publisher layouts. Don't use the global action on record page layouts, as it won't have the context of which record you're on.
* The first time the action is run the Flow will prompt the user to enter default settings for the component, such as the Opportunity Stage Name to use, the default Quote validity time, and the Quote Document template to use.


## Components

Quicker Quotes includes a few custom components:

qqProductsTable: Custom Lightning Web Component (LWC) that streamlines the entry of Quote Line Items

QQ_CreateQuotePDF: Custom Apex Action to generate the PDF quote

QQ_NavigateToRecord: Flow Action Component to redirect the user to the newly created Quote at the end of the flow.


## Packages

* Main Package (Quicker Quotes) in force-app folder designed to be installed as a managed AppExchange package. Like all managed packages, you can't edit any of the elements in it.  So if it's not perfect, you either need to install the Unlocked package in it's entirety, or install an Unlocked Extension package over the top.
* Extension Package (Quicker Quotes Extensions) in quicker-quotes-ext folder designed as an unlocked package for installation in addition to the managed AppExchange package.  Provides modifiable versions of the main flows, actions, Lightning Page and Custom Tab.
* PE Extension Package (Quicker Quotes PE Extensions) in quicker-quotes-pe-ext folder, designed as an unlocked package for installation in PE orgs.  Provides modifiable versions of the New Quotes flow, actions, Lightning Page and Custom Tab, with incompatible PDF functionality removed.
* 
