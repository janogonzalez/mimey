module JanoGB
  class CPU
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
    
    # INC R operations. Increment R register by 1
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
    
    # RLCA. Rotates to the left the A register, loads the bit 7 into the C flag
    # Resets Z, N and H flags
    def rlca
      @f &= C_FLAG
      @f |= C_FLAG  if (@a & 0x80) == 0x80
      @a = ((@a << 1) | (@a >> 7)) & 0xFF
      @clock += 1
    end
    
    # RRCA. Rotates to the left the A register, loads the bit 0 into the C flag
    # Resets Z, N and H flags
    def rrca
      @f &= C_FLAG
      @f |= C_FLAG  if (@a & 0x01) == 0x01
      @a = ((@a >> 1) | ((@a & 0x01) << 7)) & 0xFF
      @clock += 1
    end
    
    # CPL. Sets the A register into its complement, sets the H and N flags.
    def cpl
      @a = ~@a & 0xFF
      @f |= (N_FLAG + H_FLAG)
      @clock += 1
    end
    
    # CCF. Sets the C flag into its complement, resets the H and N flags.
    def ccf
      val = @f
      @f &= Z_FLAG
      @f |= C_FLAG  unless (val & C_FLAG) == C_FLAG
      @clock += 1
    end
    
    # CCF. Sets the C flag, resets the H and N flags.
    def scf
      @f &= Z_FLAG
      @f |= C_FLAG
      @clock += 1
    end
    
    # ADD A,R operations. Add R 8 bits register to 8 bits A register
    # Set Z flag if result is 0
    # Reset N flag
    # Set H flag if carry from bit 3
    # Set C flag if carry from bit 7
    [:b, :c, :d, :e, :h, :l, :a].each do |r|
      method_name = "add_a_#{r}"
      define_method(method_name) do
        value = instance_variable_get "@#{r}"
        add_to_a value
        @clock += 1
      end
    end
    
    # ADD A,(HL). Adds memory pointed by HL register to 8 bits A register
    # Set Z flag if result is 0
    # Reset N flag
    # Set H flag if carry from bit 3
    # Set C flag if carry from bit 7
    def add_a_mhl
      value = @mmu[hl]
      add_to_a value
      @clock += 2
    end
    
    # ADD A,(HL). Adds a 8 bit value to 8 bits A register
    # Set Z flag if result is 0
    # Reset N flag
    # Set H flag if carry from bit 3
    # Set C flag if carry from bit 7
    def add_a_n
      value = next_byte
      add_to_a value
      @clock += 2
    end
    
    # ADC A,R operations. Add R 8 bits register and the C (carry) flag to 8 bits A register
    # Set Z flag if result is 0
    # Reset N flag
    # Set H flag if carry from bit 3
    # Set C flag if carry from bit 7
    [:b, :c, :d, :e, :h, :l, :a].each do |r|
      method_name = "adc_a_#{r}"
      define_method(method_name) do
        value = instance_variable_get("@#{r}") + ((@f & C_FLAG) >> 4)
        add_to_a value
        @clock += 1
      end
    end
    
    # ADC A,(HL). Adds memory pointed by HL register and the C (carry) flag to 8 bits A register
    # Sets Z flag if result is 0
    # Resets N flag
    # Sets H flag if carry from bit 3
    # Sets C flag if carry from bit 7
    def adc_a_mhl
      value = @mmu[hl] + ((@f & C_FLAG) >> 4)
      add_to_a value
      @clock += 2
    end
    
    # ADC A,n. Adds a 8 bit value and the C (carry) flag to 8 bits A register
    # Sets Z flag if result is 0
    # Resets N flag
    # Sets H flag if carry from bit 3
    # Sets C flag if carry from bit 7
    def adc_a_n
      value = next_byte + ((@f & C_FLAG) >> 4)
      add_to_a value
      @clock += 2
    end
    
    # Adds a value to the A register
    def add_to_a(to_add)
      sum = @a + to_add
      @f = 0x00
      @f |= Z_FLAG  if sum & 0xFF == 0x00
      @f |= H_FLAG  if (@a & 0x0F) + (to_add & 0x0F) > 0x0F
      @f |= C_FLAG  if sum > 0xFF
      @a = sum & 0xFF
    end
    
    # AND R operations. Do a logical AND between A and a 8 bits register and set the result in A
    # Set Z flag if result is 0
    # Reset N and C flags, Set H flag
    [:b, :c, :d, :e, :h, :l, :a].each do |r|
      method_name = "and_#{r}"
      define_method(method_name) do
        value = instance_variable_get "@#{r}"
        and_to_a value
        @clock += 1
      end
    end
    
    # AND (HL). Does a logical AND between A and the memory pointed by the HL register and set the result in A
    # Set Z flag if result is 0
    # Reset N and C flags, Set H flag
    def and_mhl
      value = @mmu[hl]
      and_to_a value
      @clock += 2
    end
    
    # AND N. Does a logical AND between A and a 8 bit value and set the result in A
    # Set Z flag if result is 0
    # Reset N and C flags, Set H flag
    def and_n
      value = next_byte
      and_to_a value
      @clock += 2
    end
    
    # Does a logical AND to the A register
    def and_to_a(to_and)
      @a &= to_and
      @f = 0x00
      @f |= H_FLAG
      @f |= Z_FLAG  if @a == 0x00
    end

    # XOR R operations. Do a logical XOR between A and a 8 bits register and set the result in A
    # Set Z flag if result is 0
    # Reset N, H and C flags
    [:b, :c, :d, :e, :h, :l, :a].each do |r|
      method_name = "xor_#{r}"
      define_method(method_name) do
        value = instance_variable_get "@#{r}"
        xor_to_a value
        @clock += 1
      end
    end
    
    # XOR (HL). Does a logical XOR between A and the memory pointed by the HL register and set the result in A
    # Sets Z flag if result is 0
    # Resets N, H and C flags
    def xor_mhl
      value = @mmu[hl]
      xor_to_a value
      @clock += 2
    end
    
    # XOR N. Does a logical XOR between A and a 8 bit value and set the result in A
    # Sets Z flag if result is 0
    # Resets N, H and C flags
    def xor_n
      value = next_byte
      xor_to_a value
      @clock += 2
    end
    
    # Does a logical XOR to the A register
    def xor_to_a(to_xor)
      @a ^= to_xor
      @f = 0x00
      @f |= Z_FLAG  if @a == 0x00
    end
    
    # OR R operations. Do a logical OR between A and a 8 bits register and set the result in A
    # Set Z flag if result is 0
    # Reset N, H and C flags
    [:b, :c, :d, :e, :h, :l, :a].each do |r|
      method_name = "or_#{r}"
      define_method(method_name) do
        value = instance_variable_get "@#{r}"
        or_to_a value
        @clock += 1
      end
    end
    
    # OR (HL). Does a logical OR between A and the memory pointed by the HL register and set the result in A
    # Sets Z flag if result is 0
    # Resets N, H and C flags
    def or_mhl
      value = @mmu[hl]
      or_to_a value
      @clock += 2
    end
    
    # OR N. Does a logical OR between A and a 8 bit value and set the result in A
    # Sets Z flag if result is 0
    # Resets N, H and C flags
    def or_n
      value = next_byte
      or_to_a value
      @clock += 2
    end
    
    # Does a logical XOR to the A register
    def or_to_a(to_or)
      @a |= to_or
      @f = 0x00
      @f |= Z_FLAG  if @a == 0x00
    end
  end
end