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

    it "should have its clock in 0" do
      cpu = CPU.new()

      cpu.clock.should == 0
    end
  end

  describe "16 bits 'virtual' registers" do
    it "should get the 'virtual' AF register based on registers A and F" do
      cpu = CPU.new(a: 0xAB, f: 0xCD)

      cpu.af.should == 0xABCD
    end

    it "should set the 'virtual' AF register based on registers A and F" do
      cpu = CPU.new

      cpu.af = 0xABCD

      cpu.a.should == 0xAB
      cpu.f.should == 0xCD
    end

    it "should get the 'virtual' BC register based on registers B and C" do
      cpu = CPU.new(b: 0xAB, c: 0xCD)

      cpu.bc.should == 0xABCD
    end

    it "should set the 'virtual' BC register based on registers C and B" do
      cpu = CPU.new

      cpu.bc = 0xABCD

      cpu.b.should == 0xAB
      cpu.c.should == 0xCD
    end

    it "should get the 'virtual' DE register based on registers D and E" do
      cpu = CPU.new(d: 0xAB, e: 0xCD)

      cpu.de.should == 0xABCD
    end

    it "should set the 'virtual' DE register based on registers D and E" do
      cpu = CPU.new

      cpu.de = 0xABCD

      cpu.d.should == 0xAB
      cpu.e.should == 0xCD
    end

    it "should get the 'virtual' HL register based on registers H and L" do
      cpu = CPU.new(h: 0xAB, l: 0xCD)

      cpu.hl.should == 0xABCD
    end

    it "should set the 'virtual' HL register based on registers H and L" do
      cpu = CPU.new

      cpu.hl = 0xABCD

      cpu.h.should == 0xAB
      cpu.l.should == 0xCD
    end
  end

  describe "Flags from F register" do
    describe "Z flag" do
      it "should be false when its off" do
        cpu = CPU.new(f: 0b0111_0000)

        cpu.z_flag.should be_false
      end

      it "should be true when its on" do
        cpu = CPU.new(f: 0b1000_0000)

        cpu.z_flag.should be_true
      end
    end

    describe "N flag" do
      it "should be false when its off" do
        cpu = CPU.new(f: 0b1011_0000)

        cpu.n_flag.should be_false
      end

      it "should be true when its on" do
        cpu = CPU.new(f: 0b0100_0000)

        cpu.n_flag.should be_true
      end
    end

    describe "H flag" do
      it "should be false when its off" do
        cpu = CPU.new(f: 0b1101_0000)

        cpu.h_flag.should be_false
      end

      it "should be true when its on" do
        cpu = CPU.new(f: 0b0010_0000)

        cpu.h_flag.should be_true
      end
    end

    describe "C flag" do
      it "should be false when its off" do
        cpu = CPU.new(f: 0b1110_0000)

        cpu.c_flag.should be_false
      end

      it "should be true when its on" do
        cpu = CPU.new(f: 0b0001_0000)

        cpu.c_flag.should be_true
      end
    end
  end

  it "should be able to read the next byte from memory and increment the program counter" do
    cpu = CPU.new

    cpu.load_with(0xAB)

    cpu.next_byte.should == 0xAB
    cpu.pc.should == 1
  end

  it "should be able to read the next word from memory and increment the program counter" do
    cpu = CPU.new

    cpu.load_with(0xAB, 0xCD)

    cpu.next_word.should == 0xABCD
    cpu.pc.should == 2
  end
end
