class VehicleFactory
  attr_reader :vehicles

  def initialize
    @vehicles = []
  end

  def create_vehicles(data_service)
    @vehicles = data_service.map do |vehicle_info|
      Vehicle.new(vehicle_info)
    end
  end

  def set_to_electric(vehicles)
    vehicles.map do |vehicle|
      vehicle.change_to_ev
    end
    vehicles
  end
end