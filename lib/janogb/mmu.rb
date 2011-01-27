module JanoGB
  # his class represents the Game Boy MMU
  class MMU
    # Initializes the memory areas
    def initialize
      @internal_memory = Array.new(8192, 0x00)
    end
    
    # Reads a byte from to the different memory areas
    def [](i)
      case i
      when 0xC000..0xDFFF, 0xE000..0xFDFF
        @internal_memory[i & 0x1FFF]
      end
    end
    
    # Writes a byte to the different memory areas
    def []=(i, n)
      case i
      when 0xC000..0xDFFF, 0xE000..0xFDFF
        @internal_memory[i & 0x1FFF] = n
      end
    end
  end
end