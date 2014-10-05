require "observable_object/version"

module ObservableObject
  class Notifier
    def initialize(param,&event)
      @param = param
      @event = event
    end
    def call
      @event.call(@param)
    end
  end

  module DeepWrap
    def self.map_obj(obj,notifier)
      case obj
        when Array then obj.map { |x| wrap_elem(x,notifier) }
        when Set then obj.clone.map! { |x| wrap_elem(x,notifier) }
        when Hash then obj.map { |k,v| [ k, wrap_elem(v,notifier) ] }.to_h
        else obj
      end 
    end

    NonWrappable = [Symbol, Numeric, TrueClass, FalseClass, NilClass]
    def self.is_unwrappable(elem)
      NonWrappable.any? { |t| elem.is_a?(t) }
    end
    def self.wrap_elem(elem,notifier)
      is_unwrappable(elem) ? elem : Wrapper.new(elem,:detect,true,notifier)
    end
  end

  module Watcher
    class WatcherDetect
      DefaultMethods = [  :<<, :[]=, :add, :add?, :capitalize!, :chomp!, :chop!, :clear, :collect!, :compact!, :concat, 
                          :delete, :delete!, :delete?, :delete_at, :delete_if, :downcase!, :encode!, :gsub!, :fill, 
                          :flatten!, :initialize_copy, :insert, :keep_if, :lstrip!, :map!, :merge!, :next!, :pop, :prepend, 
                          :push, :rehash, :reject!, :replace, :reverse!, :rotate!, :rstrip!, :scrub!, :select!, 
                          :shift, :shuffle!, :slice!, :sort!, :sort_by!, :squeeze!, :store, :strip!, :sub!, :subtract,
                          :succ!, :swapcase!, :tr!, :tr_s!, :uniq!, :unshift, :upcase!, :update ]
      StringExceptionMethods = [ :delete ]  # doesn't change the object in case of String

      def initialize(obj)
        @methods = obj.is_a?(String) ? DefaultMethods-StringExceptionMethods : DefaultMethods
      end
      def remember
        # nothing to do
      end
      def is_state_changing(obj,mname)
        mname.match(/.+\!\z/) || @methods.include?(mname)
      end
    end
    
    class WatcherMethods
      def initialize(methods)
        @methods = methods
      end
      def remember
        # nothing to do
      end
      def is_state_changing(obj,mname)
        @methods.include?(mname)
      end
    end
    
    class WatcherCompare
      def remember
        obj = yield
        @obj_before = obj.clone rescue obj
      end
      def is_state_changing(obj,mname)
        !obj.eql?(@obj_before)
      end
    end

    def self.create(obj,methods)
      case methods
        when :detect then WatcherDetect.new(obj)
        when :compare then WatcherCompare.new
        else WatcherMethods.new(methods)
      end
    end
  end
  
  class Wrapper < BasicObject
    def initialize(obj,methods,deep,notifier=nil,&event)
      @deep = deep
      @notifier = notifier || Notifier.new(self,&event)
      @watcher = Watcher::create(obj,methods)
      @obj = @deep ? DeepWrap::map_obj(obj,@notifier) : obj
    end
    
    def ==(other)
      @obj == other
    end
    def eql?(other)
      @obj.eql?(other)
    end
    def !=(other)
      @obj != other
    end
    def !
      !@obj
    end

    def respond_to?(mname)
      @obj.respond_to?(mname)
    end
    def method_missing(mname,*args,&block)
      @watcher.remember { @obj }

      res = @obj.__send__(mname,*args,&block)
      chain = @obj.equal?(res)                # did the wrapped object return itself from this method?
      
      if @watcher.is_state_changing(@obj,mname)
        @obj = DeepWrap::map_obj(@obj,@notifier) if @deep # remap; some nested objects could have changed
        @notifier.call 
      end
      
      chain ? self : res                      # for chaining return self when the underlying object returns self
    end
  end
  
  # Main API
  def self.wrap(obj,methods=:detect,&event)
    DeepWrap.is_unwrappable(obj) ? obj : Wrapper.new(obj,methods,false,nil,&event)
  end
  def self.deep_wrap(obj,methods=:detect,&event)
    DeepWrap.is_unwrappable(obj) ? obj : Wrapper.new(obj,methods,true,nil,&event)
  end
end
