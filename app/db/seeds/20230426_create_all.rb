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
  platform_cycle = StringofFate::Platform.all.cycle
  loop do
    link_info = link_info_each.next
    platform = platform_cycle.next
    StringofFate::CreateLinkForPlatform.call(
      platform_id: platform.id, link_data: link_info
    )
  end
end
