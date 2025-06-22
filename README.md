# Shiftcare CLI

## Requirements

- Ruby 3.4.4 (It likely works on older versions but has only been tested on this version)

## Setup

- clone repository to your local machine
```
git clone git@github.com:RobertCurry0216/shiftcare-cli.git
```

- Move into the new directory and run bundle install:
```
cd shiftcare-cli
bundle install
```

- Next you need to point the config file at the json file on your local machine. You can either do this by manually updating `filepath` in `/config/cli.yml` or by running the `config` command.

```
ruby ./lib/shiftcare.rb config -f <path to data.json>
```


## Usage

### Search for name

To search for a partial string in the user names, use the `search` command.

This accepts one argument, a string, which will be compared against all users in the data store and return all that partially match the provided string.

This search will ignore case and any leading / trailing whitespace.

```
ruby ./lib/shiftcare.rb search <VALUE>
```

#### example

```
$ ruby ./lib/shiftcare.rb search john
{"id" => 1, "full_name" => "John Doe", "email" => "john.doe@gmail.com"}
{"id" => 3, "full_name" => "Alex Johnson", "email" => "alex.johnson@hotmail.com"}
```


### Find Email collisions

To find all uses who have the same email as at least one other user, use the `email_collisions` command.

```
ruby ./lib/shiftcare.rb email_collisions
```

#### example

```
$ ruby ./lib/shiftcare.rb email_collisions
{"id" => 2, "full_name" => "Jane Smith", "email" => "jane.smith@yahoo.com"}
{"id" => 15, "full_name" => "Another Jane Smith", "email" => "jane.smith@yahoo.com"}
```

### Unit tests

To run the unit tests simply run `rspec`

```
rspec
```


## Assumptions

- That the json data store will be stored on the local machine and won't need to be changed often.
- That matching should be done ignoring case. ie: `john` and `JoHn` should match.
- That the data is un-ordered. When searching through un-oredered data you can't do much better than O(n) so I didn't spend much time trying to optimise the search methods.
- That missing data should be handled gracefully and not throw an error, ie: if a record is missing a `full_name` value, just treat is as an empty string and keep moving.

## Limitations

- json file size: The data is naively loaded into memory using `File.read` which will cause slow down if the json file grows too large. However it is adequate for the provided json file.
- Cannot handle nested data. While the keys for `full_name` and `email` can be updated in the config file, it can't handle anything other than top level reads.


## Project Structure


- `/lib/`
  - `/cli/`
    - `runner.rb`
      - The CLI runner, this is what handles cli arguments and calls.
  - `/datastores/`
    - The collection of datastores. Currently only `JsonStore` is available but if more are to be added in the future, this is where they'd go.
    - `core.rb`
      - Core functions for datastores. This is where the factory method lives.
    - `base_store.rb`
      - The abstract base class for all data stores
    - `json_store.rb`
      - a datastore that uses a json file for is data.
  - `shiftcare.rb`
    - Cli entry point. Run this file to run the cli.
- `/config/`
  - `cli.yml`
    - Config for the cli
