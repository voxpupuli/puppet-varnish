# frozen_string_literal: true

require 'spec_helper'

describe 'Varnish::Controller::Agent_name' do
  describe 'valid handling' do
    %w[
      foo01
      foo-10
      123
      foo
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
        'foo.bar',
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
