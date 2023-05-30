# StringofFate API

API to store and retrieve platform and link information of digital namecard of String of Fate cardect.

## Routes

All routes return Json

- GET  `/`: Root route shows if Web API is running
- GET  `api/v1/accounts/[username]`: Get account details
- POST  `api/v1/accounts`: Create a new account
- GET  `api/v1/platforms/[plat_id]/links/[link_id]`: Get a link
- GET  `api/v1/platforms/[plat_id]/links`: Get list of links for platform
- POST `api/v1/platforms/[ID]/links`: Upload link for a platform
- GET  `api/v1/platforms/[ID]`: Get information about a platform
- GET  `api/v1/platforms`: Get list of all platforms
- POST `api/v1/platforms`: Create new platform

## Install

Install this API by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```

## Execute

Run this API using:

```shell
puma
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```
## Execute

Launch the API using:

```shell
rake run:dev
```


## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass:

```shell
rake release?
```

## Develop Shortcut
### Develop/Debug

Add fake data to the development database to work on this cardect:

```shell
rake db:seed
```

<details>
<summary> Click for tips</summary>
&nbsp
## DB drop and migrate again shortcut
For DEV
 ```shell
rake db:rebuild
```
For Test
```shell
RACK_ENV=test rake db:rebuild
```

## Test puma working using httpie
```shell
http -v GET http://0.0.0.0:9292/
```
</details>
