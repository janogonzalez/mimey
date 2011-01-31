require 'rspec'
require 'janogb'

describe "CPU jump operations" do
  include JanoGB
  
  describe "JR n" do
    it "should add n to current address and jump to it" do
      cpu = CPU.new(pc:0x02)
      
      cpu.load_with(0x00, 0x00, 0x18, 0b0000_0010).step
      
      [:a, :f, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.pc.should == 0x05
      cpu.clock.should == 3
    end
    
    it "should jump back if n is negative" do
      cpu = CPU.new(pc:0x02)
      
      cpu.load_with(0x00, 0x00, 0x18, 0b1111_1101).step
      
      [:a, :f, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.pc.should == 0x00
      cpu.clock.should == 3
    end
  end
  
  describe "JR cc,n" do
    it "should be 4" do
      cpu = CPU.new
      
      opcodes = [0x20, 0x28, 0x30, 0x38]
      
      [:jr_nz_n, :jr_z_n, :jr_nc_n, :jr_c_n].each_with_index do |m, i|
        cpu.should respond_to m
        opcode = opcodes[i]
        CPU::OPERATIONS[opcode].should == m
      end
    end
    
    it "should add n to current address and jump to it if the flag is set and cc is set" do
      cpu = CPU.new(pc:0x02, f:CPU::Z_FLAG)
      
      cpu.load_with(0x00, 0x00, 0x28, 0b0000_0010).step
      
      [:a, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.pc.should == 0x05
      cpu.z_flag.should be_true
      cpu.clock.should == 3
    end
    
    it "should add n to current address and jump to it if the flag is unset and cc is unset" do
      cpu = CPU.new(pc:0x02)
      
      cpu.load_with(0x00, 0x00, 0x20, 0b0000_0010).step
      
      [:a, :f, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.pc.should == 0x05
      cpu.z_flag.should be_false
      cpu.clock.should == 3
    end
    
    it "should continue if the flag is set and cc is unset" do
      cpu = CPU.new(pc:0x02)
      
      cpu.load_with(0x00, 0x00, 0x28, 0b0000_0010).step
      
      [:a, :f, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.pc.should == 0x04
      cpu.clock.should == 2
    end
    
    it "should continue if the flag is unset and cc is set" do
      cpu = CPU.new(pc:0x02, f:CPU::Z_FLAG)
      
      cpu.load_with(0x00, 0x00, 0x20, 0b0000_0010).step
      
      [:a, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.pc.should == 0x04
      cpu.z_flag.should be_true
      cpu.clock.should == 2
    end
    
    it "should jump back if n is negative and the flag is set and cc is set" do
      cpu = CPU.new(pc:0x02, f:CPU::Z_FLAG)
      
      cpu.load_with(0x00, 0x00, 0x28, 0b1111_1101).step
      
      [:a, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.pc.should == 0x00
      cpu.z_flag.should be_true
      cpu.clock.should == 3
    end
    
    it "should jump back if n is negative and the flag is unset and cc is unset" do
      cpu = CPU.new(pc:0x02)
      
      cpu.load_with(0x00, 0x00, 0x20, 0b1111_1101).step
      
      [:a, :f, :b, :c, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.pc.should == 0x00
      cpu.clock.should == 3
    end
  end
end
