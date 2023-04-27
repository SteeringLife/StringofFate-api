# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding platforms, links'
    create_links
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
LINK_INFO = YAML.load_file("#{DIR}/link_seeds.yml")

def create_links
  link_info_each = LINK_INFO.each
  account_cycle = StringofFate::Account.all.cycle
  loop do
    link_info = link_info_each.next
    account = account_cycle.next
    StringofFate::CreateLinkForOwner.call(
      account_id: account.id, link_data: link_info
    )
  end
end
