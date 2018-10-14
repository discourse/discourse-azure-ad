### discourse-azure-oauth2

A Discourse plugin to enable login Microsoft Azure Active Directory users via OAuth2.

## Installation

Follow the directions at [Install a Plugin](https://meta.discourse.org/t/install-a-plugin/19157) using https://github.com/discourse/discourse-oauth2-basic.git as the repository URL.

### Configuration

Add your Discourse site as an application in Windows Azure Active Directory (WAAD). [Follow instructions here](https://msdn.microsoft.com/en-us/library/azure/dn132599.aspx), and use the following values:

* **Name** is not important.
* Choose "**Web Application and/or Web API**" as the application type.
* **Sign-On URL** (aka Reply URL): enter the full URL with path `/auth/azure_oauth2/callback`. e.g., `http://discourse.example.com/auth/azure_oauth2/callback`
* **App ID URI**: use the root url of your Discourse site. e.g., `http://discourse.example.com`
* Click on the new app, choose **Configure** from the top nav, and generate a new key in the "**Keys**" section.
* In the Configure section, you'll find the **client ID**, and the key that you generated will be used as the **client secret**. Also make sure that the Reply URL is the full url to /auth/azure_oauth2/callback.

Visit your **Admin** > **Settings** > **Login** and fill in the basic
configuration for the Azure AD provider:

* `azure_enabled` - check this off to enable the feature

* `azure_client_id` - the client ID from your Azure Ad

* `azure_client_secret` - the client secret from your Azure Ad