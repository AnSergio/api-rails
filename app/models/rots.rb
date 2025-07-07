class Route
  attr_reader :path, :children

  def initialize(attrs = {})
    @path     = attrs["path"]
    @children = (attrs["children"] || []).map { |child| Route.new(child) }
  end

  def as_json(*)
    json = { path: path }
    json[:children] = children.map(&:as_json) unless children.empty?
    json
  end
end

class Rots
  attr_reader :rotas

  def initialize(attrs = {})
    @rotas = attrs[:rotas]
  end

  def self.from(result)
    new(
      rotas: result["rotas"]
    )
  end

  def as_json(*)
  {
    rotas: rotas
  }
  end
end
