require 'hipsterhash'

module Ebayr
  class Record < HipsterHash
  protected
    def convert_key(key)
      super.to_s.sub('e_bay', 'ebay')
    end
  end
end
