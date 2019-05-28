require "./station"
require "./yleta"

class Star
  getter stations = [] of Station
  property name : String

  def self.autogen
    stars = [] of Star

    Random.new.rand(5...7).times do
      stars << Star.new(stars)
    end

    stars
  end

  def initialize(@name, @stations = [] of Station)
  end

  def initialize(other_stars)
    @name = random_gen
    @stations = [] of Station

    Random.new.rand(2...4).times do
      @stations << Station.new self
    end
  end

  def <<(station)
    @stations << station
  end

  def to_s(io)
    io << @name << " [" << @stations.size << "]"
  end

  private def random_gen
    parts = [] of String

    parts << "ka"
    parts << ["di", "da", "do"].sample
    parts << ["vi", "va", "vo"].sample
    # TODO: More parts?

    Yleta.adultspeak parts.join
  end

  def sample
    @stations.sample
  end
end
