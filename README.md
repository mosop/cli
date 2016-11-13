# Crystal CLI

Yet another Crystal library for building command-line interface applications.

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

### Option Parser

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

For more detail, see [Parsing Options](#parsing_options).

### Exit

```crystal
class Open < Cli::Command
  class Options
    arg "word"
  end

  def valid?
    args.word == "sesame"
  end

  def run
    if valid?
      exit! "Opened!"
    else
      error! "Not opened!"
    end
  end
end

Open.run %w(sesame) # => prints "Opened!" and returns 0 as an exit code
Open.run %w(paprika) # => prints "Not opened!" into STDERR and returns 1 as an exit code
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

For more detail, see [Defining Subcommands](#defining_subcommands).

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
class Call < Cli::Command
  class Help
    header "Receives an ancient message."
    footer "(C) 20XX mosop"
  end

  class Options
    arg "message", desc: "your message to call them", required: true
    bool "-w", not: "-W", desc: "wait for response", default: true
    help
  end
end

Call.run %w(--help)
# call [OPTIONS] MESSAGE
#
# Receives an ancient message.
#
# Arguments:
#   MESSAGE (required)  your message to call them
#
# Options:
#   -w          wait for response
#               (default: true)
#   -W          disable -w
#   -h, --help  show this help
#
# (C) 20XX mosop
```

For more detail, see [Generating Help](#generating_help).

### Versioning

```crystal
class Command < Cli::Supercommand
  version "1.0.0"

  class Options
    version
  end
end

Command.run %w(-v) # prints 1.0.0
```

For more detail, see [Versioning](#versioning).

## Usage

```crystal
require "cli"
```

and see [Features](#features).

## Fundamentals

Crystal CLI provides 4 fundamental classes: `Command`, `Supercommand`, `Options` and `Help`.

Both `Command` and `Supercommand` inherit the `CommandBase` class that has several features commonly used.

Once you make a class inherit `Command` or `Supercommand`, then `Options` and `Help` is automatically defined into the class.

```crystal
class YourCommand < Cli::Command
end
```

This code seems that it simply defines the `YourCommand` class. But, actually, it also makes `YourCommand::Options` and `YourCommand::Help` defined internally.


### Parsing Options

<a name="parsing_options"></a>

The `Options` class is used to define command-line options and arguments.

For example:

```crystal
class PlaySong < Cli::Command
  class Options
    arg "title", required: true
    bool "--repeat", not: "--Repeat", default: true
    array "--genre"
  end
end
```

`Options` inherits the `Optarg::Model` class provided from the *optarg* parser library. For more information about optarg, see the  [README](https://github.com/mosop/optarg).

Crystal CLI provides the proxy methods calling the corresponding optarg's API methods for accessing options and arguments. The following table shows how the methods are mapped.

| Crystal CLI | optarg |
| :-- | :-- |
| Cli::CommandBase#options | Optarg::Model#options
| Cli::CommandBase#args | Optarg::Model#args
| Cli::CommandBase#named_args | Optarg::Model#named_args
| Cli::CommandBase#nameless_args | Optarg::Model#nameless_args
| Cli::CommandBase#parsed_args | Optarg::Model#parsed_args
| Cli::CommandBase#unparsed_args | Optarg::Model#unparsed_args

So, you can access to options and arguments easily in a command's scope.

```crystal
class Command < Cli::Command
  class Options
    arg "arg"
    string "-s"
    terminator "--"
  end

  def run
    puts args.arg
    puts options.s
    puts unparsed_args[0]
  end
end

Command.run %w(foo -s bar -- baz)
```

This prints:

```
foo
bar
baz
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

This prints:

```
We the Earth
```

A command's instance is also accessible with the `command` method in option parser's scopes.

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

This prints:

```
We know
We the Earth
```

## Handling Exit

<a name="handling_exit"></a>

When a command normally ends, it returns 0.

```crystal
class Command < Cli::Command
  def run
  end
end

Command.run # => 0
```

When you want to abort your command, you may raise an exception:

```crystal
class Command < Cli::Command
  def run
    raise "ERROR!"
  end
end

Command.run # => raises error
```

Or, instead, you can have more control of exit with one of the 3 methods: `help!`, `exit!` and `error!`.

### help!

```crystal
class Command < Cli::Command
  def run
    help!
  end
end

Command.run # => 0
```

This command just ends after printing its help message. `Command.run` returns 0.

To print a message to STDERR and exit with an error code, use `:error` option.

```crystal
help! error: true
```

If the `:error` option is true, `run` method returns 1. To specify a number, use the `:code` option.

```crystal
help! code: 22
```

You can also let a command exit with an additional message:

```crystal
help! message: "You passed an illegal option! See help!"
```

Or simply:

```crystal
help! "You passed an illegal option! See help!"
```

Calling `help!` with the `:message` argument implies that the `:error` option is true. To exit normally, set false to `:error`.

### exit! and error!

`exit!` is more general purpose than `help!`.

```crystal
class Command < Cli::Command
  def run
    exit!
  end
end

Command.run # => 0
```

It just ends and returns 0 without a message.

To print a message:

```crystal
exit! "bye."
```

Or more variations:

```crystal
exit! help: true # equivalent to help!
exit! error: true # returns 1 as an exit code
exit! "message", error: true, help: true # equivalent to help!("message")
```

`error!` is similar to `exit!`, but the `:error` option is true as default.

```crystal
error! # ends with 1 as an exit code
error! "message" # equivalent to exit!("message", error: true)
error! code: 22 # specifies exit code
error! help: true # equivalent to help!(error: true)
error! "message", help: true # equivalent to help!("message")
```

### Displaying Help on Parsing Error

If a parsing error occurs, a help message automatically will be displayed.

```crystal
class Bookmark < Cli::Command
  class Options
    arg "url", required: true, desc: "a URL to be bookmarked"
  end
end

Command.run
```

This prints:

```
Parsing Error: The URL argument is required.

bookmark URL

Arguments:
  URL  a URL to be bookmarked
```

If you want to disable the feature, use the `CommandBase.disable_help_on_parsing_error!` method.

```crystal
class Bookmark < Cli::Command
  disable_help_on_parsing_error!

  class Options
    arg "url", required: true, desc: "a URL to be bookmarked"
  end
end
```

This only prints an error message:

```
Parsing Error: The URL argument is required.
```

## Defining Subcommands

<a name="defining_subcommands"></a>

A subcommand is a child command that is categorized under a specific namespace. For example, the `git` command has its several subcommands, `clone`, `commit`, `push`, etc.

To define subcommands, you do:

* define a *supercommand* class that inherits `Cli::Supercommand`,
* define subcommand names with the `comamnd` method in the supercommand class,
* define a module and name it "Commands" in the supercommand class and
* define command classes into the `Commands` module.

```crystal
class Git < Cli::Supercommand
  command "clone"
  command "commit"
  command "push"

  module Commands
    class Clone < Cli::Command
     # ...
    end

    class Commit < Cli::Command
      # ...
    end

    class Push < Cli::Command
      # ...
    end
  end
end
```

### Default Subcommand

You can mark one of subcommands as default. The default subcommand can be run without an explicit name in a command line.

```crystal
class Bundle < Cli::Supercommand
  command "install", default: true
  command "update"
  command "config"
  # ...
end

Bundle.run %w(install)  # explicitly runs install
Bundle.run %w()         # implicitly runs install
```

## Generating Help

<a name="generating_help"></a>

To format help messages, use the `Help` class.

For example:

```crystal
class Smile < Cli::Command
  class Help
    header "Smiles n times."
    footer "(C) 20XX mosop"
  end

  class Options
    arg "face", required: true, desc: "your face, for example, :), :(, :P"
    string "--times", var: "NUMBER", default: "1", desc: "number of times to display"
    help
  end

  def run
    puts args.face * options.times.to_i
  end
end

Smile.run ARGV
```

If you run this command with a help option, you see:

```
$ smile --help
smile [OPTIONS] FACE

Smiles n times.

Arguments:
  FACE  your face, for example, :), :(, :P

Options:
  --times NUMBER  number of times to display
                  (default: 1)
  -h, --help      show this help

(C) 20XX mosop
```

The help format has the following sections. Each section is aligned in the order.

* title
* header
* subcommands (for supercommands only)
* arguments
* options
* footer

### Titling

By default, the title section is automatically generated. To explicitly specify a title, use the `Help.title` method.

```crystal
class Ancient < Cli::Command
  class Help
    title "ancient - calls ancient people"
  end
end
```

Instead of specifying a whole title, you can only set a command's name. It is convenient when a command name is different from its class name.

```crystal
class Main < Cli::Command
  command_name "ancient"
end
```

Note: The `command_name` method belongs to the `CommandBase` class, not the `Help` class.

#### Unparsed Arguments

You may make a command that has arguments unparsed. For example, "exec" command internally executes another command and passes unparsed arguments to the other command. If you still need to display unparsed arguments in a title, use the `Help.unparsed_args` method.

```crystal
class Exec < Cli::Command
  class Options
    arg "command", required: true, stop: true, desc: "command name"
    help
  end

  class Help
    unparsed_args "[ARG1 ARG2 ...]"
  end
end

Command.run %w(-h)
```

This prints:

```
exec COMMAND [ARG1 ARG2 ...]

Arguments:
  COMMAND  command name

Options:
  -h, --help  show this help
```

### Header and Footer

The header and footer sections are not automatically defined. They appear only if you define them.

To define those sections, use the methods: `Help.header` and `Help.footer`.

```crystal
class Dependency < Cli::Command
  class Help
    header <<-EOS
      Renders a dependency diagram.

      Supported package managers:
        RubyGems
        Shards
        npm
      EOS
    footer <<-EOS
      (C) 20XX mosop
      Created by mosop (http://mosop.me)
      EOS
  end
end
```

### Subcommands

The *subcommands* section is appeared only if a command is a supercommand.

You can specify a *caption* that is displayed beside each subcommand. The caption is a very short description and typically a single phrase.

```crystal
class Cake < Cli::Supercommand
  command "strawberry"
  command "cheese"
  command "chocolat"

  class Options
    help
  end

  module Commands
    class Strawberry < Cli::Command
      class Help
        caption "made with Sachinoka strawberry"
      end
    end

    class Cheese < Cli::Command
      class Help
        caption "New York-style"
      end
    end

    class Chocolat < Cli::Command
      class Help
        caption "winter only"
      end
    end
  end
end

Cake.run %w(--help)
# cake SUBCOMMAND
#
# Subcommands:
#   cheese      New York-style
#   chocolat    winter only
#   strawberry  made with Toyonoka strawberry
#
# Options:
#   -h, --help  show this help
```

### Arguments and Options

The arguments and options sections are automatically generated from information defined.

You can specify an option's description by the `:desc` option.

```crystal
class Friend < Cli::Command
  class Options
    arg "name", required: true, desc: "your friend name"
    string "--years", desc: "how long you've been friends"
    help
  end
end

Friend.run %w(--help)
# friend [OPTIONS] NAME
#
# Arguments:
#   NAME (required)  your friend name
#
# Options:
#   --years  how long you've been friends  
```

### Options.help

The `Options.help` method adds the `-h` and `--help` options to your command. These options can be used to print a help message.

```
class Command < Cli::Command
  class Options
    help # equivalent to on(%w(-h --help)) { command.help! }
  end
end
```

You can change the option's name:

```
class Command < Cli::Command
  class Options
    help "--show-help"
  end
end
```

## Versioning

<a name="versioning"></a>

You can set a command's version with the `CommandBase.version` method.

```crystal
class Command < Cli::Command
  version "1.0.0"
end
```

To access the version string in a running context, use the `CommandBase#version` method.

```crystal
class Command < Cli::Command
  version "1.0.0"

  def run
    version # => "1.0.0"
  end
end
```

Like the `CommandBase#help!` method, the `CommandBase#version!` method exits with a version string.

```crystal
class Command < Cli::Command
  version "1.0.0"

  def run
    version! # prints "1.0.0" and exits
  end
end
```

### Version Inheritance

Without an explicit definition, a subcommand inherits its supercommand's version.

```crystal
class Command < Cli::Supercommand
  version "1.1.0"

  command "specific"
  command "inherit"

  module Commands
    class Specific < Cli::Command
      version "1.0.0"

      def run
        version # => "1.0.0"
      end
    end

    class Inherit < Cli::Command
      def run
        version # => "1.1.0"
      end
    end
  end
end
```

### Options.version

The `Options.version` method adds the `-v` and `--version` options to your command. These options can be used to print a version string.

```crystal
class Command < Cli::Command
  class Options
    version # equivalent to on(%w(-v --version)) { command.version! }
  end
end
```

You can change the option's name:

```crystal
class Command < Cli::Command
  class Options
    version "--show-version"
  end
end
```

## Want to Do

- Application-Level Logger
- Bash Completion Support
- I18n

## Releases

* v0.3.0
  * (Breaking Change) Updated optarg to 0.4.0 from 0.3.2. See [README](https://github.com/mosop/optarg).
* v0.2.5
  * Displaying Help on Parsing Error
  * Versioning
* v0.2.4
  * Unparsed Arguments for Help
* v0.2.0
  * (Breaking Change) The optarg's version is updated to 0.3.
* v0.1.11
  * Automatic Title Generation
* v0.1.9
  * CommandBase.run returns 0 when #run normally returns.
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
