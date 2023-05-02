# frozen_string_literal: true

require 'roda'
require_relative './app'

module StringofFate
  # Web controller for String of Fate API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on String do |username|
        routing.on 'links' do
          @link_route = "#{@api_root}/accounts/#{username}/links"
          # GET api/v1/accounts/[username]/links/[link_id]
          routing.get String do |link_id|
            doc = Document.where(username:, id: link_id).first
            doc ? doc.to_json : raise('Document not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/accounts/[username]/links
          routing.get do
            output = { data: Project.first(id: username).links }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt(404, { message: 'Could not find links' }.to_json)
          end

          # # POST api/v1/accounts/[username]/links
          # routing.post do
          #   new_data = JSON.parse(routing.body.read)

          #   new_doc = CreateDocumentForProject.call(
          #     username: , document_data: new_data
          #   )

          #   response.status = 201
          #   response['Location'] = "#{@link_route}/#{new_doc.id}"
          #   { message: 'Document saved', data: new_doc }.to_json
          # rescue Sequel::MassAssignmentRestriction
          #   Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          #   routing.halt 400, { message: 'Illegal Attributes' }.to_json
          # rescue StandardError => e
          #   Api.logger.warn "MASS-ASSIGNMENT: #{e.message}"
          #   routing.halt 500, { message: 'Error creating document' }.to_json
          # end
        end
      end
    end
  end
end
