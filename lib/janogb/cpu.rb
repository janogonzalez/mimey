module JanoGB
  # This class represents the Game Boy CPU, a modified Z80.
  class CPU
    # 8 bit registers: A, F, B, C, D, E, H, L
    attr_reader :a, :f, :b, :c, :d, :e, :h, :l
    # 16 bit PC register (Program counter)
    attr_reader :pc
    # 16 bit SP register (Stack pointer)
    attr_reader :sp
    
    # Default register values
    DEFAULTS = {
      a: 0x00,
      f: 0x00,
      b: 0x00,
      c: 0x00,
      d: 0x00,
      e: 0x00,
      h: 0x00,
      l: 0x00,
      pc: 0x0000,
      sp: 0x0000
    }
    
    # Creates a new CPU and initializes with the provided options
    # if no options where give all the registers will be 0
    def initialize(options = {})
      DEFAULTS.merge(options).each do |k, v|
        instance_variable_set("@#{k}", v)
      end
    end
    
    # Gets the value of the "virtual" 16 bits AF register
    def af
      (@a << 8) + @f
    end
    
    # Gets the value of the "virtual" 16 bits BC register
    def bc
      (@b << 8) + @c
    end
    
    # Gets the value of the "virtual" 16 bits DE register
    def de
      (@d << 8) + @e
    end
    
    # Gets the value of the "virtual" 16 bits HL register
    def hl
      (@h << 8) + @l
    end
  end
end