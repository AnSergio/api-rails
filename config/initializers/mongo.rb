require "mongo"
require "dotenv/load"

Mongo::Logger.logger.level = ::Logger::INFO

client = Mongo::Client.new(ENV["MONGODB_URI"])

MongoClient = client
