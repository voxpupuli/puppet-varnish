# frozen_string_literal: true

require 'spec_helper'

describe 'Varnish::Vcl::Duration' do
  describe 'valid handling' do
    [
      123,
      1,
      1.0,
      '1',
      '1.0',
      '1234',
      '1.2s',
      '1.5m',
    ].each do |value|
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
        '',
        '4-2',
        'asd/',
        'bob@example.com',
        '%.example.com',
        '2001:0d8',
        '1.2mm',
        '1x',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
