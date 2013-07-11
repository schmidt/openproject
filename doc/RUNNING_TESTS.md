# Testing OpenProject

## Cucumber

The cucucmber features can be run using rake. You can run the following
rake tasks using the command `bundle exec rake <task>`.

* `cucumber` Run core features
* `cucumber:plugins` Run plugin features
* `cucumber:all` Run core and plugin features
* `cucumber:custom[features]`: Run single features or folders of features

    Example: `cucumber:custom[features/issues/issue.feature]`
    * When providing multiple features, the task name and arguments must
      be enclosed in quotation marks.

      Example: `bundle exec rake "cucumber:custom[features/issues features/projects]"`

`cucumber:plugins` and `cucumber:all` accept an optional parameter which
allows specifying custom options to cucumber. This can be used for
executing scenarios by name, e.g. `"cucumber:all[-n 'Adding an issue link']"`.
Like with spaces in `cucumber:custom` arguments, task name and arguments
have to be enclosed in quotation marks.

Here are two bash functions which allow using shorter commands for running
cucumber features:

    # Run OpenProject cucumber features (like arguments to the cucumber command)
    # Example: cuke features/issues/issue.feature
    cuke() { bundle exec rake "cucumber:custom[$*]"; }

    # Run OpenProject cucumber scenarios by name
    # Example: cuken Adding an issue link
    cuken() { bundle exec rake "cucumber:all[-n '$*']"; }


## RSpec

You can run the specs with the following commands:

* `bundle exec rake spec` Run all core specs with a random seed
* `SPEC_OPTS="--seed 12935" bundle exec rake spec` Run the core specs with the seed 12935

TODO: how to run plugins specs.

## For the fancy programmer

* We are testing on travis-ci. Look there for your pull requests.<br />
  https://travis-ci.org/opf/openproject
* If you have enabled the terminal bell, add `; echo -e "\a"` to the end of your test command. The terminal bell will then tell you when your tests finished.

## Manual acceptance tests

* Sometimes you want to test things manually. Always remember: If you test something more than once, write an automated test for it.
* Assuming you do not have all Internet Explorer version installed on your computer, you can grab a VM with preinstalled IE's directly from Mircrosoft: http://www.modern.ie/en-us/virtualization-tools#downloads
