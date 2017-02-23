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
      when text = @ss.scan(NUMBER) then [:NUMBER, text]
      when text = @ss.scan(TRUE)   then [:TRUE, text]
      when text = @ss.scan(FALSE)  then [:FALSE, text]
      when text = @ss.scan(NULL)   then [:NULL, text]

      when x = @ss.scan(OPEN_SQ)     then [x, x]
      when x = @ss.scan(CLOSE_SQ)    then [x, x]
      when x = @ss.scan(OPEN_CURLY)  then [x, x]
      when x = @ss.scan(CLOSE_CURLY) then [x, x]
      when x = @ss.scan(COMMA)       then [x, x]
      when x = @ss.scan(COLON)       then [x, x]

      else
        text = @ss.rest
        [:CORRUPTED, text]
      end
    end
  end
end
