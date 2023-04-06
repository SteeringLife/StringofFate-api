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
    end

    # TODO: create attr_reader

    def to_json(options = {})
      JSON(
        {
          # TODO: convert hash to json
        },
        options
      )
    end

    def self.setup
      Dir.mkdir(StringofFate::STORE_DIR) unless StringofFate::STORE_DIR
    end

    def save
      File.write("#{StringofFate::STORE_DIR}/#{id}.txt", to_json)
    end

    def self.find(find_id)
      document_file = File.read("#{StringofFate::STORE_DIR}/#{find_id}.txt")
      Document.new JSON.parse(document_file)
    end

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
