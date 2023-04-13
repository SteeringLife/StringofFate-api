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

    route do |routing|
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
                { message: 'Userinfo saved', data: new_doc }.to_json
              else
                routing.halt 400, { message: 'Could not save userinfo' }.to_json
              end
            end
          end
          routing.on 'platforms' do
            @plat_root = "#{@api_root}/platforms"

            routing.on String do |platform_id|
              routing.on 'links' do
                @link_route = "#{@link_route}/#{platform_id}/links"
                # GET api/v1/platforms/[platform_id]/links/[link_id]
                routing.get String do |link_id|
                  link = Link.where(id: link_id, platform_id:).first
                  link ? link.to_json : raise('Link not found')
                rescue StandardError => e
                  routing.halt 404, { message: e.message }.to_json
                end

                # GET api/v1/platforms/[platform_id]/links
                routing.get do
                  output = { data: Platform.find(id: platform_id).links }
                  JSON.pretty_generate(output)
                rescue StandardError
                  routing.halt 404, message: 'Could not find link'
                end

                # POST api/v1/platforms/[platform_id]/links
                routing.post do
                  new_data = JSON.parse(routing.body.read)
                  plat = Platform.find(id: platform_id)
                  new_link = plat.add_link(new_data)

                  if new_link
                    response.status = 201
                    response['Location'] = "#{@link_route}/#{new_link.id}"
                    { message: 'Link saved', data: new_link }.to_json
                  else
                    routing.halt 400, { message: 'Could not save link' }
                  end

                rescue StandardError
                  routing.halt 500, { message: 'Database error' }.to_json
                end
              end

              # GET api/v1/platforms/[platform_id]
              routing.get do
                plat = Platform.find(id: platform_id)
                plat ? plat.to_json : raise('Platform not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end
            end

            # GET api/v1/platforms
            routing.get do
              output = { data: Platform.all }
              JSON.pretty_generate(output)
            rescue StandardError
              routing.halt 404, { message: 'Could not find platform' }.to_json
            end

            # POST api/v1/platforms
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_plat = Platform.new(new_data)
              raise 'Could not save platform' unless new_plat.save

              response.status = 201
              response['Location'] = "#{@plat_root}/#{new_plat.id}"
              { message: 'Platform saved', data: new_plat }.to_json
            rescue StandardError => e
              routing.halt 400, { message: e.message }.to_json
            end
          end
        end
      end
    end
  end
end
