class RJSON::Parser
token STRING NUMBER TRUE FALSE NULL CORRUPTED
rule
  document
    : object
    | array
    | incomplete_object
    | incomplete_array
    ;
  object
    : start_object end_object
    | start_object pairs end_object
    ;
  incomplete_object
    : start_object
    | start_object corrupted_pair
    | start_object pairs
    | start_object pairs ','
    | start_object corrupted_pairs
    ;
  corrupted_pairs
    : pairs ',' corrupted_pair
    ;
  pairs
    : pairs ',' pair
    | pair
    ;
  pair
    : string ':' value
    ;
  corrupted_pair
    : string ':' corrupted
    | string ':'
    | string
    | corrupted
    ;
  array
    : start_array end_array
    | start_array values end_array
    ;
  incomplete_array
    : start_array
    | start_array corrupted
    | start_array values
    | start_array values ','
    | start_array corrupted_values
    ;
  start_array  : '[' { @handler.start_array  } ;
  end_array    : ']' { @handler.end_array    } ;
  start_object : '{' { @handler.start_object } ;
  end_object   : '}' { @handler.end_object   } ;
  corrupted_values
    : values ',' corrupted
    ;
  values
    : values ',' value
    | value
    ;
  value
    : scalar
    | object
    | array
    | incomplete_array
    | incomplete_object
    ;
  scalar
    : string
    | literal { @handler.scalar val[0] }
    ;
  literal
    : NUMBER { n = val[0]; result = n.count('.') > 0 ? n.to_f : n.to_i }
    | TRUE   { result = true }
    | FALSE  { result = false }
    | NULL   { result = nil }
    ;
  corrupted
    : CORRUPTED { result = :corrupted }
    ;
  string
    : STRING { @handler.scalar val[0].gsub(/^"|"$/, '') }
    ;
end

---- inner

  require 'rjson/handler'

  attr_reader :handler

  def initialize tokenizer, handler = Handler.new
    @tokenizer = tokenizer
    @handler   = handler
    super()
  end

  def next_token
    @tokenizer.next_token
  end

  def parse
    do_parse
    handler
  end
