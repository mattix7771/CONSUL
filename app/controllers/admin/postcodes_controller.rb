require 'rexml/document'
require 'rexml/xpath'

class Admin::PostcodesController < Admin::BaseController
  respond_to :html

  load_and_authorize_resource

  def index
    @postcodes = Postcode.all.order(Arel.sql("UPPER(postcode)"))
  end

  def new
  end

  def ncsv
    @postcodes = Postcode.all
    respond_to do |format|
      format.html { render :ncsv }
      format.csv { render :ncsv, formats: [:csv] }
    end
  end

  def process_csv
    uploaded_file = params[:file]
    file_path = uploaded_file.path
    if File.extname(file_path) == ".csv"
      postcode_validation(file_path)
      redirect_to admin_postcodes_path
    else
      @error_msg = "Please select a CSV file."
      render :ncsv
    end
  end

  def postcode_validation(file_path)

    xml_file = File.new("lib/tasks/postcodes.xml")
    xml_doc = REXML::Document.new(xml_file)

    regex_patterns = {}
    REXML::XPath.each(xml_doc, "//postCodeRegex") do |element|
      territory_id = element.attributes["territoryId"]
      regex_patterns[territory_id] = Regexp.new(element.text)
    end

    CSV.foreach(file_path, headers: true) do |row| 
      next unless row["ward"].present? && row["postcode"].present?

      p row
      ward = "init"
	    ward = row["ward"].strip
      postcode = row["postcode"].delete(' ').upcase

      if regex_patterns.any? { |_, pattern| postcode =~ pattern }  && postcode.length <= 10
        geozone = Geozone.find_or_create_by!(name: ward)
        Postcode.create!(postcode:postcode, ward:ward, geozone_id:geozone.id) unless Postcode.exists?(postcode: postcode)
      end
    end
  end

  def edit
  end

  def create
    @postcode = Postcode.new(postcode_params)

    if @postcode.save
      redirect_to admin_postcodes_path
    else
      render :new
    end
  end

  def update
    if @postcode.update(postcode_params)
      redirect_to admin_postcodes_path
    else
      render :edit
    end
  end

  def destroy
    if @postcode.safe_to_destroy?
      @postcode.destroy!
      redirect_to admin_postcodes_path, notice: t("admin.postcodes.delete.success")
    else
      redirect_to admin_postcodes_path, flash: { error: t("admin.postcodes.delete.error") }
    end
  end

  private

    def postcode_params
      params.require(:postcode).permit(allowed_params)
    end

    def allowed_params
      [:postcode, :geozone, :ward]
    end
end
