# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveJobject::Request do
  subject(:klass) { described_class }

  describe '#default_headers' do
    let(:dummy_klass) do
      Class.new(ActiveJobject::Base) do
        self.site = 'http://testing-test-tester.test/api/v1/users'
      end
    end

    context 'with overriding' do
      before do
        dummy_klass.default_headers = { 'Authorization' => 'Bearer TEST' }
      end

      it 'creates and sets a Hash with values' do
        expect(dummy_klass.default_headers).to eq({ 'Authorization' => 'Bearer TEST' })
      end
    end

    context 'without overriding' do
      it 'creates and sets a Hash without values' do
        expect(dummy_klass.default_headers).to eq({})
      end
    end
  end
end
