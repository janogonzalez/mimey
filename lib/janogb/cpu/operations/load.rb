module JanoGB
  class CPU
    # LD RR,nn operations. Loads a 16 bits value to a 16 bits register
    [:bc, :de, :hl, :sp].each do |r|
      method_name = "ld_#{r}_nn"
      define_method(method_name) do
        send "#{r}=", next_word
        @clock += 3
      end
    end
    
    # LD (RR), A operations. Loads the A register into the
    # 16 bit memory direction pointed by RR regiser
    [:bc, :de, :hl].each do |r|
      method_name = "ld_m#{r}_a"
      define_method(method_name) do
        address = send "#{r}"
        @mmu[address] = @a
        @clock += 2
      end
    end
    
    # LD R,n operations. Loads a 8 bits value to a 8 bits register
    [:b, :c, :d, :e, :h, :l, :a].each do |r|
      method_name = "ld_#{r}_n"
      define_method(method_name) do
        instance_variable_set "@#{r}", next_byte
        @clock += 2
      end
    end
    
    # LD (NN),SP. Loads the 16 bits SP register into 16 bits memory direction NN
    def ld_mnn_sp
      @mmu.word[next_word] = sp
      @clock += 5
    end
    
    # LD A,(RR) operations. Loads the memory pointed by RR register
    # into the A register
    [:bc, :de, :hl].each do |r|
      method_name = "ld_a_m#{r}"
      define_method(method_name) do
        address = send "#{r}"
        @a = @mmu[address]
        @clock += 2
      end
    end
    
    # LD R,R operations. Load a 8 bit register into another
    [:b, :c, :d, :e, :h, :l, :a].each do |r1|
      [:b, :c, :d, :e, :h, :l, :a].each do |r2|
        method_name = "ld_#{r1}_#{r2}"
        define_method(method_name) do
          value = instance_variable_get "@#{r2}"
          instance_variable_set "@#{r1}", value
          @clock += 1
        end
      end
    end  
    
    # LD R,(HL) operations. Load the memory pointed by register HL into a 8 bits register
    [:b, :c, :d, :e, :h, :l].each do |r|
      method_name = "ld_#{r}_mhl"
      define_method(method_name) do
        instance_variable_set "@#{r}", @mmu[hl]
        @clock += 2
      end
    end
    
    # LD (HL),R operations. Load a 8 bits register into the memory pointed by register HL 
    [:b, :c, :d, :e, :h, :l].each do |r|
      method_name = "ld_mhl_#{r}"
      define_method(method_name) do
        value = instance_variable_get "@#{r}"
        @mmu[hl] = value
        @clock += 2
      end
    end
    
    # LDI (HL),A. Loads the A register into the memory pointed by HL, and then increments HL
    def ldi_mhl_a
      @mmu[hl] = @a
      self.hl = (hl + 1) & 0xFFFF
      @clock += 2
    end
    
    # LDI A,(HL). Loads the memory pointed by HL into the A register, and then increments HL
    def ldi_a_mhl
      @a = @mmu[hl]
      self.hl = (hl + 1) & 0xFFFF
      @clock += 2
    end
    
    # LDD (HL),A. Loads the A register into the memory pointed by HL, and then decrements HL
    def ldd_mhl_a
      @mmu[hl] = @a
      self.hl = (hl - 1) & 0xFFFF
      @clock += 2
    end
    
    # LDD A,(HL). Loads the memory pointed by HL into the A register, and then decrements HL
    def ldd_a_mhl
      @a = @mmu[hl]
      self.hl = (hl - 1) & 0xFFFF
      @clock += 2
    end
    
    # LD (HL),n. Loads a 8 bit number into the memory pointed by HL
    def ld_mhl_n
      @mmu[hl] = next_byte
      @clock += 3
    end
  end
end