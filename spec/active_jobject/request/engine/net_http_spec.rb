# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveJobject::Request::Engine::NetHttp do
  subject(:klass) { described_class }

  describe '#get' do
    context 'when the request succeeds' do
      context 'without default headers' do
        let(:dummy_klass) do
          described_klass = klass

          Class.new(ActiveJobject::Base) do
            self.site = 'http://testing-test-tester.test/api/v1/users'
            self.engine = described_klass
          end
        end

        let(:dummy_instance) { dummy_klass.new }

        before do
          stub_request(:get, 'http://testing-test-tester.test/api/v1/users')
            .to_return(status: 200, body: JSON.generate({ id: 1, name: 'John Ruby', clients: [{ id: 1, name: 'Alpha' }, { id: 2, name: 'Beta' }, { id: 3, name: 'Sigma' }] }))
        end

        it 'parses the result and returns the class' do
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
            self.site = 'http://testing-test-tester.test/api/v1/users'
            self.engine = described_klass

            self.default_headers = { 'Authorization' => 'Bearer TEST_TOKEN' }
          end
        end

        let(:dummy_instance) { dummy_klass.new }

        before do
          stub_request(:get, 'http://testing-test-tester.test/api/v1/users')
            .with(headers: { 'Authorization' => 'Bearer TEST_TOKEN' })
            .to_return(status: 200, body: JSON.generate({ id: 1, name: 'John Ruby', clients: [{ id: 1, name: 'Alpha' }, { id: 2, name: 'Beta' }, { id: 3, name: 'Sigma' }] }))
        end

        it 'parses the result and returns the class' do
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
          self.site = 'http://testing-test-tester.test/api/v1/users'
          self.engine = described_klass
        end
      end

      let(:dummy_instance) { dummy_klass.new }

      context 'status 401' do
        before do
          stub_request(:get, 'http://testing-test-tester.test/api/v1/users')
            .to_return(status: 401, body: nil)
        end

        it 'raises ActiveJobject::Request::Unauthorized' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::Unauthorized)
        end
      end

      context 'status 403' do
        before do
          stub_request(:get, 'http://testing-test-tester.test/api/v1/users')
            .to_return(status: 403, body: nil)
        end

        it 'raises ActiveJobject::Request::Forbidden' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::Forbidden)
        end
      end

      context 'status 404' do
        before do
          stub_request(:get, 'http://testing-test-tester.test/api/v1/users')
            .to_return(status: 404, body: nil)
        end

        it 'raises ActiveJobject::Request::NotFound' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::NotFound)
        end
      end

      context 'status 500' do
        before do
          stub_request(:get, 'http://testing-test-tester.test/api/v1/users')
            .to_return(status: 500, body: nil)
        end

        it 'raises ActiveJobject::Request::ServerError' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::ServerError)
        end
      end

      context 'status 42069 (non-standard)' do
        before do
          stub_request(:get, 'http://testing-test-tester.test/api/v1/users')
            .to_return(status: 42_069, body: nil)
        end

        it 'raises ActiveJobject::Request::Error' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::Error)
        end
      end
    end
  end

  describe '#post' do
    context 'when the request succeeds' do
      context 'without default headers' do
        let(:dummy_klass) do
          described_klass = klass

          Class.new(ActiveJobject::Base) do
            self.site = 'http://utest.hello/api/v1/users'
            self.engine = described_klass
          end
        end

        let(:dummy_instance) { dummy_klass.new }

        let(:body) { { name: 'Alpha Wolf', location: 'Unknown', age: 0 } }

        before do
          stub_request(:post, 'http://utest.hello/api/v1/users')
            .with(body: JSON.generate(body))
            .to_return(status: 200, body: JSON.generate({ id: 2, name: 'Alpha Wolf', location: 'Unknown', age: 0, created_at: '2026-08-19T14:19:04-05:00' }))
        end

        it 'parses the result and returns the class' do
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

      context 'without default headers' do
        let(:dummy_klass) do
          described_klass = klass

          Class.new(ActiveJobject::Base) do
            self.site = 'http://utest.hello/api/v1/users'
            self.engine = described_klass

            self.default_headers = { 'Authorization' => 'Bearer TEST_TOKEN' }
          end
        end

        let(:dummy_instance) { dummy_klass.new }

        let(:body) { { name: 'Alpha Wolf', location: 'Unknown', age: 0 } }

        before do
          stub_request(:post, 'http://utest.hello/api/v1/users')
            .with(headers: { 'Authorization' => 'Bearer TEST_TOKEN' }, body: JSON.generate(body))
            .to_return(status: 200, body: JSON.generate({ id: 2, name: 'Alpha Wolf', location: 'Unknown', age: 0, created_at: '2026-08-19T14:19:04-05:00' }))
        end

        it 'parses the result and returns the class' do
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
          self.site = 'http://utest.hello/api/v1/users'
          self.engine = described_klass
        end
      end

      let(:dummy_instance) { dummy_klass.new }

      let(:body) { { name: 'Alpha Wolf', location: 'Unknown', age: 0 } }

      context 'status 401' do
        before do
          stub_request(:get, 'http://utest.hello/api/v1/users')
            .to_return(status: 401, body: nil)
        end

        it 'raises ActiveJobject::Request::Unauthorized' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::Unauthorized)
        end
      end

      context 'status 403' do
        before do
          stub_request(:get, 'http://utest.hello/api/v1/users')
            .to_return(status: 403, body: nil)
        end

        it 'raises ActiveJobject::Request::Forbidden' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::Forbidden)
        end
      end

      context 'status 404' do
        before do
          stub_request(:get, 'http://utest.hello/api/v1/users')
            .to_return(status: 404, body: nil)
        end

        it 'raises ActiveJobject::Request::NotFound' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::NotFound)
        end
      end

      context 'status 500' do
        before do
          stub_request(:get, 'http://utest.hello/api/v1/users')
            .to_return(status: 500, body: nil)
        end

        it 'raises ActiveJobject::Request::ServerError' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::ServerError)
        end
      end

      context 'status 42069 (non-standard)' do
        before do
          stub_request(:get, 'http://utest.hello/api/v1/users')
            .to_return(status: 42_069, body: nil)
        end

        it 'raises ActiveJobject::Request::Error' do
          expect { dummy_instance.get }.to raise_error(ActiveJobject::Request::Error)
        end
      end
    end
  end
end
