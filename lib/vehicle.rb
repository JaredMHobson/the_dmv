require 'date'

class Vehicle
  attr_reader :vin,
              :year,
              :make,
              :model,
              :engine,
              :county,
              :registration_date,
              :plate_type

  def initialize(vehicle_details)
    @vin = vehicle_details[:vin]
    @year = vehicle_details[:year]
    @make = vehicle_details[:make]
    @model = vehicle_details[:model]
    @engine = vehicle_details[:engine]
    @county = vehicle_details[:county]
    @registration_date = vehicle_details[:date]
    @plate_type = vehicle_details[:plate_type]
  end

  def antique?
    Date.today.year - @year > 25
  end

  def electric_vehicle?
    @engine == :ev
  end

  def update_registration_date
    @registration_date = Date.today
  end

  def update_plate_type
    @plate_type =
    case
    when antique?
      :antique
    when electric_vehicle?
      :ev
    else
      :regular
    end
  end

  def registered?
    registration_date != nil
  end
end