require 'sneakers'
require "json"
class LocationWorker

  include Sneakers::Worker

  from_queue(
    :sneakers,
    exchange: 'sneakers',
    durable: true,
    auto_delete: false,
    exchange_type: 'topic',
    routing_key: ['ps.location.#']
  )

  def work_with_params(message, headers, params)
    msg = JSON.parse(message)
    puts msg
    case headers.routing_key
    when 'ps.location.hello'
      puts "Message: #{msg}, routing_key: #{headers.routing_key}"
    when 'ps.location.geocode_lookup'
      record = msg["location_id"].present? ? Location.where(id: message.body["location_id"]).first : Nas.where(id: message.body["nas_id"]).first
      record.geocode_lookup if record
    when 'ps.location.facebook_checkin'
      location = Location.find_by unique_id: msg["location_id"]
      location.facebook_checkin(
        facebook_id: msg["facebook_id"],
        message: msg["message"]
      ) if location
    when 'ps.location.update_from_facebook'
      loc = Location.find(msg["location_id"])
      loc.update_from_facebook id: msg["facebook_id"]
    when 'ps.location.generate_defaults'
      location = Location.find_by(id: msg["location_id"])
      location.generate_defaults
    when 'ps.location.newsletter_test'
      location = Location.find(msg["location_id"])
      location.newsletter_test
    when 'ps.location.duplicate_settings'
      location = Location.find(msg["location_id"])
      location.duplicate_settings(
        user_id: msg["user_id"],
        location_name: msg["location_name"],
        address: msg["address"],
        users: msg["users"]
      )
    when 'ps.location.filepicker_create'
      Polkaspots.filepicker_create(
        location_id: msg["location_id"],
        url: msg["url"]
      )
    when "ps.location.sync_with_foursquare"
      location = Location.where(id: msg["location_id"]).first
      location.sync_with_foursquare
    when "ps.location.fb_create_page_cache"
      Polkaspots.fb_create_page_cache(msg["location_id"])
    when 'ps.location.update_from_foursquare'
      location = Location.find(msg["location_id"])
      location.update_from_foursquare
    when 'ps.location.update_from_google'
      location = Location.find(msg["location_id"])
      location.update_from_google
    when 'ps.location.publish_social_updates'
      location = Location.find(msg["location_id"])
      location.publish_social_updates
    when 'ps.location.schedule_autoresponders'
      location = Location.find msg["location_id"]
      location.schedule_autoresponder msg["uid"]
    when 'ps.location.sms_test'
      location = Location.find msg["location_id"]
      location.sms_test(msg["mobile"])
    when 'ps.location.post_email_to_list'
      location = Location.find(msg["location_id"])
      location.post_email_to_list(msg["email"],message.body[:mac])
    when 'ps.location.change_all_radcheck_passwords'
      location = Location.where(id: msg["location_id"]).select("id").first
      location.change_all_radcheck_passwords(msg["password"])
    when "ps.location.process_online"
      location = Location.find_by(unique_id: msg["unique_id"])
      location.process_login(msg)
    when 'ps.location.watch'
      location = Location.find(msg["location_id"])
      location.process_watch(msg["user_ids"])
    when 'ps.location.remove_watcher'
      location = Location.find(msg["location_id"])
      location.process_remove_watcher(msg["user_ids"])
    when "ps.location.check_attr_generated"
      Location.check_attr_generated
    when "ps.location.sense.enabled"
      location = Location.find_by slug: msg["slug"]
      location.flume_activate
    when "ps.location.sense.error"
      location = Location.find_by slug: msg["slug"]
      location.flume_errored
    when "ps.location.sense.deleted"
      location = Location.find_by slug: msg["slug"]
      location.flume_disable
    when "ps.location.sense.updated"
      location = Location.find_by slug: msg["slug"]
      location.flume_updated
    when "ps.location.sense.count"
      location = Location.find_by slug: msg["slug"]
      location.flume_counted(msg[:count])
    end
    ack!
  end

end
