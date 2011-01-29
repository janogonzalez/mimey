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
    
    # DEC B operations. Decrement R register by 1
    # Sets Z flag if result is 0
    # Sets N flag
    # Sets H flag if no borrow from bit 4
    # C flag is not affected
    [:b, :c, :d, :e, :h, :l, :a].each do |r|
      method_name = "dec_#{r}"
      define_method(method_name) do
        value = instance_variable_get "@#{r}"
        new_value = (value - 1) & 0xFF
        instance_variable_set "@#{r}", new_value
        @f &= C_FLAG
        @f |= N_FLAG
        @f |= Z_FLAG  if new_value == 0x00
        @f |= H_FLAG  if (new_value & 0x0F) == 0x0F
        @clock += 1
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
    
    # ADD HL,RR operations. Adds a 16 bits register to HL
    [:bc, :de, :hl, :sp].each do |r|
      method_name = "add_hl_#{r}"
      define_method(method_name) do
        to_add = send "#{r}"
        sum = hl + to_add
        @f &= Z_FLAG
        @f |= H_FLAG  if (hl & 0x0FFF) + (to_add & 0x0FFF) > 0x0FFF
        @f |= C_FLAG  if sum > 0xFFFF
        self.hl = sum & 0xFFFF
        @clock += 2
      end
    end
    
    # LD A,(RR) operations. Loads the 16 bit memory pointed by RR register
    # into the A register
    [:bc, :de, :hl].each do |r|
      method_name = "ld_a_m#{r}"
      define_method(method_name) do
        address = send "#{r}"
        @a = @mmu[address]
        @clock += 2
      end
    end
    
    # DEC RR operations. Decrement RR register by 1. If current register value is 0x0000,
    # it will be 0xFFFF after method execution
    [:bc, :de, :hl, :sp].each do |r|
      method_name = "dec_#{r}"
      define_method(method_name) do
        value = send "#{r}"
        send "#{r}=", (value - 1) & 0xFFFF
        @clock += 2
      end
    end

    # Operations array, indexes methods names by opcode
    OPERATIONS = [
      :nop, :ld_bc_nn, :ld_mbc_a, :inc_bc, :inc_b, :dec_b, :ld_b_n, :_07, :ld_mnn_sp, :add_hl_bc, :ld_a_mbc, :dec_bc, :inc_c, :dec_c, :ld_c_n, :_0F,
      :_10, :ld_de_nn, :ld_mde_a, :inc_de, :inc_d, :dec_d, :ld_d_n, :_17, :_18, :add_hl_de, :add_a_mde, :dec_de, :inc_e, :dec_e, :ld_e_n, :_1F,
      :_20, :ld_hl_nn, :ld_mhl_a, :inc_hl, :inc_h, :dec_h, :ld_h_n, :_27, :_28, :add_hl_hl, :_2A, :dec_hl, :inc_l, :dec_l, :ld_l_n, :_2F,
      :_30, :ld_sp_nn, :_32, :inc_sp, :_34, :_35, :_36, :_37, :_38, :add_hl_sp, :_3A, :dec_sp, :inc_a, :dec_a, :ld_a_n, :_3F
    ].freeze
  end
end