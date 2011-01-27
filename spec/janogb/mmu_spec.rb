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
end