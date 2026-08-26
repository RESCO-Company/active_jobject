require 'spec_helper'

RSpec.describe ActiveJobject::Request::Engine::OAuth2 do
  subject(:klass) { described_class }

  describe "#get" do
    context 'when the request succeeds' do
      context 'without default_headers' do
        let(:dummy_klass) do
          described_klass = klass

          Class.new(ActiveJobject::Base) do
            self.site = "http://testing-test-tester.test/api/v1/users"
            self.engine = described_klass
          end
        end

        let(:dummy_instance) { dummy_klass.new }

        let(:response_body) { JSON.generate({ id: 1, name: 'John Ruby', clients: [{ id: 1, name: 'Alpha' }, { id: 2, name: 'Beta' }, { id: 3, name: 'Sigma' }] }) }

        let(:response_double) do
          instance_double(OAuth2::Response, body: response_body, status: 200)
        end

        let(:access_token_double) do
          instance_double(OAuth2::AccessToken, get: response_double)
        end

        before do
          klass.authorization_strategy = ->(site:) { access_token_double }
        end

        it 'parses the result and returns the class' do
          expect(access_token_double).to receive(:get)
            .with("/api/v1/users", params: {}, headers: {})
            .and_return(response_double)

          result = dummy_instance.get

          expect(result).to eq(dummy_instance)

          expect(result.id).to eq(1)
          expect(result.id.class).to be(Integer)

          expect(result.name).to eq('John Ruby')
          expect(result.name.class).to be(String)

          expect(result.clients.class).to be(ActiveJobject::Collection)

          result.clients.each do |client|
            expect(client.class).to be(dummy_klass.const_get('clients'.split('_').map(&:capitalize).join.to_sym, false))
          end
        end
      end

      context 'with default headers' do
        let(:dummy_klass) do
          described_klass = klass

          Class.new(ActiveJobject::Base) do
            self.site = "http://testing-test-tester.test/api/v1/users"
            self.engine = described_klass

            self.default_headers = { 'Authorization' => 'Bearer TEST_TOKEN' }
          end
        end

        let(:dummy_instance) { dummy_klass.new }

        let(:response_body) { JSON.generate({ id: 1, name: 'John Ruby', clients: [{ id: 1, name: 'Alpha' }, { id: 2, name: 'Beta' }, { id: 3, name: 'Sigma' }] }) }

        let(:response_double) do
          instance_double(OAuth2::Response, body: response_body, status: 200)
        end

        let(:access_token_double) do
          instance_double(OAuth2::AccessToken, get: response_double)
        end

        before do
          klass.authorization_strategy = ->(site:) { access_token_double }
        end

        it 'parses the result and returns the class' do
          expect(access_token_double).to receive(:get)
            .with("/api/v1/users", params: {}, headers: { 'Authorization' => 'Bearer TEST_TOKEN' })
            .and_return(response_double)

          result = dummy_instance.get

          expect(result).to eq(dummy_instance)

          expect(result.id).to eq(1)
          expect(result.id.class).to be(Integer)

          expect(result.name).to eq('John Ruby')
          expect(result.name.class).to be(String)

          expect(result.clients.class).to be(ActiveJobject::Collection)

          result.clients.each do |client|
            expect(client.class).to be(dummy_klass.const_get('clients'.split('_').map(&:capitalize).join.to_sym, false))
          end
        end
      end
    end

    context 'when the request fails' do
      let(:dummy_klass) do
        described_klass = klass

        Class.new(ActiveJobject::Base) do
          self.site = "http://testing-test-tester.test/api/v1/users"
          self.engine = described_klass
        end
      end

      let(:dummy_instance) { dummy_klass.new }

      let(:access_token_double) do
        instance_double(OAuth2::AccessToken)
      end

      before do
        klass.authorization_strategy = ->(site:) { access_token_double }
        allow(access_token_double).to receive(:get).and_raise(oauth_error)
      end

      context 'status 401' do
        let(:response_double) do
          instance_double(OAuth2::Response, body: JSON.generate({}), status: 401)
        end

        let(:oauth_error) { OAuth2::Error.new(response_double) }

        it 'raises ActiveJobject::Request::Unauthorized' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::Unauthorized)
        end
      end

      context 'status 403' do
        let(:response_double) do
          instance_double(OAuth2::Response, body: JSON.generate({}), status: 403)
        end

        let(:oauth_error) { OAuth2::Error.new(response_double) }

        it 'raises ActiveJobject::Request::Forbidden' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::Forbidden)
        end
      end

      context 'status 404' do
        let(:response_double) do
          instance_double(OAuth2::Response, body: JSON.generate({}), status: 404)
        end

        let(:oauth_error) { OAuth2::Error.new(response_double) }

        it 'raises ActiveJobject::Request::NotFound' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::NotFound)
        end
      end

      context 'status 500' do
        let(:response_double) do
          instance_double(OAuth2::Response, body: JSON.generate({}), status: 500)
        end

        let(:oauth_error) { OAuth2::Error.new(response_double) }

        it 'raises ActiveJobject::Request::ServerError' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::ServerError)
        end
      end

      context 'status 42069 (non-standard)' do
        let(:response_double) do
          instance_double(OAuth2::Response, body: JSON.generate({}), status: 42069)
        end

        let(:oauth_error) { OAuth2::Error.new(response_double) }

        it 'raises ActiveJobject::Request::Error' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::Error)
        end
      end
    end
  end

  describe "#post" do
    context "when the request succeeds" do
      context 'without default headers' do
        let(:dummy_klass) do
          described_klass = klass

          Class.new(ActiveJobject::Base) do
            self.site = "http://utest.hello/api/v1/users"
            self.engine = described_klass
          end
        end

        let(:dummy_instance) { dummy_klass.new }

        let(:body) { { name: 'Alpha Wolf', location: 'Unknown', age: 0 } }

        let(:response_body) { JSON.generate({ id: 2, name: 'Alpha Wolf', location: 'Unknown', age: 0, created_at: '2026-08-19T14:19:04-05:00' }) }

        let(:response_double) do
          instance_double(OAuth2::Response, body: response_body, status: 200)
        end

        let(:access_token_double) do
          instance_double(OAuth2::AccessToken, post: response_double)
        end

        before do
          klass.authorization_strategy = ->(site:) { access_token_double }
        end

        it 'parses the result and returns the class' do
          expect(access_token_double).to receive(:post)
            .with("/api/v1/users", body:, params: {}, headers: {})
            .and_return(response_double)

          result = dummy_instance.post(body:)

          expect(result).to be(dummy_instance)

          expect(result.id).to eq(2)
          expect(result.id.class).to be(Integer)

          expect(result.name).to eq('Alpha Wolf')
          expect(result.name.class).to be(String)

          expect(result.location).to eq('Unknown')
          expect(result.location.class).to be(String)

          expect(result.age).to eq(0)
          expect(result.age.class).to be(Integer)

          expect(result.created_at).to eq('2026-08-19T14:19:04-05:00')
          expect(result.created_at.class).to be(String)
        end
      end

      context 'with default headers' do
        let(:dummy_klass) do
          described_klass = klass

          Class.new(ActiveJobject::Base) do
            self.site = "http://utest.hello/api/v1/users"
            self.engine = described_klass

            self.default_headers = { 'Authorization' => 'Bearer TEST_TOKEN' }
          end
        end

        let(:dummy_instance) { dummy_klass.new }

        let(:body) { { name: 'Alpha Wolf', location: 'Unknown', age: 0 } }

        let(:response_body) { JSON.generate({ id: 2, name: 'Alpha Wolf', location: 'Unknown', age: 0, created_at: '2026-08-19T14:19:04-05:00' }) }

        let(:response_double) do
          instance_double(OAuth2::Response, body: response_body, status: 200)
        end

        let(:access_token_double) do
          instance_double(OAuth2::AccessToken, post: response_double)
        end

        before do
          klass.authorization_strategy = ->(site:) { access_token_double }
        end

        it 'parses the result and returns the class' do
          expect(access_token_double).to receive(:post)
            .with("/api/v1/users", body:, params: {}, headers: { 'Authorization' => 'Bearer TEST_TOKEN' })
            .and_return(response_double)

          result = dummy_instance.post(body:)

          expect(result).to be(dummy_instance)

          expect(result.id).to eq(2)
          expect(result.id.class).to be(Integer)

          expect(result.name).to eq('Alpha Wolf')
          expect(result.name.class).to be(String)

          expect(result.location).to eq('Unknown')
          expect(result.location.class).to be(String)

          expect(result.age).to eq(0)
          expect(result.age.class).to be(Integer)

          expect(result.created_at).to eq('2026-08-19T14:19:04-05:00')
          expect(result.created_at.class).to be(String)
        end
      end
    end

    context 'when the request fails' do
      let(:dummy_klass) do
        described_klass = klass

        Class.new(ActiveJobject::Base) do
          self.site = "http://utest.hello/api/v1/users"
          self.engine = described_klass
        end
      end

      let(:dummy_instance) { dummy_klass.new }

      let(:access_token_double) do
        instance_double(OAuth2::AccessToken)
      end

      before do
        klass.authorization_strategy = ->(site:) { access_token_double }
        allow(access_token_double).to receive(:post).and_raise(oauth_error)
      end

      context 'status 401' do
        let(:response_double) do
          instance_double(OAuth2::Response, body: JSON.generate({}), status: 401)
        end

        let(:oauth_error) { OAuth2::Error.new(response_double) }

        it 'raises ActiveJobject::Request::Unauthorized' do
          expect { dummy_instance.post }.to raise_error(ActiveJobject::Request::Unauthorized)
        end
      end

      context 'status 403' do
        let(:response_double) do
          instance_double(OAuth2::Response, body: JSON.generate({}), status: 403)
        end

        let(:oauth_error) { OAuth2::Error.new(response_double) }

        it 'raises ActiveJobject::Request::Forbidden' do
          expect { dummy_instance.post }.to raise_error(ActiveJobject::Request::Forbidden)
        end
      end

      context 'status 404' do
        let(:response_double) do
          instance_double(OAuth2::Response, body: JSON.generate({}), status: 404)
        end

        let(:oauth_error) { OAuth2::Error.new(response_double) }

        it 'raises ActiveJobject::Request::NotFound' do
          expect { dummy_instance.post }.to raise_error(ActiveJobject::Request::NotFound)
        end
      end

      context 'status 500' do
        let(:response_double) do
          instance_double(OAuth2::Response, body: JSON.generate({}), status: 500)
        end

        let(:oauth_error) { OAuth2::Error.new(response_double) }

        it 'raises ActiveJobject::Request::ServerError' do
          expect { dummy_instance.post }.to raise_error(ActiveJobject::Request::ServerError)
        end
      end

      context 'status 42069 (non-standard)' do
        let(:response_double) do
          instance_double(OAuth2::Response, body: JSON.generate({}), status: 42069)
        end

        let(:oauth_error) { OAuth2::Error.new(response_double) }

        it 'raises ActiveJobject::Request::Error' do
          expect { dummy_instance.post }.to raise_error(ActiveJobject::Request::Error)
        end
      end
    end
  end

  describe "#deconstruct_uri" do
    context "HTTPS URL without port" do
      let(:uri) { URI('https://rescocompany.com/about-us') }

      it "decopules the scheme://host/ and /path" do
        expect(klass.send(:deconstruct_uri, uri)).to eq(['https://rescocompany.com/', '/about-us'])
      end
    end

    context "HTTPS URL with port" do
      let(:uri) { URI('https://rescocompany.com:3030/about-us') }

      it "decopules the scheme://host:port/ and /path" do
        expect(klass.send(:deconstruct_uri, uri)).to eq(['https://rescocompany.com:3030/', '/about-us'])
      end
    end

    context "HTTP URL without port" do
      let(:uri) { URI('http://192.168.4.20/hello/world/iam/alive') }

      it "decopules the scheme://host/ and /path" do
        expect(klass.send(:deconstruct_uri, uri)).to eq(['http://192.168.4.20/', '/hello/world/iam/alive'])
      end
    end

    context "HTTPS URL with port" do
      let(:uri) { URI('http://10.0.10.10:10210/about-us') }

      it "decopules the scheme://host:port/ and /path" do
        expect(klass.send(:deconstruct_uri, uri)).to eq(['http://10.0.10.10:10210/', '/about-us'])
      end
    end
  end
end