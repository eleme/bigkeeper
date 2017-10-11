# BigStash

big-stash is an enhancement for `git stash` command, you can use it to add and apply a stash with the name you have specified before.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'big_stash'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install big_stash

## Usage

Run `bin/big-stash` to learn how to use big-stash.

### Add a stash with name

If you want to add a stash for a git repository, run following command:

``` ruby
bin/big-stash -p [root path for a git repository] add [name of the stash]
```

### Apply a stash with name

If you want to apply a stash for a git repository, run following command:

``` ruby
bin/big-stash -p [root path for a git repository] apply [name of the stash]
```

### List all the stashes

If you want to list all the stashes for a git repository, run following command:

``` ruby
bin/big-stash -p [root path for a git repository] list
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/big_stash.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
