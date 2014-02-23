require 'rspec'
require 'janogb'

include JanoGB

DEFAULT_REGISTERS = {
  a: 0x00,
  b: 0x00,
  c: 0x00,
  d: 0x00,
  e: 0x00,
  h: 0x00,
  l: 0x00,
  pc: 0x0000,
  sp: 0x0000
}

DEFAULT_FLAGS = {
  z: false,
  n: false,
  h: false,
  c: false
}

RSpec::Matchers.define :have_only_registers do |registers|
  match do |cpu|
    @matched = {}
    @not_matched = {}

    all_registers = DEFAULT_REGISTERS.merge(registers)

    all_registers.each do |k, v|
      if (cpu.instance_variable_get("@#{k}") == v)
        @matched.merge!(k => v)
      else
        @not_matched.merge!(k => v)
      end
    end

    @not_matched.empty?
  end

  failure_message_for_should do |cpu|
    "expected register values of #{@not_matched.inspect}.\n"
  end

  failure_message_for_should_not do |cpu|
    "not expected register values of #{@matched.inspect}\n"
  end
end

RSpec::Matchers.define :have_only_flags do |*flags|
  match do |cpu|
    @matched = {}
    @not_matched = {}

    flags_with_values = {}

    flags.each do |f|
      flags_with_values.merge!(f => true)
    end

    all_flags = DEFAULT_FLAGS.merge(flags_with_values)

    all_flags.each do |k, v|
      if (cpu.method("#{k}_flag").call == v)
        @matched.merge!(k => v)
      else
        @not_matched.merge!(k => v)
      end
    end

    @not_matched.empty?
  end

  failure_message_for_should do |cpu|
    "expected the following flags #{@not_matched.inspect}.\n"
  end

  failure_message_for_should_not do |cpu|
    "not expected the following flags #{@matched.inspect}\n"
  end
end
