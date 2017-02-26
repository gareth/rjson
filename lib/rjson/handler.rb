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
      # If we're in an unclosed array or hash and we have a corrupted token at
      # the end of that context, remove that token
      last_tokens_context = @stack.last
      last_token = last_tokens_context.last

      if last_token.is_a?(Array)
        last_token_value = last_token.last
        if last_token_value.is_a?(Numeric) || last_token_value == :corrupted
          # Remove corrupted data
          last_tokens_context.pop
        end
      end

      # The next line succeeds whether or not all arrays/hashes have been closed
      root = @stack.first.last
      process root.first, root.drop(1)
    end

    def process type, rest
      case type
      when :array
        rest.map { |x| process(x.first, x.drop(1)) }
      when :hash
        Hash[
          rest.
          map { |x| process(x.first, x.drop(1)) }.
          each_slice(2).
          # Only take Keys that also have values
          take_while { |i| i.size == 2 }
        ]
      when :scalar
        rest.first
      end
    end
  end
end
