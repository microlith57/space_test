require "./ship"

module CLI
  class_property stars : Array(Star)
  class_property ship : Ship

  @@stars = Star.autogen
  @@ship = Ship.new(@@stars)

  def self.start
    begin
      loop do
        puts @@ship.read_out
        @@ship.read_in
      end
    rescue e
      STDERR.puts e
      exit 1
    end
  end
end
