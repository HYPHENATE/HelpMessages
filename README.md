# Help Messages

A simple tool that allow you to dynamically display help messages on page dependant on different configurations of record.
i.e. Opportunity - Recordtype = Donation - Status = Pledged you can display a series of help messages for staff to help them with what their next steps are.

## Verion Control

### 1.0 - Initial release
2 x Objects:
Help Message - Object Used for storing the message in
Help Message Filters - Object Used for confirm when the message should appear

1 x LWC Component
Dynamic component that can be loaded onto any page

2 x Permission Sets
Help Message Admin - This allows you to provide certain staff with the ability to edit the messages, add new, unpublish, publish messages
Help Message Viewer - This provides read access to the help messages and their filters to ensure they can be displayed on screen

## Part 1: Installation

<a href="https://githubsfdeploy.herokuapp.com?owner=HYPHENATE&repo=HelpMessages">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

1. You need to ensure you have your My Domain Configured.
2. Use the button above to deploy this to your salesforce.
3. Once deployed you are ready to setup / configure your first message.

## Part 2: Configuration

TODO - Include step by step guidance on how to configure the application

## Part 3: Limitations

### Filters
At the moment we only have support for AND and OR in your filters - Custom Filters are coming
