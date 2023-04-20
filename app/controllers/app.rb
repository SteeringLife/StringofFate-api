# frozen_string_literal: true

require 'roda'
require 'json'

module StringofFate
  # Web controller for StringofFate API
  class Api < Roda
    plugin :halt

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'StringofFate up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'userinfos' do
          @userinfo_route = "#{@api_root}/userinfos"
          # GET api/v1/userinfos/[id]
          routing.get do
            info = Userinfo.first(id: userinfo_id)
            info ? info.to_json : raise('Userinfo not found')
          rescue StandardError
            routing.halt 404, { message: 'Userinfo not found' }.to_json
          end

          # GET api/v1/userinfos
          routing.get do
            output = { data: Userinfo.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find userinfos' }.to_json
          end

          # POST api/v1/userinfos
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_userinfo = Userinfo.new(new_data)
            raise 'Could not save userinfo' unless new_userinfo.save

            response.status = 201
            response['Location'] = "#{@userinfo_route}/#{new_userinfo.id}"
            { message: 'Userinfo saved', data: new_userinfo }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.inspect}"
            routing.halt 500, { message: e.message }.to_json
          end
        end
        routing.on 'platforms' do
          @plat_root = "#{@api_root}/platforms"

          routing.on String do |platform_id|
            routing.on 'links' do
              @link_route = "#{@plat_root}/#{platform_id}/links"
              # GET api/v1/platforms/[platform_id]/links/[link_id]
              routing.get String do |link_id|
                link = Link.where(platform_id:, id: link_id).first
                link ? link.to_json : raise('Link not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/platforms/[platform_id]/links
              routing.get do
                output = { data: Platform.first(id: platform_id).links }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find link'
              end

              # POST api/v1/platforms/[platform_id]/links
              routing.post do
                new_data = JSON.parse(routing.body.read)
                plat = Platform.first(id: platform_id)
                new_link = plat.add_link(new_data)
                raise 'Could not save link' unless new_link

                response.status = 201
                response['Location'] = "#{@link_route}/#{new_link.id}"
                { message: 'Link saved', data: new_link }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end

            # GET api/v1/platforms/[platform_id]
            routing.get do
              plat = Platform.first(id: platform_id)
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
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
end
