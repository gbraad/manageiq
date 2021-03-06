describe ManageIQ::Providers::Hawkular::MiddlewareManager::MiddlewareServer do
  let(:ems_hawkular) do
    # allow(MiqServer).to receive(:my_zone).and_return("default")
    _guid, _server, zone = EvmSpecHelper.create_guid_miq_server_zone
    auth = AuthToken.new(:name => "test", :auth_key => "valid-token", :userid => "jdoe", :password => "password")
    FactoryGirl.create(:ems_hawkular,
                       :hostname        => 'localhost',
                       :port            => 8080,
                       :authentications => [auth],
                       :zone            => zone)
  end

  let(:eap) do
    FactoryGirl.create(:hawkular_middleware_server,
                       :name                  => 'Local',
                       :feed                  => 'cda13e2a-e206-4e87-8bca-8cfdd5aea484',
                       :ems_ref               => '/t;28026b36-8fe4-4332-84c8-524e173a68bf'\
                                                 '/f;cda13e2a-e206-4e87-8bca-8cfdd5aea484/r;Local~~',
                       :nativeid              => 'Local~~',
                       :ext_management_system => ems_hawkular)
  end

  it "#collect_live_metrics for all metrics available" do
    start_time = Time.new(2016, 4, 5, 0, 0, 0, "+02:00")    # Fixed time for testing
    end_time = Time.new(2016, 4, 7, 0, 0, 0, "+02:00")      # Fixed time for testing
    interval = 3600                                         # Interval in seconds
    VCR.use_cassette(described_class.name.underscore.to_s,
                     :allow_unused_http_interactions => true,
                     :decode_compressed_response     => true) do # , :record => :new_episodes) do
      metrics_available = eap.metrics_available
      metrics_data = eap.collect_live_metrics(metrics_available, start_time, end_time, interval)
      keys = metrics_data.keys
      expect(metrics_data[keys[0]].keys.size).to be > 3
    end
  end

  it "#collect_live_metrics for three metrics" do
    start_time = Time.new(2016, 4, 5, 0, 0, 0, "+02:00")    # Fixed time for testing
    end_time = Time.new(2016, 4, 7, 0, 0, 0, "+02:00")      # Fixed time for testing
    interval = 3600                                         # Interval in seconds
    VCR.use_cassette(described_class.name.underscore.to_s,
                     :allow_unused_http_interactions => true,
                     :decode_compressed_response     => true) do # , :record => :new_episodes) do
      metrics_available = eap.metrics_available
      expect(metrics_available.size).to be > 3
      metrics_data = eap.collect_live_metrics(metrics_available[0, 3],
                                              start_time,
                                              end_time,
                                              interval)
      keys = metrics_data.keys
      # Assuming that for the test the first key has data for 3 metrics
      expect(metrics_data[keys[0]].keys.size).to eq(3)
    end
  end

  it "#first_and_last_capture" do
    VCR.use_cassette(described_class.name.underscore.to_s,
                     :allow_unused_http_interactions => true,
                     :decode_compressed_response     => true) do # , :record => :new_episodes) do
      capture = eap.first_and_last_capture
      expect(capture[0]).to be < capture[1]
    end
  end
end
