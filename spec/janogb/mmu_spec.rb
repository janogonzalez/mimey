require 'rspec'
require 'janogb'

describe "MMU" do
  include JanoGB
  
  it "should be able to write a byte to the internal memory and then read it" do
    mmu = MMU.new
    
    mmu[0xC000] = 0xAB
    mmu[0xDFFF] = 0xCD
    
    mmu[0xC000].should == 0xAB
    mmu[0xDFFF].should == 0xCD
  end
  
  it "should be able to write a byte to the shadow memory and then read it" do
    mmu = MMU.new
    
    mmu[0xE000] = 0xAB
    mmu[0xFDFF] = 0xCD
    
    mmu[0xE000].should == 0xAB
    mmu[0xFDFF].should == 0xCD
  end
  
  it "should be able to write a byte to the internal memory and then read it from the shadow memory" do
    mmu = MMU.new
    
    mmu[0xC000] = 0xAB
    mmu[0xDDFF] = 0xCD
    
    mmu[0xE000].should == 0xAB
    mmu[0xFDFF].should == 0xCD
  end
  
  it "should be able to write a byte to the shadow memory and then read it from the internal memory" do
    mmu = MMU.new
    
    mmu[0xE000] = 0xAB
    mmu[0xFDFF] = 0xCD
    
    mmu[0xC000].should == 0xAB
    mmu[0xDDFF].should == 0xCD
  end
  
  it "should be able to load a ROM and read it" do
    mmu = MMU.new
    mmu.load_rom(0xAB, 0xCD, 0xDE)
    
    mmu[0x00].should == 0xAB
    mmu[0x01].should == 0xCD
    mmu[0x02].should == 0xDE
    mmu[0x03].should be nil
  end
  
  it "should not let a program to modify the ROM" do
    mmu = MMU.new
    mmu.load_rom(0xAB)
    
    mmu[0x00] = 0xCD
    
    mmu[0x00].should == 0xAB
  end
  
  it "should be able to read a word (16 bits)" do
    mmu = MMU.new
    
    mmu[0xC000] = 0xAB
    mmu[0xC001] = 0xCD
    
    mmu.word[0xC000].should == 0xABCD
  end
  
  it "should be able to write a word (16 bits)" do
    mmu = MMU.new
    
    mmu.word[0xC000] = 0xABCD
    
    mmu[0xC000].should == 0xAB
    mmu[0xC001].should == 0xCD
  end
end