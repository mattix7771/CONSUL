namespace :postcodes do
  desc "imort postcodes and wards to create geozones"

  logger = Logger.new('logfile.log')
  logger.info "Something happened"

  task import_csv: :environment do
    CSV.foreach(Rails.root.join("db", "wards.csv"), headers: true) do |row| 
      next unless row["ward"].present? && row["postcode"].present? #rejects empty entries

      p row
      ward = "init"
	    ward = row["ward"].strip
      postcode = row["postcode"].delete(' ').upcase #deletes empty spaces and upper case

      logger.info "Row being imported is #{row}"
      logger.info "ward should be #{ward}"
      logger.info "postcode should be #{postcode}"

      if postcode.length <= 7 && postcode.length >= 6 #rejects postcodes thats are not 6 or 7 digits
        geozone = Geozone.find_or_create_by!(name: ward)
        logger.info "ward is present #{postcode} postcode exists as #{postcode}"
        Postcode.create!(postcode:postcode, ward:ward, geozone_id:geozone.id) unless Postcode.exists?(postcode: postcode) #rejects duplicate postcodes
      end
    end
  end
end