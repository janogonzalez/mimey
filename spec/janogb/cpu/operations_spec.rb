require 'rspec'
require 'janogb'

describe "CPU operations" do
  include JanoGB
  
  it "should have a NOP operation with opcode 0x00 that does nothing" do
    cpu = CPU.new
    
    cpu.run_with(0x00)

    [:a, :f, :b, :c, :d, :e, :h, :l, :sp].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end
    
    cpu.pc.should == 0x0001
    cpu.clock.should == 1
  end
end