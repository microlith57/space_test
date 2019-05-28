require "./cargo"
require "./yleta"
require "./star"

class Station
  property name : String
  property type : StationType
  property star : Star
  property trades : Hash(Cargo, Cargo)

  def initialize(@name, @type, @star, @trades)
  end

  def initialize(@star, random = Random.new)
    other_stations = [] of StationType
    @star.stations.each do |s|
      other_stations << s.type
    end

    @type = (StationType.values - other_stations).sample
    @name = random_gen

    @trades = {} of Cargo => Cargo
    regenerate_trades
  end

  def to_s(io)
    io << @name << " [" << @type << "]"
  end

  enum StationType
    City
    Town
    Port
    Foundry
    Hydroponics
    Mines
    Factories
    Electronics
  end

  TYPE_ATTRS = {
    StationType::City        => "sadadi",
    StationType::Town        => "sada",
    StationType::Port        => "risa",
    StationType::Foundry     => "do",
    StationType::Hydroponics => "sadali",
    StationType::Mines       => "ridaso",
    StationType::Factories   => "ridoso",
    StationType::Electronics => "sidili",
  }

  CARGOES = {
    StationType::City        => {i: [Cargo::Food, Cargo::Electronics, Cargo::Water, Cargo::Parts, Cargo::Currency], o: [Cargo::Currency]},
    StationType::Town        => {i: [Cargo::Food, Cargo::Electronics, Cargo::Water, Cargo::Parts, Cargo::Currency], o: [Cargo::Currency]},
    StationType::Port        => {i: [Cargo::Ore, Cargo::Metal, Cargo::Food, Cargo::Parts, Cargo::Currency], o: [Cargo::Ore, Cargo::Metal, Cargo::Food, Cargo::Currency]},
    StationType::Foundry     => {i: [Cargo::Ore, Cargo::Parts, Cargo::Currency], o: [Cargo::Metal, Cargo::Currency]},
    StationType::Hydroponics => {i: [Cargo::Water, Cargo::Parts, Cargo::Currency], o: [Cargo::Food, Cargo::Currency]},
    StationType::Mines       => {i: [Cargo::Parts, Cargo::Currency], o: [Cargo::Ore, Cargo::Currency]},
    StationType::Factories   => {i: [Cargo::Metal, Cargo::Currency], o: [Cargo::Parts, Cargo::Currency]},
    StationType::Electronics => {i: [Cargo::Metal, Cargo::Parts, Cargo::Currency], o: [Cargo::Electronics, Cargo::Currency]},
  }

  private def random_gen
    attrs = TYPE_ATTRS[@type]

    Yleta.adultspeak("ka" + attrs)
  end

  def regenerate_trades
    table = CARGOES[@type]
    inputs = table[:i].shuffle
    outputs = table[:o].shuffle

    num_trades = Random.rand(2..5).clamp(0..inputs.size)

    trades = {} of Cargo => Cargo

    num_trades.times do
      i = inputs.shift
      next if (outputs - [i]).size == 0
      o = (outputs - [i]).sample

      trades[i] = o
    end

    @trades = trades
  end

  def trade_for?(cargo)
    @trades[cargo]?
  end

  def trade_for(cargo)
    trade_for?(cargo).not_nil!
  end
end
