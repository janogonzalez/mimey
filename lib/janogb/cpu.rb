require 'janogb/cpu/operations'

module JanoGB
  # This class represents the Game Boy CPU, a modified Z80.
  class CPU    
    # 8 bit registers: A, F, B, C, D, E, H, L
    attr_reader :a, :f, :b, :c, :d, :e, :h, :l
    # 16 bit PC register (Program counter)
    attr_reader :pc
    # 16 bit SP register (Stack pointer)
    attr_reader :sp
    # CPU Clock
    attr_reader :clock
    
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
    
    # Bitmasks for Z, N, H and C flags from the F register
    Z_FLAG = 0b1000_0000
    N_FLAG = 0b0100_0000
    H_FLAG = 0b0010_0000
    C_FLAG = 0b0001_0000
    
    # Creates a new CPU and initializes with the provided options
    # if no options where give all the registers will be 0
    def initialize(options = {})   
      DEFAULTS.merge(options).each do |k, v|
        instance_variable_set("@#{k}", v)
      end
      
      @clock = 0
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
    
    # Gets the Z flag from the F register
    def z_flag
      (@f & Z_FLAG) == Z_FLAG
    end
    
    # Gets the N flag from the F register
    def n_flag
      (@f & N_FLAG) == N_FLAG
    end
    
    # Gets the H flag from the F register
    def h_flag
      (@f & H_FLAG) == H_FLAG
    end
    
    # Gets the C flag from the F register
    def c_flag
      (@f & C_FLAG) == C_FLAG
    end
  end
end