require "./star"
require "colorize"
require "readline"
require "progress"

class Array(T)
  def delete_one(obj)
    delete_at index(obj).not_nil!
  end
end

class Ship
  property station : Station
  property stars : Array(Star)
  property cargo = [] of Cargo

  MAX_CARGO = 5

  COMMANDS = {
    %w[help] => ->(args : Array(String), ship : Ship) {
      raise "too many arguments" if args.size != 0

      if COMMANDS.size == 0
        puts "NO COMMANDS\n".colorize :red
        return
      end

      puts "COMMANDS:"

      str = COMMANDS.keys.map do |cmd|
        "- " + cmd.join " "
      end.join("\n")
      puts str
      puts
    },

    %w[cargo] => ->(args : Array(String), ship : Ship) {
      raise "too many arguments" if args.size != 0

      if ship.cargo.size == 0
        puts "NO CARGO\n".colorize :red
        return
      end

      puts "CARGO:"

      str = ship.cargo.map do |item|
        "- #{item.to_s.downcase}"
      end.join "\n"
      puts str
      puts
    },

    %w[radar] => ->(args : Array(String), ship : Ship) {
      raise "too many arguments" if args.size != 0

      if ship.star.stations.size == 0
        raise "ping failed"
      end

      puts "RADAR:"

      str = ""
      ship.star.stations.each_with_index do |item, index|
        if item == ship.station
          str += "[#{index + 1}]".colorize(:black).on(:white).to_s
          str += " #{item}\n"
        else
          str += "[#{index + 1}] #{item}\n"
        end
      end
      puts str
      puts
    },

    %w[goto [int]] => ->(args : Array(String), ship : Ship) {
      raise "too few arguments" if args.size == 0
      raise "too many arguments" if args.size != 1

      raise "argument must be a number" unless args[0].to_i32?

      destination = args[0].to_i32 - 1
      raise "no such station" if destination < 0

      dest_station = ship.station.star.stations[destination]?

      raise "no such station" if dest_station.nil?

      if dest_station == ship.station
        raise "already at this station"
      end

      puts "TRANSIT TO #{dest_station.name}"

      ship.progress 1.3

      ship.station = dest_station

      puts "ARRIVED: #{ship.station.name}"
      puts
    },

    %w[starmap] => ->(args : Array(String), ship : Ship) {
      raise "too many arguments" if args.size != 0

      if ship.star.stations.size == 0
        raise "query failed"
      end

      puts "STARMAP:"

      str = ""
      ship.stars.each_with_index do |item, index|
        if item == ship.station.star
          str += "[#{index + 1}]".colorize(:black).on(:white).to_s
          str += " #{item}\n"
        else
          str += "[#{index + 1}] #{item}\n"
        end
      end
      puts str
      puts
    },

    %w[warp [int]] => ->(args : Array(String), ship : Ship) {
      raise "too few arguments" if args.size == 0
      raise "too many arguments" if args.size != 1

      raise "argument must be a number" unless args[0].to_i32?

      destination = args[0].to_i32 - 1
      raise "no such star" if destination < 0

      dest_star = ship.stars[destination]?

      raise "no such star" if dest_star.nil?

      if dest_star == ship.station.star
        raise "already at this star"
      end

      puts "WARP TO #{dest_star.name}"

      ship.progress 3

      ship.station = dest_star.stations.sample

      puts "ARRIVED: #{ship.station.name}"
      puts
    },

    %w[trades] => ->(args : Array(String), ship : Ship) {
      raise "too many arguments" if args.size != 0

      if ship.station.trades.size == 0
        raise "request failed"
      end

      puts "TRADES:"

      str = ""
      ship.station.trades.each do |item|
        str += "#{item[0].to_s.downcase} => #{item[1].to_s.downcase}\n"
      end
      puts str
      puts
    },

    %w[trade [cargo_hold]] => ->(args : Array(String), ship : Ship) {
      raise "too few arguments" if args.size == 0
      raise "too many arguments" if args.size != 1

      raise "no such good" if Cargo.parse?(args[0]).nil?

      trade = ship.station.trade_for? Cargo.parse(args[0])
      raise "no such trade" if trade.nil?

      raise "no such cargo in hold" unless ship.cargo.includes? Cargo.parse(args[0])

      ship.cargo.delete_one Cargo.parse(args[0])

      puts "TRADING WITH #{ship.station.name}"

      ship.progress 0.5

      ship.cargo << trade

      puts "TRADED: #{args[0].downcase} => #{trade.to_s.downcase}"
      puts
    },
  }

  def initialize(@stars)
    @station = @stars[0].sample
    @cargo = [] of Cargo
    Random.new.rand(3..4).times do
      @cargo << Cargo::Currency
    end

    Readline.autocomplete do |str|
      cmds = [] of String
      COMMANDS.keys.select do |cmd|
        cmd.first.starts_with? str
      end.each do |cmd|
        cmds << cmd.first
      end
      cmds

      # parts = str.downcase.split
      #
      # puts str.inspect.colorize :yellow
      #
      # if parts.size == 0
      #   commands = [] of String
      #   COMMANDS.keys.each do |k|
      #     commands << k[0] unless k[0]?.nil?
      #   end
      #   next commands
      # end
      #
      # if parts.size == 1
      #   commands = [] of String
      #   COMMANDS.keys.select do |k|
      #     k[0].starts_with? parts[0]
      #   end.each do |k|
      #     commands << k[0] unless k[0]?.nil?
      #   end
      #   next commands
      # end
      #
      # commands = COMMANDS.keys.select do |k|
      #   k[0] == parts[0]
      # end
      # next nil if commands[0]?.nil?
      # command = commands[0]
      #
      # if command[parts.size - 1]?.nil?
      #   next nil
      # else
      #   arg = command[parts.size - 1]
      #   next [arg] unless arg.starts_with?("[") && arg.ends_with?("]")
      #
      #   case arg
      #   when "[int]"
      #     next nil
      #   when "[str]"
      #     next nil
      #   when "[cargo]"
      #     next Cargo.names.map do |n|
      #       n.downcase
      #     end
      #   when "[cargo_hold]"
      #     cargo = [] of String
      #     @cargo.each do |c|
      #       cargo << c.to_s.downcase
      #     end
      #     next cargo
      #   end
      # end
    end
  end

  def read_out
    puts <<-READOUT
    STAR    | #{star}
    STATION | #{station}
    CARGO   | [#{cargo_bar}]
    READOUT
  end

  def read_in
    input = Readline.readline("> ", true)
    if input.nil? || input.blank?
      puts
      return
    end
    input = input.downcase.split

    command_name = COMMANDS.keys.select do |c|
      c.first == input.first
    end.first
    command = COMMANDS[command_name]

    if command.nil?
      puts "ERR: Command not found".colorize :red
      return
    end

    begin
      command.call(input[1..-1], self)
    rescue e
      puts "ERR: #{e.message}".colorize :red
    end
  end

  def progress(est_time = 1, ticks = 5)
    bar = ProgressBar.new total: ticks,
      width: 10,
      complete: "=",
      incomplete: " "

    until bar.done?
      bar.inc
      sleep Random.new.rand(0.0..(est_time.to_f64 / ticks.to_f64))
    end
  end

  def star
    @station.star
  end

  def cargo_bar(full = '=', empty = ' ')
    str = ""

    (1..MAX_CARGO).each do |i|
      if cargo.size >= i
        str += full
      else
        str += empty
      end
    end

    str
  end
end
