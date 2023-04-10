# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module StringofFate
  STORE_DIR = 'app/db/store'

  # Holds a fill secret document
  class Document
    def initialize(new_document)
      # TODO: Create some attributes
      @username    = new_document['username']
      @id          = new_document['id'] || new_id
      @friends = new_document['friends']
      @public_hashtags = new_document['public_hashtags']
      @links = new_document['links']
    end

    # TODO: create attr_reader
    attr_reader :username, :id, :friends, :public_hashtags, :links

    def to_json(options = {})
      JSON(
        { # TODO: convert hash to json
          type: 'document', # tell json from which class
          username:,
          id:,
          friends:,
          public_hashtags:,
          links:
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(StringofFate::STORE_DIR) unless StringofFate::STORE_DIR
    end

    # Stores document in file store
    def save
      File.write("#{StringofFate::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one document
    def self.find(find_id)
      document_file = File.read("#{StringofFate::STORE_DIR}/#{find_id}.txt")
      Document.new JSON.parse(document_file)
    end

    # Query method to retrieve index of all documents
    def self.all
      Dir.glob("#{StringofFate::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(StringofFate::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
