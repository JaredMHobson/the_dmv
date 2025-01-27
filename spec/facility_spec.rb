require 'spec_helper'

RSpec.describe Facility do
    let (:facility_1) { Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600'}) }
    let (:facility_2) { Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'}) }
    let (:cruz) { Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice}) }
    let (:bolt) { Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev}) }
    let (:camaro) { Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice}) }
    let (:registrant_1) { Registrant.new('Bruce', 18, true ) }
    let (:registrant_2) { Registrant.new('Penny', 16) }
    let (:registrant_3) { Registrant.new('Tucker', 15) }

  describe '#initialize' do
    it 'can initialize' do
      expect(facility_1).to be_an_instance_of(Facility)
      expect(facility_1.name).to eq('DMV Tremont Branch')
      expect(facility_1.address).to eq('2855 Tremont Place Suite 118 Denver CO 80205')
      expect(facility_1.phone).to eq('(720) 865-4600')
      expect(facility_1.hours).to eq(nil)
      expect(facility_1.holidays_closed).to eq(nil)
      expect(facility_1.services).to eq([])
      expect(facility_1.registered_vehicles).to eq([])
      expect(facility_1.collected_fees).to eq(0)
    end
  end

  describe '#services' do
    it 'can add available services' do
      expect(facility_1.services).to eq([])
      facility_1.add_service('New Drivers License')
      facility_1.add_service('Renew Drivers License')
      facility_1.add_service('Vehicle Registration')
      expect(facility_1.services).to eq(['New Drivers License', 'Renew Drivers License', 'Vehicle Registration'])
    end
  end

  describe '#has_service?' do
    it 'can check if it has a service' do
      expect(facility_1.services).to be_empty

      facility_1.add_service('Written Test')
      facility_1.add_service('New Drivers License')

      expect(facility_1.services).to eq(['Written Test', 'New Drivers License'])

      expect(facility_1.has_service?('Written Test')).to be true
    end
  end

  describe '#administer_written_test' do
    it 'cannot administer written tests if it does not have the service' do
      expect(registrant_1.license_data[:written]).to be false
      expect(registrant_1.permit?).to be true
      expect(registrant_1.age).to eq(18)

      expect(facility_1.services).to be_empty

      expect(facility_1.administer_written_test(registrant_1)).to be false
      expect(registrant_1.license_data[:written]).to be false
    end

    it 'can administer written tests if it has the service, the registrant is above 16 and has permit' do
      facility_1.add_service('Written Test')

      expect(facility_1.administer_written_test(registrant_1)).to be true
      expect(registrant_1.license_data[:written]).to be true
    end

    it 'cannot administer written tests if it has the service but the registrant does not meet the requirements' do
      expect(registrant_2.license_data[:written]).to be false
      expect(registrant_2.permit?).to be false
      expect(registrant_2.age).to eq(16)

      facility_1.add_service('Written Test')

      expect(facility_1.administer_written_test(registrant_2)).to be false
      expect(registrant_2.license_data[:written]).to be false
    end
  end

  describe '#administer_road_test' do
    it 'cannot administer road test if registrant meets the requirements but it does not have the service' do
      expect(registrant_1.license_data[:license]).to be false

      facility_1.add_service('Written Test')
      facility_1.administer_written_test(registrant_1)

      expect(facility_1.services).to eq(['Written Test'])

      expect(facility_1.administer_road_test(registrant_1)).to be false
    end

    it 'can administer road test if it has the service and registrant has permit and written' do
      facility_1.add_service('Written Test')
      facility_1.add_service('Road Test')
      facility_1.administer_written_test(registrant_1)
      expect(facility_1.services).to eq(['Written Test', 'Road Test'])

      expect(facility_1.administer_road_test(registrant_1)).to be true
      expect(registrant_1.license_data[:license]).to be true
    end

    it 'cannot administer road test if it has the service but registrant does not meet the requirements' do
      facility_1.add_service('Written Test')
      facility_1.add_service('Road Test')
      expect(facility_1.services).to eq(['Written Test', 'Road Test'])

      facility_1.administer_road_test(registrant_1)

      expect(facility_1.administer_road_test(registrant_1)).to be false
      expect(registrant_1.license_data[:license]).to be false
    end
  end

  describe '#renew_drivers_license' do
    it 'cannot renew license if registrant meets the requirements but it does not have the service' do
      facility_1.add_service('Written Test')
      facility_1.add_service('Road Test')
      expect(facility_1.services).to eq(['Written Test', 'Road Test'])

      facility_1.administer_written_test(registrant_1)
      facility_1.administer_road_test(registrant_1)

      expect(facility_1.renew_drivers_license(registrant_1)).to be false
      expect(registrant_1.license_data[:renewed]).to be false
    end

    it 'can renew license if it has the service and registrant has their license' do
      facility_1.add_service('Written Test')
      facility_1.add_service('Road Test')
      facility_1.add_service('Renew License')
      expect(facility_1.services).to eq(['Written Test', 'Road Test', 'Renew License'])

      facility_1.administer_written_test(registrant_1)
      facility_1.administer_road_test(registrant_1)

      expect(facility_1.renew_drivers_license(registrant_1)).to be true
      expect(registrant_1.license_data[:renewed]).to be true
    end

    it 'cannot renew license if it has the service but registrant does not meet the requirements' do
      facility_1.add_service('Written Test')
      facility_1.add_service('Road Test')
      facility_1.add_service('Renew License')
      expect(facility_1.services).to eq(['Written Test', 'Road Test', 'Renew License'])

      facility_1.administer_written_test(registrant_1)

      expect(facility_1.renew_drivers_license(registrant_1)).to be false
      expect(registrant_1.license_data[:renewed]).to be false
    end
  end

  describe '#register_vehicle' do
    it 'cannot register a vehicle if it does not have the service' do
      expect(facility_1.services).to be_empty

      facility_1.register_vehicle(cruz)

      expect(cruz.registered?).to be false
    end

    it 'can register vehicles' do
      facility_1.add_service('Vehicle Registration')

      facility_1.register_vehicle(cruz)

      expect(cruz.registered?).to be true
    end

    it 'will add the registered vehicle to registered_vehicles' do
      facility_1.add_service('Vehicle Registration')


      facility_1.register_vehicle(cruz)

      expect(facility_1.registered_vehicles).to eq([cruz])
    end

    it 'will change the vehicles registration date to todays date' do
      facility_1.add_service('Vehicle Registration')

      expect(cruz.registration_date).to eq(nil)

      facility_1.register_vehicle(cruz)

      expect(cruz.registration_date).to eq(Date.today)
    end

    it 'can update plate type when registering the vehicle based on the vehicles year made' do
      facility_1.add_service('Vehicle Registration')

      expect(cruz.plate_type).to eq(nil)
      expect(bolt.plate_type).to eq(nil)
      expect(camaro.plate_type).to eq(nil)

      facility_1.register_vehicle(cruz)
      facility_1.register_vehicle(bolt)
      facility_1.register_vehicle(camaro)

      expect(cruz.plate_type).to eq(:regular)
      expect(bolt.plate_type).to eq(:ev)
      expect(camaro.plate_type).to eq(:antique)
    end

    it 'cannot register a vehicle that is already registered' do
      facility_1.add_service('Vehicle Registration')
      facility_2.add_service('Vehicle Registration')

      expect(facility_1.registered_vehicles).to be_empty
      expect(facility_2.registered_vehicles).to be_empty

      facility_1.register_vehicle(cruz)

      expect(facility_1.registered_vehicles).to eq([cruz])
      expect(facility_2.registered_vehicles).to be_empty

      # to show it can't be registered to facility 1 twice
      facility_1.register_vehicle(cruz)

      expect(facility_1.registered_vehicles).to eq([cruz])

      facility_2.register_vehicle(cruz)

      expect(facility_2.registered_vehicles).to be_empty

      facility_2.register_vehicle(bolt)

      expect(facility_2.registered_vehicles).to eq([bolt])
    end
  end

  describe '#add_collected_fees' do
    it 'can add to collected fees' do
      expect(facility_1.collected_fees).to eq(0)

      facility_1.add_collected_fees(cruz)

      expect(facility_1.collected_fees).to eq(100)

      facility_1.add_collected_fees(bolt)

      expect(facility_1.collected_fees).to eq(300)

      facility_1.add_collected_fees(camaro)

      expect(facility_1.collected_fees).to eq(325)
    end

    it 'collects the appropriate fees when registering vehicles' do
      facility_1.add_service('Vehicle Registration')

      expect(facility_1.collected_fees).to eq(0)

      facility_1.register_vehicle(cruz)

      expect(facility_1.collected_fees).to eq(100)

      facility_1.register_vehicle(bolt)

      expect(facility_1.collected_fees).to eq(300)

      facility_1.register_vehicle(camaro)

      expect(facility_1.collected_fees).to eq(325)
    end
  end
end