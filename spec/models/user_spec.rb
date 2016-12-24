# == Schema Information
#
# Table name: users
#
#  id                       :uuid             not null, primary key
#  roles                    :string
#  name                     :string
#  surname                  :string
#  avatar                   :string
#  login                    :string
#  email                    :string           default(""), not null
#  password_digest          :string           default(""), not null
#  restore_password_token   :string
#  restore_password_sent_at :datetime
#  is_active                :boolean
#  confirmed_at             :datetime
#  created_at               :datetime
#  updated_at               :datetime
#

describe User, :focus do

  context "factory" do
    it 'default factory is valid' do
      expect(build(:user)).to be_valid
    end

    context "trait :with_phone_numbers" do
      it "produces 2 phone_numbers by default" do
        user = create(:user, :with_phone_numbers)
        expect(user.phone_numbers.count).to eq 2
      end

      it "produces 3 phone_numbers when transient.phone_numbers_count set to 3" do
        user = create(:user, :with_phone_numbers, phone_numbers_count: 3)
        expect(user.phone_numbers.count).to eq 3
      end
    end

    # user cannot be driver
    # context "trait :driver" do
    #   let(:event)     { create(:event) }
    #   let(:location)  { create(:location, event: event) }

    #   it "raises ArgumentError when called withou specifying event" do
    #     expect { create(:user, :driver) }.to raise_exception(ArgumentError)
    #   end

    #   it "creates user with single role of driver for given event when event given" do
    #     expect { create(:user, :driver, event: event) }.to change { Role.count }.by(1)
    #     expect(create(:user, :driver, event: event).roles.count).to eq(1)
    #     expect(create(:user, :driver, event: event).roles.first.role).to eq :driver
    #   end

    #   it "creates user with single role of driver for given event when event given and location when location given" do
    #     expect { create(:user, :driver, event: event, location: location) }.to change { Role.count }.by(1)
    #     expect(create(:user, :driver, event: event, location: location).roles.count).to eq(1)
    #     expect(create(:user, :driver, event: event, location: location).roles.first.role).to eq :driver
    #     expect(create(:user, :driver, event: event, location: location).roles.first.location).to eq location
    #   end
    # end
  end

  let(:user) { build(:user) }

  describe "db columns" do
    it { should have_db_column(:id).of_type(:uuid) }
    it { should have_db_column(:current_event_id).of_type(:uuid) }
    it { should have_db_column(:current_location_id).of_type(:uuid) }
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:surname).of_type(:string) }
    it { should have_db_column(:defaults).of_type(:text) }
    it { should have_db_column(:email).of_type(:string) }
    it { should have_db_column(:acronym).of_type(:string) }
    it { should have_db_column(:password_digest).of_type(:string) }
    it { should have_db_column(:is_admin).of_type(:boolean) }
    it { should have_db_column(:api_secret).of_type(:string) }
    it { should have_db_column(:deleted_at).of_type(:datetime) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }

    it { should have_db_index(:current_event_id) }
    it { should have_db_index(:current_location_id) }
    it { should have_db_index(:acronym) }
    it { should have_db_index(:email) }
    it { should have_db_index(:deleted_at) }
  end

  describe "associations" do
    it { should belong_to(:current_event).class_name('Event') }
    it { should belong_to(:current_location).class_name('Location') }
    it { should have_many(:roles).dependent(:destroy) }
    it { should have_many(:current_roles).class_name('Role') }
    it { should have_many(:available_events).through(:roles).source(:event) }
    # it { should have_many(:driver_shifts).dependent(:restrict_with_error) }
    # it { should have_many(:shifts).through(:driver_shifts).dependent(:restrict_with_error) }
    it { should have_many(:phone_numbers).dependent(:destroy) }
    it { should have_many(:addresses).dependent(:destroy) }
    it { should have_many(:vehicle_sheets).dependent(:destroy) }
    it { should have_many(:user_sheets).dependent(:destroy) }
    it { should have_many(:client_sheets).dependent(:destroy) }
    it { should have_many(:arrivals_sheets).dependent(:destroy) }
    it { should have_many(:departures_sheets).dependent(:destroy) }
    it { should have_many(:online_requests).with_foreign_key(:created_by_id).dependent(:nullify) }
    it { should have_many(:resource_vehicle_allocations).dependent(:restrict_with_error) }
    it { should have_many(:vehicle_allocations).through(:resource_vehicle_allocations).dependent(:restrict_with_error) }

    it { expect(user).to accept_nested_attributes_for(:phone_numbers).allow_destroy(true) }
    it { expect(user).to accept_nested_attributes_for(:addresses).allow_destroy(true) }
    it { expect(user).to accept_nested_attributes_for(:roles).allow_destroy(true) }
  end

  describe 'validations' do
    it { expect(user).to validate_presence_of(:name) }
    it { expect(user).to validate_length_of(:name).is_at_most(255) }

    it { expect(user).to validate_presence_of(:surname) }
    it { expect(user).to validate_length_of(:surname).is_at_most(255) }

    it { expect(user).to validate_presence_of(:email) }
    it { expect(user).to validate_length_of(:email).is_at_most(255) }
    it { expect(user).to validate_uniqueness_of(:email).scoped_to(:deleted_at).case_insensitive }

    it { expect(user).to validate_uniqueness_of(:acronym).scoped_to(:deleted_at).case_insensitive }
  end

  describe "normalizations" do

    context "name" do
      it { should normalize(:name).from("  marek  ").to("Marek") }
      it { should normalize(:name).from("  marek    augustyn  ").to("Marek Augustyn") }
      it { should normalize(:name).from("    ").to(nil) }
      it { should normalize(:name).from(nil).to(nil) }
    end

    context "surname" do
      it { should normalize(:surname).from("  pietrucha  ").to("Pietrucha") }
      it { should normalize(:surname).from("  pietrucha   warzywo    ").to("Pietrucha Warzywo") }
      it { should normalize(:surname).from("    ").to(nil) }
      it { should normalize(:surname).from(nil).to(nil) }
    end

    context "acronym" do
      it { should normalize(:acronym).from("  mpi  ").to("MPI") }
      it { should normalize(:acronym).from("  mpi 1  ").to("MPI1") }
      it { should normalize(:acronym).from(123).to("123") }
      it { should normalize(:acronym).from("    ").to(nil) }
      it { should normalize(:acronym).from(nil).to(nil) }
    end

    context "email" do
      it { should normalize(:email).from("  MAREK@pietrucha.com  ").to("marek@pietrucha.com") }
      it { should normalize(:email).from("    ").to(nil) }
      it { should normalize(:email).from(nil).to(nil) }
    end
  end

  context "callbacks" do

    let(:user) { create(:user) }

    it { expect(user).to callback(:_set_defaults).after(:initialize) }
    it { expect(user).to callback(:_expire_cache).after(:save) }
    it { expect(user).to callback(:_expire_cache).after(:destroy) }
    it { expect(user).to callback(:_custom_notification_behaviour).after(:commit).on(:update) }
  end

  describe "scopes" do

    context ".non_drivers" do
      let!(:event) { create(:event) }

      it "return users without users which current roles contain only driver role" do
        Thread.current[:current_event_id] = event.id

        driver1 = create(:user)
        driver1.roles.create(event: event, role: :driver)
        driver2 = create(:user)
        driver2.roles.create(event: event, role: :driver)

        manager_and_driver = create(:user)
        manager_and_driver.roles.create(event: event, role: :manager)
        manager_and_driver.roles.create(event: event, role: :driver)

        dispatcher = create(:user)
        dispatcher.roles.create(event: event, role: :dispatcher)

        expect(User.non_drivers).to contain_exactly(manager_and_driver, dispatcher)
      end

    end

    context ".drivers_only" do
      let!(:event) { create(:event) }

      it "return users where any of current roles is a driver" do
        Thread.current[:current_event_id] = event.id

        driver1 = create(:user)
        driver1.roles.create(event: event, role: :driver)
        driver2 = create(:user)
        driver2.roles.create(event: event, role: :driver)

        manager_and_driver = create(:user)
        manager_and_driver.roles.create(event: event, role: :manager)
        manager_and_driver.roles.create(event: event, role: :driver)

        dispatcher = create(:user)
        dispatcher.roles.create(event: event, role: :dispatcher)

        expect(User.drivers_only.all).to contain_exactly(manager_and_driver, driver1, driver2)
      end

    end
  end

  describe "methods" do

    context "#current_roles" do
      let(:user)    { create(:user) }
      let(:event1)  { create(:event) }
      let(:event2)  { create(:event) }
      let!(:manager_of_event1)    { create(:role, user: user, event: event1, role: :manager) }
      let!(:dispatcher_of_event1) { create(:role, user: user, event: event1, role: :dispatcher) }
      let!(:manager_of_event2)    { create(:role, user: user, event: event2, role: :manager) }
      let!(:dispatcher_of_event2) { create(:role, user: user, event: event2, role: :dispatcher) }
      let!(:driver_of_event2)     { create(:role, user: user, event: event2, role: :driver) }

      it "returns only roles of event1 when current event is event1" do
        Thread.current[:current_event_id] = event1.id
        expect(user.current_roles(true)).to contain_exactly(manager_of_event1, dispatcher_of_event1)
        expect(user.current_roles.size).to eq(2)
        expect(user.roles.count).to eq(5)
      end

      it "returns only roles of event2 when current event is event2" do
        Thread.current[:current_event_id] = event2.id
        expect(user.current_roles(true)).to contain_exactly(manager_of_event2, dispatcher_of_event2, driver_of_event2)
        expect(user.current_roles.size).to eq(3)
        expect(user.roles.count).to eq(5)
      end
    end

    context "#available_events" do
      let(:user)            { create(:user) }
      let(:active_event)    { create(:event) }
      let(:inactive_event)  { create(:event, is_active: false) }
      let!(:manager_of_active_event)    { create(:role, user: user, event: active_event, role: :manager) }
      let!(:manager_of_inactive_event)  { create(:role, user: user, event: inactive_event, role: :manager) }

      it "returns only active events" do
        expect(user.available_events).to contain_exactly(active_event)
      end
    end

    context "#channels" do
      it "returns generic users channel and specific user channel" do
        user = create(:user)
        expect(user.channels).to contain_exactly("users", "users:#{user.id}")
      end
    end

    context "#password=" do
      it "#password=('string') sets password and calculated digest" do
        password = "SomeKindOfPassword"
        person = User.new
        person.password = password

        expect(person.password).to eq(password)
        expect(BCrypt::Password.new(person.password_digest)).to eq(password)
      end

      it "#password=(nil) sets password and digest to nil" do
        password = nil
        person = User.new
        person.password = password

        expect(person.password).to be nil
        expect(person.password_digest).to be(nil)
      end

      it "#password=('') sets password and digest to nil" do
        password = ""
        person = User.new
        person.password = password

        expect(person.password).to be nil
        expect(person.password_digest).to be(nil)
      end
    end

    context "#phone_number" do
      let!(:user) { create(:user, :with_phone_numbers) }

      it "returns number of first phone number from association phone_numbers" do
        first_phone_number = PhoneNumber.first
        expect(user.phone_number).to eq first_phone_number.number
      end
    end
  end

  describe "private methods" do

    context "#_custom_notification_behaviour" do
      let(:user) { create(:user) }

      it "reloads roles association" do
        event           = create(:event)
        Thread.current[:current_event_id] = event.id

        manager_role    = user.roles.create(event: event, role: :manager)

        expect(user.current_roles(true)).to contain_exactly(manager_role)
        dispatcher_role = Role.create(user: user, role: :dispatcher, event: event)
        expect(user.current_roles).to contain_exactly(manager_role)

        user.send(:_reload_current_roles)
        expect(user.current_roles).to contain_exactly(manager_role, dispatcher_role)
      end

      it "sets notify_on_touch on false" do
        expect(user.notify_on_touch).to be_falsy
        user.send(:_custom_notification_behaviour)
        expect(user.notify_on_touch).to be false
      end

      it "sends update message if record exits" do
        allow(user).to receive(:message).with('update')
        user.send(:_custom_notification_behaviour)
      end

      it "sends delete message if record was destroyed" do
        user.destroy
        allow(user).to receive(:message).with('delete')
        user.send(:_custom_notification_behaviour)
      end
    end

    context "#_set_defaults" do
      let(:user) { User.new }

      it "sets defaults to empty hash" do
        expect(user.defaults).to eq({})
      end

      it "sets api_secret to secret of specific length" do
        expect(user.api_secret.length).to eq ENV['API_SECRET_LENGTH'].to_i
      end

      it "does not override defaults" do
        user = User.new(defaults: {a: :b})
        expect(user.defaults).to eq({a: :b})
      end

      it "does not override api_secret" do
        user = User.new(api_secret: "Halo")
        expect(user.api_secret).to eq("Halo")
      end
    end

    context "#_expire_cache" do
      let!(:user) { create(:user) }

      it "removes user object from redis" do
        $redis.set "user_object/#{user.id}", user.serialize_to_json
        expect($redis.get("user_object/#{user.id}")).to be_present

        user.send(:_expire_cache)
        expect($redis.get("user_object/#{user.id}")).to be nil
      end

      it "removes from redis after destroy" do
        $redis.set "user_object/#{user.id}", user.serialize_to_json
        expect($redis.get("user_object/#{user.id}")).to be_present

        user.destroy
        expect($redis.get("user_object/#{user.id}")).to be nil
      end
    end
  end
end
