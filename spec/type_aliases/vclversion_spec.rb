# frozen_string_literal: true

require 'spec_helper'

describe 'Varnish::Vclversion' do
  describe 'valid handling' do
    ['4'].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'invalid handling' do
    context 'garbage inputs' do
      [
        [nil],
        [nil, nil],
        { 'foo' => 'bar' },
        {},
        '3',
        '',
        '4-2',
        'bob@example.com',
        '%.example.com',
        '2001:0d8',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
