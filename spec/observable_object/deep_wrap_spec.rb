require 'spec_helper'

describe ObservableObject::DeepWrap do
  class TestNotificationStatus
    attr_reader :count
    def initialize
      @count = 0
    end
    def notify
      @count += 1
    end
    def notified?
      count > 0
    end
  end
  
  let(:notification_status) { TestNotificationStatus.new }
  let(:notifier) { ObservableObject::Notifier.new(notification_status) { |param| param.notify } }

  it 'keeps wrapped elements equal to original elems' do
    ObservableObjectTest::AllObjects.each do |original|
      expect(ObservableObject::DeepWrap.map_obj(original,notifier)).to eq(original)
    end
  end
  
  it 'wraps elements of Array' do
    original = ["string", [1,2,3]]
    wrapped = ObservableObject::DeepWrap.map_obj(original,notifier)

    wrapped[0][0] = 'S' # should notify
    expect(notification_status.count).to eq(1)

    wrapped[1] << 5 # should notify
    expect(notification_status.count).to eq(2)
  end

  it 'wraps elements of Hash' do
    original = {a: "string", b: [1,2,3]}
    wrapped = ObservableObject::DeepWrap.map_obj(original,notifier)

    wrapped[:a][0] = 'S' # should notify
    expect(notification_status.count).to eq(1)

    wrapped[:b] << 5 # should notify
    expect(notification_status.count).to eq(2)
  end

  it 'wraps elements of Set' do
    original = Set[[1,2,3],{0=>1,1=>2}] # note: strings are frozen, don't use them in Set testing
    wrapped = ObservableObject::DeepWrap.map_obj(original,notifier)

    wrapped.each do |elem| 
      elem[0] = 'A' # should notify
    end
    expect(notification_status.count).to eq(original.size)
  end

  it 'does not wrap Strings' do
    original = "string"
    wrapped = ObservableObject::DeepWrap.map_obj(original,notifier)

    wrapped[0] = 'S' # should not notify
    expect(notification_status.count).to eq(0)
  end

  it 'deep wraps Arrays' do
    original = []
    original[0] = []
    original[0][0] = []
    original[0][0][0] = []
    original[0][0][0][0] = []
    original[0][0][0][0][0] = "string"
    wrapped = ObservableObject::DeepWrap.map_obj(original,notifier)

    wrapped[0][0][0][0][0][0] = 'S'
    expect(notification_status.count).to eq(1)
  end
  
  it 'deep wraps Hashes' do
    original = {}
    original[:a] = {}
    original[:a][:a] = {}
    original[:a][:a][:a] = {}
    original[:a][:a][:a][:a] = {}
    original[:a][:a][:a][:a][:a] = "string"
    wrapped = ObservableObject::DeepWrap.map_obj(original,notifier)

    wrapped[:a][:a][:a][:a][:a][0] = 'S'
    expect(notification_status.count).to eq(1)
  end
  
  it 'deep wraps Sets' do
    original = Set[Set[Set[{a:100}]]]
    wrapped = ObservableObject::DeepWrap.map_obj(original,notifier)

    wrapped.each do |x|     # x = Set[Set[{a:100}]]
      x.each do |y|         # y = Set[{a:100}]
        y.each do |z|       # z = {a:100}
          z[:a] = 200
        end
      end
    end
    
    expect(notification_status.count).to eq(1)
  end
  

end