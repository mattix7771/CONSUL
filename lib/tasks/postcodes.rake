require 'rexml/document'
require 'rexml/xpath'

namespace :postcodes do
  desc "imort postcodes and wards to create geozones"

  logger = Logger.new('logfile.log')
  logger.info "Something happened"

  task import_csv: :environment do
    # Load the XML file containing the postal code regex patterns for each territory
    xml_file = File.new("lib/tasks/postcodes.xml")
    xml_doc = REXML::Document.new(xml_file)

    # Build a hash of territory codes and regex patterns
    regex_patterns = {}
    REXML::XPath.each(xml_doc, "//postCodeRegex") do |element|
      territory_id = element.attributes["territoryId"]
      regex_patterns[territory_id] = Regexp.new(element.text)
    end

    CSV.foreach(Rails.root.join("db", "wards.csv"), headers: true) do |row| 
      next unless row["ward"].present? && row["postcode"].present? #rejects empty entries

      p row
      ward = "init"
	    ward = row["ward"].strip
      postcode = row["postcode"].delete(' ').upcase #deletes empty spaces and upper case

      logger.info "Row being imported is #{row}"
      logger.info "ward should be #{ward}"
      logger.info "postcode should be #{postcode}"

      if regex_patterns.any? { |_, pattern| postcode =~ pattern }
        geozone = Geozone.find_or_create_by!(name: ward)
        logger.info "ward is present #{postcode} postcode exists as #{postcode}"
        Postcode.create!(postcode:postcode, ward:ward, geozone_id:geozone.id) unless Postcode.exists?(postcode: postcode) #rejects duplicate postcodes
      end
    end
  end
end
