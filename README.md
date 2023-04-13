# StringofFate

API of StringofFate

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/userinfos/`: returns all confiugration IDs
- GET `api/v1/userinfos/[ID]`: returns details about a single userinfo with given ID
- POST `api/v1/userinfos/`: creates a new userinfo

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

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

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass:

```shell
rake release?
```
### Learn more
<details>
<summary>How we develop</summary>

- We use "dev" branch to manage conflict.

</details>