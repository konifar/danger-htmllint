# danger-htmllint
[![](https://github.com/konifar/danger-htmllint/workflows/CI/badge.svg)](https://github.com/konifar/danger-htmllint/actions)

[Danger](http://danger.systems/ruby/) plugin for [htmllint](http://htmllint.github.io/).

## Installation

    $ gem install danger-htmllint
    
`danger-htmllint` depends on [`htmllint-cli`]((https://github.com/htmllint/htmllint-cli)). You need to install it before running Danger.

## Usage

    Methods and attributes from this plugin are available in
    your `Dangerfile` under the `htmllint` namespace.

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
