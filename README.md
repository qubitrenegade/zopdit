# Zopdit

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/zopdit`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zopdit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zopdit

## Usage

TODO: Write usage instructions here

## Development

Development is done with Ruby 2.6.  Habitat is used to manage this version of Ruby across different server types.  To setup an environment install habitat, then install the following packages:

* core/ruby26
* core/gcc
* core/gcc-libs (not 100% this is required)
* core/make
* core/sqlite

This can be done with one command:

```
sudo hab pkg install core/ruby26 core/gcc core/gcc-libs core/make core/sqlite --binlink --force
```

Make bundler install gems locally:

```
bundle config --local path vendor/bundle
```

Then you'll have to tell bundler where to find sqlite libs: 

```
bundle config --local build.sqlite3 --with-sqlite3-dir="$(hab pkg path core/sqlite)"
```


After checking out the repo, all of the above steps can be completed by running `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Create a new database with

```
bundle exec sequel -m db/migrations sqlite://db/test.db
```

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/zopdit.
