JanoGB
========
A Nintendo Game Boy emulator inspired by the work of [Imran Nazar](http://imrannazar.com/GameBoy-Emulation-in-JavaScript).

Status
------

At the moment JanoGB is in a very early stage, it emulates only a half of the CPU opcodes.

Development
-----------

1. If you use RVM, create a gemset with a `.rvmrc` file and use it

        rvm use 1.9.2
        rvm --create --rvmrc 1.9.2@janogb
        rvm gemset use janogb

2. Install bundler and install the gems

        gem install bundler
        bundle

3. Run the automated test suite

        watchr specs.watchr.rb
    
4. Develop!
