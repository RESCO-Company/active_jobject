# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveJobject::Base do
  subject(:klass) { described_class }

  describe '#site' do
    let(:subclass) do
      Class.new(klass) do
        self.site = 'https://iamatest.test'
      end
    end

    it 'gets the defined site on class definition' do
      expect(subclass.site).to eq('https://iamatest.test')
    end
  end

  describe '#uri' do
    context 'site defined as String' do
      let(:subclass) do
        Class.new(klass) do
          self.site = 'https://iamatest.test'
        end
      end

      it 'gets and converts the site into URI' do
        expect(subclass.new.uri).to eq(URI('https://iamatest.test'))
      end
    end

    context 'site defined as URI' do
      let(:uri) { URI('https://iamatest.test') }

      let(:subclass) do
        subclass_uri = uri

        Class.new(klass) do
          self.site = subclass_uri
        end
      end

      it 'gets the site' do
        expect(subclass.new.uri).to be(uri)
      end
    end
  end
end
