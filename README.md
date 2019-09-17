# danger-htmllint
[![](https://github.com/konifar/danger-htmllint/workflows/CI/badge.svg)](https://github.com/konifar/danger-htmllint/actions)

[Danger](http://danger.systems/ruby/) plugin for [htmllint](http://htmllint.github.io/).

## Installation

    $ gem install danger-htmllint
    
`danger-htmllint` depends on [`htmllint-cli`]((https://github.com/htmllint/htmllint-cli)). You need to install it before running Danger.

## Usage

Set Dangerfile like this.

```
# Set .htmllintrc path (optional)
htmllint.rc_path = "/path/to/your/.htmllintrc"

# Set true if you want to fail CI when errors are detected (optional)
htmllint.fail_on_error = true

# Run htmllint to only added or modified files (required)
htmllint.lint
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
