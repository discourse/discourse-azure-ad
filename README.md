### discourse-azure-oauth2

A Discourse plugin to enable login for Microsoft Azure Active Directory users via OAuth2.


### Configuration

Add your Discourse site as an application in Windows Azure Active Directory (WAAD). [Follow instructions here](https://msdn.microsoft.com/en-us/library/azure/dn132599.aspx), and use the following values:

* **Name** is not important.
* Choose "**Web Application and/or Web API**" as the application type.
* **Sign-On URL** (aka Reply URL): enter the full URL with path `/auth/azure_oauth2/callback`. e.g., `http://discourse.example.com/auth/azure_oauth2/callback`
* **App ID URI**: use the root url of your Discourse site. e.g., `http://discourse.example.com`
* Click on the new app, choose **Configure** from the top nav, and generate a new key in the "**Keys**" section.
* In the Configure section, you'll find the **client ID**, and the key that you generated will be used as the **client secret**. Also make sure that the Reply URL is the full url to /auth/azure_oauth2/callback.
* A "resource" needs to be passed during the oauth2 request. This value is the same as the **app id uri**.

If you're running Discourse from the Docker container, add these environment variables to your container's yml file:

* DISCOURSE_AZURE_CLIENT_ID
* DISCOURSE_AZURE_CLIENT_SECRET
* DISCOURSE_AZURE_RESOURCE
* (optional) DISCOURSE_AZURE_TITLE

Or if you're not using Docker add the following to your `discourse.conf` file:

* azure_client_id
* azure_client_secret
* azure_resource
* (optional) azure_title
