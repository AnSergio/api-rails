# app/controllers/concerns/mongo_body.rb
module MongoBody
  extend ActiveSupport::Concern
  MAX_BODY_SIZE = 5.megabyte

  included do
    # Nada necessário aqui no momento
  end

  def body
    JSON.parse(request.body.read)
  end

  def on_object_id(filter)
    return true unless filter["_id"].present?

    if BSON::ObjectId.legal?(filter["_id"])
      filter["_id"] = BSON::ObjectId.from_string(filter["_id"])
      true
    else
      render json: [ { error: "ID inválido!" } ], status: 400
      false
    end
  end

  def on_object_ids(filters)
    return true unless filters.is_a?(Array)

    filters.each do |filter|
      next unless filter.is_a?(Hash)

      if filter["_id"].present?
        unless BSON::ObjectId.legal?(filter["_id"])
          render json: [ { error: "ID inválido!" } ], status: 400
          return false
        end
        filter["_id"] = BSON::ObjectId.from_string(filter["_id"])
      end

      if filter.dig("$match", "_id").present?
        unless BSON::ObjectId.legal?(filter["$match"]["_id"])
          render json: [ { error: "ID inválido!" } ], status: 400
          return false
        end
        filter["$match"]["_id"] = BSON::ObjectId.from_string(filter["$match"]["_id"])
      end
    end

    true
  end
end
