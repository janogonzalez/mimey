require 'rspec'
require 'janogb'

describe "CPU operations" do
  include JanoGB
  
  it "should have a NOP operation with opcode 0x00 that does nothing" do
    cpu = CPU.new
    
    cpu.load_with(0x00).step

    [:a, :f, :b, :c, :d, :e, :h, :l, :sp].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end
    
    cpu.pc.should == 0x0001
    cpu.clock.should == 1
  end
  
  describe "LD RR,nn operations" do
    it "must be 4" do
      cpu = CPU.new
      
      opcodes = [0x01, 0x11, 0x21, 0x31]
      
      [:ld_bc_nn, :ld_de_nn, :ld_hl_nn, :ld_sp_nn].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
  
    it "must load a 16 bit value into a 16 bit register" do
      cpu = CPU.new
    
      cpu.load_with(0x01, 0xAB, 0xCD).step
    
      [:a, :f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
    
      cpu.bc.should == 0xABCD
      cpu.pc.should == 0x0003
      cpu.clock.should == 3
    end
  end
  
  describe "LD (RR),A operations" do
    it "must be 3" do
      cpu = CPU.new
      
      opcodes = [0x02, 0x12, 0x77]
      
      [:ld_mbc_a, :ld_mde_a, :ld_mhl_a].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
  
    it "must load the A register into the memory at address pointed by register RR" do
      cpu = CPU.new(a:0xAB, b: 0xCA, c:0xFE)
    
      cpu.load_with(0x02).step
    
      [:f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
    
      cpu.mmu[0xCAFE].should == 0xAB
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
  end
  
  describe "INC RR operations" do
    it "must be 4" do
      cpu = CPU.new
      
      opcodes = [0x03, 0x13, 0x23, 0x33]
      
      [:inc_bc, :inc_de, :inc_hl, :inc_sp].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
    
    it "should increment a register" do
      cpu = CPU.new
      
      cpu.load_with(0x03).step
      
      [:a, :f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.bc.should == 0x0001
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should let in 0x0000 a register with 0xFFFF" do
      cpu = CPU.new(b:0xFF, c:0xFF)
      
      cpu.load_with(0x03).step
      
      [:a, :b, :c, :f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
  end
  
  describe "INC R operations" do
    it "must be 7" do
      cpu = CPU.new
      
      opcodes = [0x04, 0x0C, 0x14, 0x1C, 0x24, 0x2C, 0x3C]
      
      [:inc_b, :inc_c, :inc_d, :inc_e, :inc_h, :inc_l, :inc_a].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
    
    it "must increment register R by 1" do
      cpu = CPU.new
      
      cpu.load_with(0x04).step
      
      [:a, :c, :f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.b.should == 0x01
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should set H flag if current value is 0x0F" do
      cpu = CPU.new(b: 0x0F)
      
      cpu.load_with(0x04).step
      
      [:a, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.b.should == 0x10
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should let the register in 0x00 and set Z and H flags if current value is 0xFF" do
      cpu = CPU.new(b:0xFF)
      
      cpu.load_with(0x04).step
      
      [:a, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.z_flag.should be_true
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "must not affect the C flag" do
      cpu = CPU.new(f: 0b0001_0000)
      
      cpu.load_with(0x04).step
      
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_true
    end
  end
  
  describe "DEC R operations" do
    it "must be 7" do
      cpu = CPU.new
      
      opcodes = [0x05, 0x0D, 0x15, 0x1D, 0x25, 0x2D, 0x3D]
      
      [:dec_b, :dec_c, :dec_d, :dec_e, :dec_h, :dec_l, :dec_a].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
    
    it "should let the register in 0x00 and set Z and N flags if current value is 0x01" do
      cpu = CPU.new(b:0x01)
      
      cpu.load_with(0x05).step
      
      [:a, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.z_flag.should be_true
      cpu.n_flag.should be_true
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should set N and H flags if current value is 0x10" do
      cpu = CPU.new(b:0x10)
      
      cpu.load_with(0x05).step
      
      [:a, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.b.should == 0x0F
      cpu.z_flag.should be_false
      cpu.n_flag.should be_true
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should set N flags if current value is 0xFF" do
      cpu = CPU.new(b:0xFF)
      
      cpu.load_with(0x05).step
      
      [:a, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.b.should == 0xFE
      cpu.z_flag.should be_false
      cpu.n_flag.should be_true
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should let the register in 0xFF and set Z and H flags if current value is 0x00" do
      cpu = CPU.new()
      
      cpu.load_with(0x05).step
      
      [:a, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.b.should == 0xFF
      cpu.z_flag.should be_false
      cpu.n_flag.should be_true
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "must not affect the C flag" do
      cpu = CPU.new(b:0x01, f:0b0001_0000)
      
      cpu.load_with(0x05).step
      
      [:a, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.z_flag.should be_true
      cpu.n_flag.should be_true
      cpu.h_flag.should be_false
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
  end
  
  describe "LD R,n operations" do
    it "must be 7" do
      cpu = CPU.new
      
      opcodes = [0x06, 0x0E, 0x16, 0x1E, 0x26, 0x2E, 0x3E]
      
      [:ld_b_n, :ld_c_n, :ld_d_n, :ld_e_n, :ld_h_n, :ld_l_n, :ld_a_n].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
  
    it "must load a 8 bit value into a 8 bit register" do
      cpu = CPU.new
    
      cpu.load_with(0x06, 0xAB).step
    
      [:a, :f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
    
      cpu.b.should == 0xAB
      cpu.pc.should == 0x0002
      cpu.clock.should == 2
    end
  end
  
  it "must have a LD (nn),SP operation with opcode 0x08 that loads the SP register into the memory" do
    cpu = CPU.new(sp:0xABCD)
    
    cpu.load_with(0x08, 0xCA, 0xFE).step

    [:a, :b, :f, :b, :c, :d, :e, :h, :l].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end
    
    cpu.mmu.word[0xCAFE].should == 0xABCD
    cpu.pc.should == 0x0003
    cpu.clock.should == 5
  end
  
  describe "ADD HL,RR operations" do
    it "must be 4" do
      cpu = CPU.new
      
      opcodes = [0x09, 0x19, 0x29, 0x39]
      
      [:add_hl_bc, :add_hl_de, :add_hl_hl, :add_hl_sp].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
    
    it "must add to HL register the value of the RR register" do
      cpu = CPU.new(b:0xAC, c:0xDB, h:0x00, l:01)
      
      cpu.load_with(0x09).step
      
      [:a, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.hl.should == 0xACDC
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should set H flag if current value is of the form 0xnFFF and the value to is not of the form 0xn000" do
      cpu = CPU.new(b:0x00, c:0x01, h:0x0F, l:0xFF)
      
      cpu.load_with(0x09).step
      
      [:a, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.hl.should == 0x1000
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should not set H flag if current value is of the form 0xnFFF and the value to add is of the form 0xn000" do
      cpu = CPU.new(b:0x10, c:0x00, h:0x0F, l:0xFF)
      
      cpu.load_with(0x09).step
      
      [:a, :f, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.hl.should == 0x1FFF
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should set H and C flags if sum overflows" do
      cpu = CPU.new(b:0x00, c:0x01, h:0xFF, l:0xFF)
      
      cpu.load_with(0x09).step
      
      [:a, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.hl.should == 0x0000
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "must not affect the Z flag" do
      cpu = CPU.new(b:0xAB, c:0xCD, f:0b1000_0000)
      
      cpu.load_with(0x09).step
      
      [:a, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.hl.should == 0xABCD
      cpu.z_flag.should be_true
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
  end

  describe "LD A,(RR) operations" do
    it "must be 3" do
      cpu = CPU.new
      
      opcodes = [0x0A, 0x1A, 0x7E]
      
      [:ld_a_mbc, :ld_a_mde, :ld_a_mhl].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
  
    it "must load the memory at address pointed by register RR into the A register" do
      cpu = CPU.new(b:0xCA, c:0xFE)
      
      cpu.mmu[0xCAFE] = 0xAB
      cpu.load_with(0x0A).step
    
      [:f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
    
      cpu.a.should == 0xAB
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
  end
  
  describe "DEC RR operations" do
    it "must be 4" do
      cpu = CPU.new
      
      opcodes = [0x0B, 0x1B, 0x2B, 0x3B]
      
      [:dec_bc, :dec_de, :dec_hl, :dec_sp].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
    
    it "should decrement a register" do
      cpu = CPU.new(b:0x00, c:0x01)
      
      cpu.load_with(0x0B).step
      
      [:a, :b, :c, :f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should let in 0xFFFF a register with 0x0000" do
      cpu = CPU.new(b:0x00, c:0x00)
      
      cpu.load_with(0x0B).step
      
      [:a, :f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.bc.should == 0xFFFF
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
  end
  
  describe "RLCA" do
    it "should rotate the bits of the A register to the left" do
      cpu = CPU.new(a:0x01)
      
      cpu.load_with(0x07).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x02
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should load the bit 7 into the C flag" do
      cpu = CPU.new(a:0xFE)
      
      cpu.load_with(0x07).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0xFD
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
  end
  
  describe "RRCA" do
    it "should rotate the bits of the A register to the right" do
      cpu = CPU.new(a:0x02)
      
      cpu.load_with(0x0F).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x01
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should load the bit 0 into the C flag" do
      cpu = CPU.new(a:0x7F)
      
      cpu.load_with(0x0F).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0xBF
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
  end
  
  describe "LD R,R operations" do
    it "must be 49" do
      cpu = CPU.new
      
      opcodes = [
        0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x47,
        0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4F,
        0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x57,
        0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5F,
        0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x67,
        0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6F,
        0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7F,
      ]
      
      operations = [
        :ld_b_b, :ld_b_c, :ld_b_d, :ld_b_e, :ld_b_h, :ld_b_l, :ld_b_a,
        :ld_c_b, :ld_c_c, :ld_c_d, :ld_c_e, :ld_c_h, :ld_c_l, :ld_c_a,
        :ld_d_b, :ld_d_c, :ld_d_d, :ld_d_e, :ld_d_h, :ld_d_l, :ld_d_a,
        :ld_e_b, :ld_e_c, :ld_e_d, :ld_e_e, :ld_e_h, :ld_e_l, :ld_e_a,
        :ld_h_b, :ld_h_c, :ld_h_d, :ld_h_e, :ld_h_h, :ld_h_l, :ld_h_a,
        :ld_l_b, :ld_l_c, :ld_l_d, :ld_l_e, :ld_l_h, :ld_l_l, :ld_l_a,
        :ld_a_b, :ld_a_c, :ld_a_d, :ld_a_e, :ld_a_h, :ld_a_l, :ld_a_a,
      ]
      
      operations.each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
  
    it "must load a 8 bit register into another 8 bit register" do
      cpu = CPU.new(c:0xAB)
    
      cpu.load_with(0x41).step
    
      [:a, :f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
    
      cpu.b.should == 0xAB
      cpu.c.should == 0xAB
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
  end
  
  describe "LD R,(HL) operations" do
    it "must be 6" do
      cpu = CPU.new
      
      opcodes = [0x46, 0x4E, 0x56, 0x5E, 0x66, 0x6E]
      
      [:ld_b_mhl, :ld_c_mhl, :ld_d_mhl, :ld_e_mhl, :ld_h_mhl, :ld_l_mhl].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
  
    it "must load the memory at address pointed by register HL into the register" do
      cpu = CPU.new(h:0xCA, l:0xFE)
      
      cpu.mmu[0xCAFE] = 0xAB
      cpu.load_with(0x46).step
    
      [:a, :c, :f, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
    
      cpu.b.should == 0xAB
      cpu.hl.should == 0xCAFE
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
  end
  
  describe "LD (HL),R operations" do
    it "must be 6" do
      cpu = CPU.new
      
      opcodes = [0x70, 0x71, 0x72, 0x73, 0x74, 0x75]
      
      [:ld_mhl_b, :ld_mhl_c, :ld_mhl_d, :ld_mhl_e, :ld_mhl_h, :ld_mhl_l].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
  
    it "must load he register into the memory at address pointed by register HL" do
      cpu = CPU.new(b:0xAB, h:0xCA, l:0xFE)

      cpu.load_with(0x70).step
    
      [:a, :c, :f, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.mmu[0xCAFE].should == 0xAB
      cpu.b.should == 0xAB
      cpu.hl.should == 0xCAFE
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
  end

  it "must have a LDI (HL),A operation with opcode 0x22 that loads the A register into the memory pointed by HL, and then increments HL" do
    cpu = CPU.new(a:0xAB, h:0xCA, l:0xFD)
    
    cpu.load_with(0x22).step

    [:b, :f, :b, :c, :d, :e, :sp].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end
    
    cpu.mmu[0xCAFD].should == 0xAB
    cpu.hl.should == 0xCAFE
    cpu.a.should == 0xAB
    cpu.pc.should == 0x0001
    cpu.clock.should == 2
  end
  
  it "must have a LDI A,(HL) operation with opcode 0x32 that loads the memory pointed by HL into the A register, and then increments HL" do
    cpu = CPU.new(h:0xCA, l:0xFD)
    
    cpu.mmu[0xCAFD] = 0xAB
    cpu.load_with(0x2A).step

    [:b, :f, :b, :c, :d, :e, :sp].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end
    
    cpu.mmu[0xCAFD].should == 0xAB
    cpu.hl.should == 0xCAFE
    cpu.a.should == 0xAB
    cpu.pc.should == 0x0001
    cpu.clock.should == 2
  end
  
  it "must have a LDD (HL),A operation with opcode 0x2A that loads the A register into the memory pointed by HL, and then decrements HL" do
    cpu = CPU.new(a:0xAB, h:0xCA, l:0xFF)
    
    cpu.load_with(0x32).step

    [:b, :f, :b, :c, :d, :e, :sp].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end
    
    cpu.mmu[0xCAFF].should == 0xAB
    cpu.hl.should == 0xCAFE
    cpu.a.should == 0xAB
    cpu.pc.should == 0x0001
    cpu.clock.should == 2
  end
  
  it "must have a LDD A,(HL) operation with opcode 0x3A that loads the memory pointed by HL into the A register, and then decrements HL" do
    cpu = CPU.new(h:0xCA, l:0xFF)
    
    cpu.mmu[0xCAFF] = 0xAB
    cpu.load_with(0x3A).step

    [:b, :f, :b, :c, :d, :e, :sp].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end
    
    cpu.mmu[0xCAFF].should == 0xAB
    cpu.hl.should == 0xCAFE
    cpu.a.should == 0xAB
    cpu.pc.should == 0x0001
    cpu.clock.should == 2
  end
  
  it "must have a LD (HL),n operation with opcode 0x36 that loads a 8 bit number into the memory pointed by HL" do
    cpu = CPU.new(h:0xCA, l:0xFE)

    cpu.load_with(0x36, 0xAB).step

    [:a, :f, :b, :c, :d, :e, :sp].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end

    cpu.mmu[0xCAFE].should == 0xAB
    cpu.hl.should == 0xCAFE
    cpu.pc.should == 0x0002
    cpu.clock.should == 3
  end
  
  describe "CPL" do
    it "must set the A register into its complement" do
      cpu = CPU.new(a:0b1010_1010)

      cpu.load_with(0x2F).step

      [:b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end

      cpu.a.should == 0b0101_0101
      cpu.z_flag.should be_false
      cpu.n_flag.should be_true
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should not affect the Z and C flags, and set N and H flags" do
      cpu = CPU.new(a:0b1010_1010, f:0b1001_0000)

      cpu.load_with(0x2F).step

      [:b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end

      cpu.a.should == 0b0101_0101
      cpu.z_flag.should be_true
      cpu.n_flag.should be_true
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
  end
  
  describe "CCF" do
    it "must set the C flag if its not" do
      cpu = CPU.new(f:0b0000_0000)

      cpu.load_with(0x3F).step

      [:a, :b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "must reset the C flag if its set" do
      cpu = CPU.new(f:0b0001_0000)

      cpu.load_with(0x3F).step

      [:a, :b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end

      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should not affect the Z flag, and reset N and H flags" do
      cpu = CPU.new(f:0b1110_0000)

      cpu.load_with(0x3F).step

      [:a, :b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end

      cpu.z_flag.should be_true
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
  end
  
  describe "SCF" do
    it "must set the C flag" do
      cpu = CPU.new(f:0b0000_0000)

      cpu.load_with(0x37).step

      [:a, :b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end

      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end

    it "should not affect the Z flag, and reset N and H flags" do
      cpu = CPU.new(f:0b1111_0000)

      cpu.load_with(0x37).step

      [:a, :b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end

      cpu.z_flag.should be_true
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
  end
  
  describe "ADD A,R operations" do
    it "must be 7" do
      cpu = CPU.new
      
      opcodes = [0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x87]
      
      [:add_a_b, :add_a_c, :add_a_d, :add_a_e, :add_a_h, :add_a_l, :add_a_a].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
    
    it "must add a register to the A register" do
      cpu = CPU.new(b:0xAC)
      
      cpu.load_with(0x80).step
      
      [:f, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0xAC
      cpu.b.should == 0xAC
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should set H flag if current value is of the form 0xnF and the value to add is not of the form 0xn0" do
      cpu = CPU.new(a:0x1F, b:0x01)
      
      cpu.load_with(0x80).step
      
      [:c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x20
      cpu.b.should == 0x01
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should not set H flag if current value is of the form 0xnF and the value to add is of the form 0xn0" do
      cpu = CPU.new(a:0x1F, b:0x10)
      
      cpu.load_with(0x80).step
      
      [:c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x2F
      cpu.b.should == 0x10
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should set H and C flags if sum overflows" do
      cpu = CPU.new(a:0xFF, b:0x02)

      cpu.load_with(0x80).step
      
      [:c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x01
      cpu.b.should == 0x02
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "must set the Z flag if the result is 0" do
      cpu = CPU.new(a:0xFF, b:0x01)

      cpu.load_with(0x80).step
      
      [:c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x00
      cpu.b.should == 0x01
      cpu.z_flag.should be_true
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
  end
  
  describe "ADD A,(HL)" do
    it "must add the memory pointed by the HL register to the A register" do
      cpu = CPU.new(h:0xCA, l:0xFE)
      
      cpu.mmu[0xCAFE] = 0xAC
      cpu.load_with(0x86).step
      
      [:f, :b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0xAC
      cpu.mmu[0xCAFE].should == 0xAC
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should set H flag if current value is of the form 0xnF and the value to add is not of the form 0xn0" do
      cpu = CPU.new(a:0x1F, h:0xCA, l:0xFE)
      
      cpu.mmu[0xCAFE] = 0x01
      cpu.load_with(0x86).step
      
      [:b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x20
      cpu.mmu[0xCAFE].should == 0x01
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should not set H flag if current value is of the form 0xnF and the value to add is of the form 0xn0" do
      cpu = CPU.new(a:0x1F, h:0xCA, l:0xFE)
      
      cpu.mmu[0xCAFE] = 0x10
      cpu.load_with(0x86).step
      
      [:b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x2F
      cpu.mmu[0xCAFE].should == 0x10
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should set H and C flags if sum overflows" do
      cpu = CPU.new(a:0xFF, h:0xCA, l:0xFE)
      
      cpu.mmu[0xCAFE] = 0x02
      cpu.load_with(0x86).step
      
      [:b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x01
      cpu.mmu[0xCAFE].should == 0x02
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "must set the Z flag if the result is 0" do
      cpu = CPU.new(a:0xFF, h:0xCA, l:0xFE)
      
      cpu.mmu[0xCAFE] = 0x01
      cpu.load_with(0x86).step
      
      [:b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x00
      cpu.mmu[0xCAFE].should == 0x01
      cpu.z_flag.should be_true
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
  end
  
  describe "ADD A,n" do
    it "must add a 8 bit number to the A register" do
      cpu = CPU.new()
      
      cpu.load_with(0xC6, 0xAC).step
      
      [:f, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0xAC
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0002
      cpu.clock.should == 2
    end
    
    it "should set H flag if current value is of the form 0xnF and the value to add is not of the form 0xn0" do
      cpu = CPU.new(a:0x1F)
      
      cpu.load_with(0xC6, 0x01).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x20
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0002
      cpu.clock.should == 2
    end
    
    it "should not set H flag if current value is of the form 0xnF and the value to add is of the form 0xn0" do
      cpu = CPU.new(a:0x1F)

      cpu.load_with(0xC6, 0x10).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x2F
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0002
      cpu.clock.should == 2
    end
    
    it "should set H and C flags if sum overflows" do
      cpu = CPU.new(a:0xFF)
      
      cpu.load_with(0xC6, 0x02).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x01
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0002
      cpu.clock.should == 2
    end
    
    it "must set the Z flag if the result is 0" do
      cpu = CPU.new(a:0xFF)
      
      cpu.load_with(0xC6, 0x01).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x00
      cpu.z_flag.should be_true
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0002
      cpu.clock.should == 2
    end
  end
  
  describe "ADC A,R operations" do
    it "must be 7" do
      cpu = CPU.new
      
      opcodes = [0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8F]
      
      [:adc_a_b, :adc_a_c, :adc_a_d, :adc_a_e, :adc_a_h, :adc_a_l, :adc_a_a].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
    
    it "must add a register and the carry flag to the A register" do
      cpu = CPU.new(b:0xAB, f:CPU::C_FLAG)
      
      cpu.load_with(0x88).step
      
      [:f, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0xAC
      cpu.b.should == 0xAB
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should set H flag if current value is of the form 0xnF and the value to add is not of the form 0xn0" do
      cpu = CPU.new(a:0x1F, f:CPU::C_FLAG)
      
      cpu.load_with(0x88).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x20
      cpu.b.should == 0x00
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should not set H flag if current value is of the form 0xnF and the value to add is of the form 0xn0" do
      cpu = CPU.new(a:0x1F, b:0x0F, f:CPU::C_FLAG)
      
      cpu.load_with(0x88).step
      
      [:c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x2F
      cpu.b.should == 0x0F
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should set H and C flags if sum overflows" do
      cpu = CPU.new(a:0xFF, b:0x01, f:CPU::C_FLAG)

      cpu.load_with(0x88).step
      
      [:c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x01
      cpu.b.should == 0x01
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "must set the Z flag if the result is 0" do
      cpu = CPU.new(a:0xFF, f:CPU::C_FLAG)

      cpu.load_with(0x88).step
      
      [:c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x00
      cpu.b.should == 0x00
      cpu.z_flag.should be_true
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
  end
  
  describe "ADC A,(HL)" do
    it "must add the memory pointed by the HL register and the C (carry) flag to the A register" do
      cpu = CPU.new(h:0xCA, l:0xFE, f:CPU::C_FLAG)
      
      cpu.mmu[0xCAFE] = 0xAB
      cpu.load_with(0x8E).step
      
      [:f, :b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0xAC
      cpu.mmu[0xCAFE].should == 0xAB
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should set H flag if current value is of the form 0xnF and the value to add is not of the form 0xn0" do
      cpu = CPU.new(a:0x1F, h:0xCA, l:0xFE, f:CPU::C_FLAG)
      
      cpu.mmu[0xCAFE] = 0x00
      cpu.load_with(0x8E).step
      
      [:b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x20
      cpu.mmu[0xCAFE].should == 0x00
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should not set H flag if current value is of the form 0xnF and the value to add is of the form 0xn0" do
      cpu = CPU.new(a:0x1F, h:0xCA, l:0xFE, f:CPU::C_FLAG)
      
      cpu.mmu[0xCAFE] = 0x0F
      cpu.load_with(0x8E).step
      
      [:b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x2F
      cpu.mmu[0xCAFE].should == 0x0F
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should set H and C flags if sum overflows" do
      cpu = CPU.new(a:0xFF, h:0xCA, l:0xFE, f:CPU::C_FLAG)
      
      cpu.mmu[0xCAFE] = 0x01
      cpu.load_with(0x8E).step
      
      [:b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x01
      cpu.mmu[0xCAFE].should == 0x01
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "must set the Z flag if the result is 0" do
      cpu = CPU.new(a:0xFF, h:0xCA, l:0xFE, f:CPU::C_FLAG)
      
      cpu.mmu[0xCAFE] = 0x00
      cpu.load_with(0x8E).step
      
      [:b, :c, :d, :e, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x00
      cpu.mmu[0xCAFE].should == 0x00
      cpu.z_flag.should be_true
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
  end
  
  describe "ADC A,n" do
    it "must add a 8 bit value and the C (carry) flag to the A register" do
      cpu = CPU.new(f:CPU::C_FLAG)
      
      cpu.load_with(0xCE, 0xAB).step
      
      [:f, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0xAC
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0002
      cpu.clock.should == 2
    end
    
    it "should set H flag if current value is of the form 0xnF and the value to add is not of the form 0xn0" do
      cpu = CPU.new(a:0x1F, f:CPU::C_FLAG)
      
      cpu.load_with(0xCE, 0x00).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x20
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0002
      cpu.clock.should == 2
    end
    
    it "should not set H flag if current value is of the form 0xnF and the value to add is of the form 0xn0" do
      cpu = CPU.new(a:0x1F, f:CPU::C_FLAG)
      
      cpu.load_with(0xCE, 0x0F).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x2F
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_false
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0002
      cpu.clock.should == 2
    end
    
    it "should set H and C flags if sum overflows" do
      cpu = CPU.new(a:0xFF, f:CPU::C_FLAG)
      
      cpu.load_with(0xCE, 0x01).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x01
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0002
      cpu.clock.should == 2
    end
    
    it "must set the Z flag if the result is 0" do
      cpu = CPU.new(a:0xFF, f:CPU::C_FLAG)
      
      cpu.load_with(0xCE, 0x00).step
      
      [:b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0x00
      cpu.z_flag.should be_true
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_true
      cpu.pc.should == 0x0002
      cpu.clock.should == 2
    end
  end
  
  describe "AND R operations" do
    it "must be 7" do
      cpu = CPU.new
      
      opcodes = [0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA7]
      
      [:and_b, :and_c, :and_d, :and_e, :and_h, :and_l, :and_a].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
    
    it "should do a logical and between A and a 8 bits register and set the result in A" do
      cpu = CPU.new(a:0b1111_0000, b:0b1010_1010)
      
      cpu.load_with(0xA0).step
      
      [:c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.a.should == 0b1010_0000
      cpu.b.should == 0b1010_1010
      cpu.z_flag.should be_false
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end
    
    it "should set the Z flag it the result is 0x00" do
      cpu = CPU.new(a:0b0101_0101, b:0b1010_1010)

      cpu.load_with(0xA0).step

      [:c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end

      cpu.a.should == 0b0000_0000
      cpu.b.should == 0b1010_1010
      cpu.z_flag.should be_true
      cpu.n_flag.should be_false
      cpu.h_flag.should be_true
      cpu.c_flag.should be_false
      cpu.pc.should == 0x0001
      cpu.clock.should == 1
    end  
  end
end