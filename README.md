# Adap
Adap is a program that synchronize user data on AD to LDAP.
Data synchronized to LDAP are limited such as dn, cn uid and uidNumber etc.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'adap'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install adap

## Usage

To build this modules, run the command like below.

```
gem build adap.gemspec
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/adap.
