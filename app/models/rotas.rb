class Route
  attr_reader :path, :children

  def initialize(attrs = {})
    @path     = attrs["path"]
    @children = (attrs["children"] || []).map { |child| Route.new(child) }
  end

  def as_json(*)
    {
      path: path,
      children: children.map(&:as_json)
    }
  end
end
