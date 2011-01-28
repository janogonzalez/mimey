module JanoGB
  class CPU
    # NOP, opcode 0x00. Does nothing
    def nop
      @clock += 1
    end

    # Operations array, indexes methods names by opcode
    OPERATIONS = [
      :nop
    ]
  end
end