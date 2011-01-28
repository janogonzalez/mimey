require 'rspec'
require 'janogb'

describe "CPU operations" do
  include JanoGB
  
  it "should have a NOP operation with opcode 0x00 that does nothing" do
    cpu = CPU.new
    
    cpu.load_with(0x00).run(1)

    [:a, :f, :b, :c, :d, :e, :h, :l, :sp].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end
    
    cpu.pc.should == 0x0001
    cpu.clock.should == 1
  end
  
  it "should have LD RR,nn operations that load a 16 bit value into a 16 bit register" do
    cpu = CPU.new
    
    cpu.load_with(0x01, 0xAB, 0xCD).run(1)
    
    [:a, :f, :d, :e, :h, :l, :sp].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end
    
    cpu.bc.should == 0xABCD
    cpu.pc.should == 0x0003
    cpu.clock.should == 3
  end
  
  it "should have LD (RR),A operations that load the A register into the memory at address pointed by register RR" do
    cpu = CPU.new(a:0xAB, b: 0xCA, c:0xFE)
    
    cpu.load_with(0x02).run(1)
    
    [:f, :d, :e, :h, :l, :sp].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end
    
    cpu.mmu[0xCAFE] = 0xAB
    cpu.pc.should == 0x0001
    cpu.clock.should == 2
  end
    
end