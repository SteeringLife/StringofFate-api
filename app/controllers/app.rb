# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/userinfo'

module StringofFate
  # Web controller for StringofFate API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Userinfo.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'StringofFate API up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'userinfos' do
            # GET api/v1/userinfos/[id]
            routing.get String do |id|
              response.status = 200
              Userinfo.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Userinfo not found' }.to_json
            end

            # GET api/v1/userinfos
            routing.get do
              response.status = 200
              output = { userinfo_ids: Userinfo.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/userinfos
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Userinfo.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'Userinfo saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save userinfo' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
