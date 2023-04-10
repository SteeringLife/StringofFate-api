# StringofFate

API of StringofFate

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/userinfo/`: returns all confiugration IDs
- GET `api/v1/userinfo/[ID]`: returns details about a single userinfo with given ID
- POST `api/v1/userinfo/`: creates a new userinfo

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
puma
```
