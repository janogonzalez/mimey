module JanoGB
  class CPU
    # NOP, opcode 0x00. Does nothing
    def nop
      @clock += 1
    end
    
    # LD RR,nn operations. Loads a 16 bits value to a 16 bits register
    [:bc, :de, :hl, :sp].each do |r|
      method_name = "ld_#{r}_nn"
      define_method(method_name) do
        send "#{r}=", next_word
        @clock += 3
      end
    end
    
    # LD (RR), A operations. Loads the A register into the memory pointed by RR regiser
    [:bc, :de, :hl].each do |r|
      method_name = "ld_m#{r}_a"
      define_method(method_name) do
        @mmu[bc] = @a
        @clock += 2
      end
    end

    # Operations array, indexes methods names by opcode
    OPERATIONS = [
      :nop, :ld_bc_nn, :ld_mbc_a
    ]
  end
end