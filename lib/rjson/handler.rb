module RJSON
  class Handler
    attr_reader :stack

    def initialize
      @stack = [[:root]]
    end

    def start_object
      push [:hash]
    end

    def start_array
      push [:array]
    end

    def end_array
      @stack.pop
    end
    alias :end_object :end_array

    def scalar s
      @stack.last << [:scalar, s]
    end

    def push o
      @stack.last << o
      @stack << o
    end

    def result
      root = @stack.first.last
      process root.first, root.drop(1)
    end

    def process type, rest
      case type
      when :array
        rest.map { |x| process(x.first, x.drop(1)) }
      when :hash
        Hash[rest.map { |x|
          process(x.first, x.drop(1))
        }.each_slice(2).to_a]
      when :scalar
        rest.first
      end
    end

    # Recover an invalid parse tree by dropping items that we're not certain are
    # fully recoverable
    def recover!
      binding.pry
      current_context = stack.last
      _type, *rest = current_context

      # If the last thing we processed was a number, we don't know whether it
      # was a complete number, so we pretend it was never read at all.
      _last_entry_type, last_entry_value = rest.last
      case last_entry_value
      when Numeric
        stack.last.pop
      end

      type, *rest = current_context

      case type
      when :hash
        stack.last.pop if rest.size.odd?
      end
    end
  end
end
