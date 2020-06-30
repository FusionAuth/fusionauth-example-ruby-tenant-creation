# FusionAuth Tenant example

This script adds a new tenant and set ups a custom theme and application for that tenant.

## To install

`bundle install`

This has been tested with ruby 2.7.

## To run

* create an API key
* edit the file and update the `NAME` and the `FA_URL`_constants.
* run the script to create a new tenant: `API_KEY=... ruby tenant-example.rb`
* or retrieve a user: `API_KEY=... ruby client-request.rb`

## More info


