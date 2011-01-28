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

    # INC RR operations. Increment RR register by 1. If current register value is 0xFFFF,
    # it will be 0x0000 after method execution
    [:bc, :de, :hl, :sp].each do |r|
      method_name = "inc_#{r}"
      define_method(method_name) do
        value = send "#{r}"
        send "#{r}=", (value + 1) & 0xFFFF
        @clock += 2
      end
    end
    
    # INC B operations. Increment R register by 1
    # Sets Z flag if result is 0
    # Resets N flag
    # Sets H flag if carry from bit 3
    # C flag is not affected
    [:b, :c, :d, :e, :h, :l, :a].each do |r|
      method_name = "inc_#{r}"
      define_method(method_name) do
        value = instance_variable_get "@#{r}"
        new_value = (value + 1) & 0xFF
        instance_variable_set "@#{r}", new_value
        @f &= C_FLAG
        @f |= Z_FLAG  if new_value == 0x00
        @f |= H_FLAG  if (new_value & 0x0F) == 0x00
        @clock += 1
      end
    end

    # Operations array, indexes methods names by opcode
    OPERATIONS = [
      :nop, :ld_bc_nn, :ld_mbc_a, :inc_bc, :inc_b
    ]
  end
end