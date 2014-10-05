require 'spec_helper'

describe ObservableObject::Notifier do
  it 'calls the specified event with the specified param' do
    param = "some parameter"
    called_with = nil
    notifier = ObservableObject::Notifier.new(param) do |p|
      called_with = p
    end
    expect(called_with).to be(nil)
    expect{notifier.call}.not_to raise_error
    expect(called_with).to be(param)
  end
end