require 'rspec'
require 'mimey'

describe "CPU bit operations" do
  include Mimey

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
end
