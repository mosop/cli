# Crystal CLI

Yet another library for building command-line interface applications, written in Crystal.

[![Build Status](https://travis-ci.org/mosop/cli.svg?branch=master)](https://travis-ci.org/mosop/cli)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  cli:
    github: mosop/cli
```

## Features
<a name="features"></a>

### Option Parser (Integrated with [optarg](https://github.com/mosop/optarg))

```crystal
class Command < Cli::Command
  class Options
    string "--hello"
  end

  def run
    puts "Hello, #{options.hello}!"
  end
end

Command.run %w(--hello world) # prints "Hello, world!"
```

### Access to Options

```crystal
class Command < Cli::Command
  class Options
    string "--option"
  end

  def run
    puts "#{options.option} #{args[0]} #{unparsed_args[0]}"
  end
end

Command.run %w(--option foo bar -- baz) # prints "foo bar baz"
```

### Access from Options

```crystal
class Command < Cli::Command
  class Options
    on("--go") { command.go(with: "the Wind") }
  end

  def go(with some)
    puts "Gone with #{some}"
    exit
  end
end

Command.run %w(--go) # prints "Gone with the Wind"
```

### Exit

```crystal
class Command < Cli::Command
  class Options
    on("--exit") { command.exit! }
    on("--abort") { command.error! }
  end
end

Command.run %w(--exit) # => 0
Command.run %w(--abort) # => 1
```

For more detail, see [Handling Exit](#handling_exit).

### Subcommand

```crystal
class Polygon < Cli::Supercommand
  command "triangle", default: true
  command "square"
  command "hexagon"

  module Commands
    class Triangle < Cli::Command
      def run
        puts 3
      end
    end

    class Square < Cli::Command
      def run
        puts 4
      end
    end

    class Hexagon < Cli::Command
      def run
        puts 6
      end
    end
  end
end

Polygon.run %w(triangle) # prints "3"
Polygon.run %w(square)   # prints "4"
Polygon.run %w(hexagon)  # prints "6"
Polygon.run %w()         # prints "3"
```

### Aliasing

```crystal
class Command < Cli::Supercommand
  command "loooooooooong"
  command "l", aliased: "loooooooooong"

  module Commands
    class Loooooooooong < Cli::Command
      def run
        sleep 1000
      end
    end
  end
end

Command.run %w(l) # sleeps
```

### Inheritance

```crystal
class Role < Cli::Command
  class Options
    string "--name"
  end
end

class Chase < Cli::Supercommand
  command "mouse"
  command "cat"

  module Commands
    class Mouse < Role
      def run
        puts "#{options.name} runs away."
      end
    end

    class Cat < Role
      def run
        puts "#{options.name} runs into a wall."
      end
    end
  end
end

Chase.run %w(mouse --name Jerry) # prints "Jerry runs away."
Chase.run %w(cat --name Tom)     # prints "Tom runs into a wall."
```

### Help

```crystal
class Lang < Cli::Command
  class Help
    title "#{global_name} [OPTIONS] #{argument_names}"
    header "Converts a language to other languages."
    footer "(C) 20XX mosop"
  end

  class Options
    arg "from", desc: "source language"
    array "--to", var: "LANG", desc: "target language", default: %w(ruby crystal)
    string "--indent", var: "NUM", desc: "set number of tab size", default: "2"
    bool "--std", not: "--Std", desc: "use standard library", default: true
    on("--help", desc: "show this help") { command.help! }
  end
end

Lang.run %w(--help)
# lang [OPTIONS] FROM
#
# Converts a language to other languages.
#
# Arguments:
#   FROM  source language
#
# Options:
#   --indent NUM          set number of tab size
#                         (default: 2)
#   --std                 use standard library
#                         (enabled as default)
#   --Std                 disable --std
#   --to LANG (multiple)  target language
#                         (default: ruby, crystal)
#   --help                show this help
#
# (C) 20XX mosop
```

### Help for Subcommands

```crystal
class Package < Cli::Supercommand
  command "install", default: true
  command "update"
  command "remove"
  command "uninstall", aliased: "remove"

  class Help
    title "#{global_name} [SUBCOMMAND] | [OPTIONS]"
  end

  class Options
    on("--help", desc: "show this help") { command.help! }
  end

  class Base < Cli::Command
    class Help
      title "#{global_name} [OPTIONS] #{argument_names}"
    end

    class Options
      arg "package_name", desc: "specify package's name"
      on("--help", desc: "show this help") { command.help! }
    end
  end

  module Commands
    class Install < Base
      class Help
        caption "install package"
      end

      class Options
        string "-v", var: "VERSION", desc: "specify package's version"
      end
    end

    class Update < Base
      class Help
        caption "update package"
      end

      class Options
        bool "--break", desc: "update major version if any"
      end
    end

    class Remove < Base
      class Help
        caption "remove package"
      end

      class Options
        bool "-f", desc: "force to remove"
      end
    end
  end
end

Package.run %w(--help)
# package [SUBCOMMAND] | [OPTIONS]
#
# Subcommands:
#   install (default)  install package
#   remove             remove package
#   uninstall          alias for remove
#   update             update package
#
# Options:
#   --help  show this help

Package.run %w(install --help)
# package install [OPTIONS] PACKAGE_NAME
#
# Arguments:
#   PACKAGE_NAME  specify package's name
#
# Options:
#   -v VERSION  specify package's version
#   --help      show this help
end

Package.run %w(update --help)
# package update [OPTIONS] PACKAGE_NAME
#
# Arguments:
#   PACKAGE_NAME  specify package's name
#
# Options:
#   --major  update major version if any
#   --help   show this help
end

Package.run %w(remove --help)
# package remove [OPTIONS] PACKAGE_NAME
#
# Arguments:
#   PACKAGE_NAME  specify package's name
#
# Options:
#   -f      force to remove
#   --help  show this help

Package.run %w(uninstall --help)
# package remove [OPTIONS] PACKAGE_NAME
#
# Arguments:
#   PACKAGE_NAME  specify package's name
#
# Options:
#   -f      force to remove
#   --help  show this help
```

## Usage

```crystal
require "cli"
```

and see [Features](#features).

## Handling Exit
<a name="features"></a>

You can handle a command's exit with one of the 3 methods, `help!`, `exit!` and `error!`.

### help!

```crystal
class Command < Cli::Command
  def run
    help!
  end
end

Command.run # => 0
```

This command just ends after printing its help message. `Command.run` returns 0 as exit code.

To print message to STDERR and exit with an error code, use `error` option.

```crystal
help! error: true
```

If the `:error` option is true, `run` method returns 1 as exit code. To specify a number, use the `:code` option.

```crystal
help! code: 22
```

You can also let it exit with an additional message:

```crystal
help! message: "You passed an illegal option! See help!"
```

Or simply:

```crystal
help! "You passed an illegal option! See help!"
```

Calling `help!` with the `:message` argument implies that the `:error` option is true. To exit normally, set false to `:error`.

### exit! and error!

`exit!` is more general than `help!`.

```crystal
class Command < Cli::Command
  def run
    exit!
  end
end

Command.run # => 0
```

It just ends and returns 0 as exit code without printing.

To print a message:

```crystal
exit! "bye."
```

Or more variations:

```crystal
exit! help: true # same as help!
exit! error: true # returns 1 as exit code
exit! "message", error: true, help: true # same as help!("message")
```

`error!` is similar to `exit!`, but the `:error` option is true as default.

```crystal
error! # ends with 1 as exit code
error! "message" # same as exit!("message", error: true)
error! code: 22 # specifies exit code
error! help: true # same as help!(error: true)
error! "message", help: true # same as help!("message")
```

## API Basics

Crystal CLI provides 4 fundamental classes, `Command`, `Supercommand`, `Options` and `Help`.

Both `Command` and `Supercommand` inherit the `CommandBase` class that has several features commonly used.

Once you make a class inherit `Command` or `Supercommand`, then `Options` and `Help` is automatically defined into the class.

```crystal
class AncientCommand < Cli::Command
end
```

This code seems that it simply defines the `AncientCommand` class. But, actually, it also makes `AncientCommand::Options` and `AncientCommand::Help` defined internally.

### Parsing Options

The `Options` class is used for parsing command-line options. `Options` inherits the `Optarg::Model` class provided from the [optarg](https://github.com/mosop/optarg) library. So you can define options in it.

```crystal
class AncientCommand < Cli::Command
  class Options
    string "--message"
  end
end
```

### Running a Command

The virtual `CommandBase#run` method is the entry point for running your command.

Your command's class will be instantiated and its `#run` method will be invoked after calling the static `.run` method.

```crystal
class AncientCommand < Cli::Command
  def run
    puts "We the Earth"
  end
end

AncientCommand.run
```

This prints as:

```
We the Earth
```

A command's instance is also accessible with the `command` method in an option parser's scope.

```crystal
class AncientCommand < Cli::Command
  class Options
    on("--understand") { command.understand }
  end

  def understand
    puts "We know"
  end

  def run
    puts "We the Earth"
  end
end

AncientCommand.run %w(--understand)
```

This prints as:

```
We know
We the Earth
```

## Formatting Help

The `Help` class is used for formatting help texts.

```crystal
class AncientCommand < Cli::Command
  class Help
    title "ancient [OPTIONS]"
    footer "(C) 1977 mosop"
  end
end
```

[WIP]

## Releases

* v0.1.4
  * help!, exit! and error!
* v0.1.2
  * Array
* v0.1.1
  * Aliasing

## Development

[WIP]

## Contributing

1. Fork it ( https://github.com/mosop/cli/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mosop](https://github.com/mosop) - creator, maintainer
