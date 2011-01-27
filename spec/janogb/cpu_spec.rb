require 'rspec'
require 'janogb'

describe "CPU" do
  include JanoGB
  
  describe "A new CPU" do
    it "should have all registers in 0 if no options where provided" do
      cpu = CPU.new
      
      [:a, :f, :b, :c, :d, :e, :h, :l, :pc, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
    end
    
    it "should initialize all registers with the options values" do
      options = {
        a: 0x0A,
        f: 0x0F,
        b: 0x0B,
        c: 0x0C,
        d: 0x0D,
        e: 0x0E,
        h: 0x11,
        l: 0x15,
        pc: 0xCAFE,
        sp: 0xFEA0
      }
      
      cpu = CPU.new(options)

      [:a, :f, :b, :c, :d, :e, :h, :l, :pc, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == options[r]
      end
    end
  end
  
  describe "16 bits 'virtual' registers" do
    it "should get the 'virtual' AF register based on registers A and F" do
      cpu = CPU.new(a: 0xAB, f: 0xCD)
      
      cpu.af.should == 0xABCD
    end
    
    it "should get the 'virtual' BC register based on registers B and C" do
      cpu = CPU.new(b: 0xAB, c: 0xCD)
      
      cpu.bc.should == 0xABCD
    end
    
    it "should get the 'virtual' DE register based on registers D and E" do
      cpu = CPU.new(d: 0xAB, e: 0xCD)
      
      cpu.de.should == 0xABCD
    end
    
    it "should get the 'virtual' HL register based on registers H and L" do
      cpu = CPU.new(h: 0xAB, l: 0xCD)
      
      cpu.hl.should == 0xABCD
    end
  end
end