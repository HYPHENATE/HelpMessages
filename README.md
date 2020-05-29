[![codecov](https://codecov.io/gh/HYPHENATE/HelpMessages/branch/master/graph/badge.svg)](https://codecov.io/gh/HYPHENATE/HelpMessages)
[![HYPHENATE](https://circleci.com/gh/HYPHENATE/HelpMessages.svg?style=svg&&circle-token=297c83f424a06b21dc3b4fa042318223464f67d7)](https://circleci.com/gh/HYPHENATE/HelpMessages)

# Help Messages

A simple tool that allow you to dynamically display help messages on page dependant on different configurations of record.
i.e. Opportunity - Recordtype = Donation - Status = Pledged you can display a series of help messages for staff to help them with what their next steps are.
Ability to save as draft that only editors can see on page and then publish. Equally you can unpublish something as well.

## Verion Control

### 1.0 - Initial release

- Object - Help Message - Object Used for storing the message in
- Object - Help Message Filters - Object Used for confirm when the message should appear
- Path - Help Message Status
- LWC Component - Dynamic component that can be loaded onto any page
- PermissionSet - Help Message Editor - This allows you to provide certain staff with the ability to edit the messages, add new, unpublish, publish messages
- PermissionSet - Help Message Viewer - This provides read access to the help messages and their filters to ensure they can be displayed on screen

## Part 1: Installation

<a href="https://githubsfdeploy.herokuapp.com?owner=HYPHENATE&repo=HelpMessages">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

1. You need to ensure you have your My Domain Configured.
2. Use the button above to deploy this to your salesforce.
3. Once deployed you are ready to setup / configure your first message.

## Part 2: Configuration

1. Apply the Help Message Editor permission set to yourself and any others who will need edit access
2. Create your first help message - (insert video link here)
3. Add the component to the record page - (insert video link here)
4. Apply the Help Message Viewer permission set to end users
5. Repeat and continue to repeat until you have go rid of your old offline documentation for your processes.

<a href="https://web.microsoftstream.com/video/cef94101-46a5-4d8d-8538-51fd6584c005">Help Messages Setup Video</a>

## Part 3: Limitations

### Filters
- Support for AND and OR in your filters
- Support for only String comparisons Equals or not equals

## Credits

- Dan Croft - for the initial build
- National Lottery Community Fund - for the project that this idea came from
