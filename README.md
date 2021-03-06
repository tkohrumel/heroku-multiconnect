# Heroku Connect API Reference Architecture

For Salesforce ISVs, Heroku Connect makes it easy for you to build Heroku apps that extend the data and functionality of their Force.com managed packages. Using bi-directional synchronization between Salesforce and Heroku Postgres, Heroku Connect unifies the data in a Postgres database with the customers' contacts, accounts, and other custom objects in the Salesforce database.

This reference architecture demonstrates how a multitenant application on Heroku can be used to extend a distributed Force.com application via the Heroku Connect service. Moreover, it shows how to automate the setup and configuration of the Heroku Connect service per customer, which synchronizes data between that customer’s Salesforce environment and the ISV's centralized, multitenant Postgres database.

___

# Architecture

## Force.com

- An application containing a post-install script, which initializes the automation of Heroku Connect for each subscriber org into,  and metadata for a simple example use case.
- [Repository](https://github.com/tkohrumel/force-multiconnect)

*Note: In Salesforce post-installation scripts only operate within managed packages; for the sake of being open source, this project is necessarily an unmanaged package. Although the functionality of the post-install script can be triggered manually, the unmanaged package can be converted into a managed package such that the post-install script runs automatically.*

## Heroku

- Processes
  - Frontend Rails app, which handles the creation of sync operations, via the Heroku Connect API, between customers' Salesforce organizations and a multitenant Heroku Postgres database 
  - Ruby process for background jobs
- Add-ons
  - [Heroku Postgres database](https://devcenter.heroku.com/articles/heroku-postgresql)
  - [Heroku Connect](https://devcenter.heroku.com/articles/herokuconnect), with which select data from customers' Salesforce organizations are synchronized with the Postgres database
  - [Heroku Redis](https://devcenter.heroku.com/articles/heroku-redis) key-value store, which is used by background job process to store all job and operational data
  - [SendGrid](https://devcenter.heroku.com/articles/sendgrid), used for sending emails
  - [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler), used for scheduled processing of relevant social media records
  - [PaperTrail](https://devcenter.heroku.com/articles/papertrail), optional, used for log aggregation and management

See the [sequence diagram](https://github.com/tkohrumel/heroku-multiconnect/wiki/Sequence-Diagram) for a visual overview of how it works.

___

# Heroku Setup

## Step 1: Install the prerequisites

 If you have not already done so, [sign up for a free Heroku account](https://signup.heroku.com/) and [install the Heroku Toolbelt command line tool](https://toolbelt.heroku.com/).

## Step 2: Deploy the app and add-ons

Click the button below to deploy the Rails application and supporting services to the Heroku platform.
  
[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)
  
  
Next, use git to clone the Rails repository's source code to your local machine.

~~~~
$ heroku git:clone -a your-unique-app-name
$ cd your-unique-app-name
~~~~

## Step 3: Add the required config variables 

You'll set each of your environment variables the same way:

~~~
$ heroku config:set KEY=VALUE
~~~

### APP_NAME

The name of your Heroku app.


### HEROKU_API_TOKEN

This is a unique API token for your Heroku account, used by the application to provision Heroku Connect connections for each customer's Salesforce Org.

Obtain your Heroku account API key either on the ["Account" page](https://dashboard.heroku.com/account) (in the "API Key" section) on your dashboard or by running the following command:

~~~
$ heroku auth:token
~~~

### DEV_EMAIL

This is the default from which automated emails are sent to customers' administrators.

### SECRET

Key used for data encryption of sensitive subscriber organization details using AES-256. Generate this yourself or run the following command from your local project directory:

~~~~
$ heroku run ruby commands/generate_secret.rb
~~~~

Note that this is unecessary if using a Premium or Enterprise tiers of Heroku Postgres, which feature automatic encryption-at-rest of all data written to disk.

### SALESFORCE_KEY and SALESFORCE_SECRET

The value for these two config keys are generated by creating a Connected App, which you will do [later](#step-4-create-a-connected-app) during the Force.com setup.

____


# Force.com Setup

## Step 1: Install the source code

There are two ways to use [the Force.com code](https://github.com/tkohrumel/force-multiconnect) in this project. 

First, you can use the "Deploy to Salesforce" tool below:

<a href="https://githubsfdeploy.herokuapp.com?owner=tkohrumel&repo=force-multiconnect">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a> 

Alternatively, clone the source code from the Force.com repository and deploy to your org.

## Step 2: Configure the Custom Setting

Configure your Force.com development environment with the specific details of your Heroku app. For now, all you need to set is a single field in a custom setting.

1. Click on Setup in the upper right-hand menu.
2. Under "Build", click Develop -> Custom Settings.
3. Click "Heroku Config".
4. Click the "Manage" button.
5. Click "New".
6. For the Name, enter a name describing the Heroku app (e.g. *Web App*).
7. For the App Name, enter the name of your app in Heroku. This was either specified by you or automatically generated by Heroku (e.g. *trusty-cedar-4038*).

## Step 3: Create a Remote Site Setting

Before the Apex callout can call your app on Heroku to initiate the automated Heroku Connect setup, that app must be registered in the Remote Site Settings page of your Force.com development environment.

To register a new site from the Setup menu of your Force.com development environment:

1. Click New Remote Site.
2. Enter a descriptive term for the Remote Site Name.
3. Enter the URL for the remote site (e.g. *https://my-connect-app-copy.herokuapp.com*).
4. Optionally, enter a description of the site.
5. Click Save to finish.

## Step 4: Create a Connected App

Next, you must configure your Force.com development environment to permit users to use its OAuth.

1. Click on Setup in the upper right-hand menu.
2. Under “Build”, click Create -> Apps.
3. Scroll to the bottom and click “New” under “Connected Apps.”

Enter the following details for the remote application:

1. For Connected App Name, enter a name for your Connected App.
2. The API Name will be filled in automatically. Accept this value.
3. Enter an email address for Contact Email.
4. Select “Enable OAuth Settings” under the API dropdown.
5. For “Callback URL” provide a callback URL of your local app, e.g. http://localhost:5000/auth/salesforce/callback.
6. Give the app “Full access” scope. In production scenarios you may want to limit this scope.

After saving, you’ll see that Force.com provides you two values: a consumer key and a consumer secret. Use these values to [set the *SALESFORCE_KEY* and *SALESFORCE_SECRET* Heroku config vars](#step-3-add-the-required-config-variables) for your app.

_____

# Using the app 

Once you have set up all of the Force.com and Heroku components that constitute the solution, you're ready to get started.

1. Open the Developer Console in your Force.com development environment.
2. Open the 'Debug' menu and select 'Open Execute Anonymous Window'.
3. Enter the following code, then click 'Execute': 
~~~
HerokuConnectSetup.testRequest();
~~~

This method simulates the post-installation method that would be execute for each subscriber if you were to convert this code into a managed package.

At this point, you can follow the progression of the automated setup of the Heroku Connect connection by monitoring both the Heroku logs, using either the command line utility or an add-on like PaperTrail, as well as the Heroku dashboard.

