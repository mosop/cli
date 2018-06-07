# Crystal CLI

Yet another Crystal library for building command-line interface applications.

[![CircleCI](https://circleci.com/gh/mosop/cli.svg?style=shield)](https://circleci.com/gh/mosop/cli)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  cli:
    github: mosop/cli
```

<a name="code_samples"></a>

## Code Samples

### Option Parser

```crystal
class Hello < Cli::Command
  class Options
    bool "--bye"
    arg "to"
  end

  def run
    if args.bye?
      print "Goodbye"
    else
      print "Hello"
    end
    puts " #{args.to}!"
  end
end

Hello.run %w(world) # prints "Hello, world!"
Hello.run %w(--bye world) # prints "Goodbye, world!"
```

### Subcommand

```crystal
class Polygon < Cli::Supercommand
  command "triangle", default: true

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

Polygon.run %w(triangle) # prints "3"
Polygon.run %w(square)   # prints "4"
Polygon.run %w(hexagon)  # prints "6"
Polygon.run %w()         # prints "3"
```

### Replacing

```crystal
class New < Cli::Command
  def run
    puts "new!"
  end
end

class Obsolete < Cli::Command
  replacer_command New
end

Obsolete.run # prints "new!"
```

### Inheritance

```crystal
abstract class Role < Cli::Command
  class Options
    string "--name"
  end
end

class Chase < Cli::Supercommand
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
```

Output:

```
call [OPTIONS] MESSAGE

Receives an ancient message.

Arguments:
  MESSAGE (required)  your message to call them

Options:
  -w          wait for response
              (default: true)
  -W          disable -w
  -h, --help  show this help

(C) 20XX mosop
```

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

### Shell Completion

```crystal
class TicketToRide < Cli::Command
  class Options
    string "--by", any_of: %w(train plane taxi)
    arg "for", any_of: %w(kyoto kanazawa kamakura)
  end
end

puts TicketToRide.generate_bash_completion
# or
puts TicketToRide.generate_zsh_completion
```

## Usage

```crystal
require "cli"
```

and see:

* [Code Samples](#code_samples)
* [Wiki](https://github.com/mosop/cli/wiki)
* [API Document](http://mosop.me/cli/Cli.html)

## Want to Do

- Application-Level Logger
- I18n

## Release Notes

See [Releases](https://github.com/mosop/cli/releases).
