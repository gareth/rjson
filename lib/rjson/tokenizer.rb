require 'strscan'

module RJSON
  class Tokenizer
    STRING = /"(?:[^"\\]|\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4}))*"/
    NUMBER = /-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?\b/
    TRUE   = /true/
    FALSE  = /false/
    NULL   = /null/

    OPEN_SQ     = /\[/
    CLOSE_SQ    = /\]/
    OPEN_CURLY  = /\{/
    CLOSE_CURLY = /\}/
    COMMA       = /,/
    COLON       = /:/

    def initialize io
      @ss = StringScanner.new io.read
    end

    def next_token
      return if @ss.eos?

      case
      when text = @ss.scan(STRING) then [:STRING, text]
      when text = @ss.scan(TRUE)   then [:TRUE, text]
      when text = @ss.scan(FALSE)  then [:FALSE, text]
      when text = @ss.scan(NULL)   then [:NULL, text]

      when x = @ss.scan(OPEN_SQ)     then [x, x]
      when x = @ss.scan(CLOSE_SQ)    then [x, x]
      when x = @ss.scan(OPEN_CURLY)  then [x, x]
      when x = @ss.scan(CLOSE_CURLY) then [x, x]
      when x = @ss.scan(COMMA)       then [x, x]
      when x = @ss.scan(COLON)       then [x, x]
      
      when text = @ss.scan(NUMBER)
        next_ch = @ss.peek(1)
        # Peek at the next char to check it's not an `e` or a `.`
        # If it is, then we have corrupted data, not a valid number token
        if ['e', '.'].include? next_ch
          text << @ss.getch
          [:CORRUPTED, text]
        else
          [:NUMBER, text]
        end

      else
        text = @ss.rest
        @ss.terminate
        [:CORRUPTED, text]
      end
    end
  end
end
