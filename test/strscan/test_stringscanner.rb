#
# test/strscan/test_stringscanner.rb
#

require 'test/unit/testsuite'
require 'test/unit/testcase'
require 'strscan'


class TestStringScanner < Test::Unit::TestCase

  def test_s_new
    s = StringScanner.new('test string')
    assert_instance_of StringScanner, s
    assert_equal false, s.eos?
    assert_equal true, s.string.frozen?
    assert_equal false, s.tainted?

    str = 'test string'
    str.taint
    s = StringScanner.new(str, false)
    assert_instance_of StringScanner, s
    assert_equal false, s.eos?
    assert_same str, s.string
    assert_equal true, s.string.frozen?
    assert_equal true, s.string.tainted?

    str = 'test string'
    str.taint
    s = StringScanner.new(str)
    assert_equal true, s.string.tainted?
  end

if VERSION >= '1.7.0'
  UNINIT_ERROR = ArgumentError
  def test_s_allocate
    s = StringScanner.allocate
    assert_equal '#<StringScanner (uninitialized)>', s.inspect.sub(/StringScanner_C/, 'StringScanner')
    assert_raises(UNINIT_ERROR) { s.eos? }
    assert_raises(UNINIT_ERROR) { s.scan(/a/) }
    s.string = 'test'
    assert_equal '#<StringScanner 0/4 @ "test">', s.inspect.sub(/StringScanner_C/, 'StringScanner')
    assert_nothing_raised(UNINIT_ERROR) { s.eos? }
    assert_equal false, s.eos?
  end
end

  def test_s_mustc
    assert_nothing_raised(NotImplementedError) {
        StringScanner.must_C_version
    }
  end

  def test_const_Version
    assert_instance_of String, StringScanner::Version
    assert_equal true, StringScanner::Version.frozen?
  end

  def test_const_Id
    assert_instance_of String, StringScanner::Id
    assert_equal true, StringScanner::Id.frozen?
  end

  def test_inspect
    str = 'test string'
    str.taint
    s = StringScanner.new(str, false)
    assert_instance_of String, s.inspect
    assert_equal s.inspect, s.inspect
    assert_equal '#<StringScanner 0/11 @ "test ...">', s.inspect.sub(/StringScanner_C/, 'StringScanner')
    s.get_byte
    assert_equal '#<StringScanner 1/11 "t" @ "est s...">', s.inspect.sub(/StringScanner_C/, 'StringScanner')
    assert_equal true, s.inspect.tainted?
  end

  def test_eos?
    s = StringScanner.new('test string')
    assert_equal false, s.eos?
    assert_equal false, s.eos?
    s.scan(/\w+/)
    assert_equal false, s.eos?
    assert_equal false, s.eos?
    s.scan(/\s+/)
    s.scan(/\w+/)
    assert_equal true, s.eos?
    assert_equal true, s.eos?
    s.scan(/\w+/)
    assert_equal true, s.eos?
  end

  def test_pos
    s = StringScanner.new('test string')
    assert_equal 0, s.pos
    s.get_byte
    assert_equal 1, s.pos
    s.get_byte
    assert_equal 2, s.pos
    s.terminate
    assert_equal 11, s.pos
  end

  def test_scan
    s = StringScanner.new('stra strb strc', true)
    tmp = s.scan(/\w+/)
    assert_equal 'stra', tmp
    assert_equal false, tmp.tainted?

    tmp = s.scan(/\s+/)
    assert_equal ' ', tmp
    assert_equal false, tmp.tainted?

    assert_equal 'strb', s.scan(/\w+/)
    assert_equal ' ',    s.scan(/\s+/)

    tmp = s.scan(/\w+/)
    assert_equal 'strc', tmp
    assert_equal false, tmp.tainted?

    assert_nil           s.scan(/\w+/)
    assert_nil           s.scan(/\w+/)


    str = 'stra strb strc'
    str.taint
    s = StringScanner.new(str, false)
    tmp = s.scan(/\w+/)
    assert_equal 'stra', tmp
    assert_equal true, tmp.tainted?

    tmp = s.scan(/\s+/)
    assert_equal ' ', tmp
    assert_equal true, tmp.tainted?

    assert_equal 'strb', s.scan(/\w+/)
    assert_equal ' ',    s.scan(/\s+/)

    tmp = s.scan(/\w+/)
    assert_equal 'strc', tmp
    assert_equal true, tmp.tainted?

    assert_nil           s.scan(/\w+/)
    assert_nil           s.scan(/\w+/)
  end

  def test_skip
    s = StringScanner.new('stra strb strc', true)
    assert_equal 4, s.skip(/\w+/)
    assert_equal 1, s.skip(/\s+/)
    assert_equal 4, s.skip(/\w+/)
    assert_equal 1, s.skip(/\s+/)
    assert_equal 4, s.skip(/\w+/)
    assert_nil      s.skip(/\w+/)
    assert_nil      s.skip(/\s+/)
    assert_equal true, s.eos?
  end

  def test_getch
    s = StringScanner.new('abcde')
    assert_equal 'a', s.getch
    assert_equal 'b', s.getch
    assert_equal 'c', s.getch
    assert_equal 'd', s.getch
    assert_equal 'e', s.getch
    assert_nil        s.getch

    str = 'abc'
    str.taint
    s = StringScanner.new(str)
    assert_equal true, s.getch.tainted?
    assert_equal true, s.getch.tainted?
    assert_equal true, s.getch.tainted?
    assert_nil s.getch

    $KCODE = 'EUC'
    s = StringScanner.new("\244\242")
    assert_equal "\244\242", s.getch
    assert_nil s.getch
    $KCODE = 'NONE'
  end

  def test_get_byte
    s = StringScanner.new('abcde')
    assert_equal 'a', s.get_byte
    assert_equal 'b', s.get_byte
    assert_equal 'c', s.get_byte
    assert_equal 'd', s.get_byte
    assert_equal 'e', s.get_byte
    assert_nil        s.get_byte
    assert_nil        s.get_byte

    str = 'abc'
    str.taint
    s = StringScanner.new(str)
    assert_equal true, s.get_byte.tainted?
    assert_equal true, s.get_byte.tainted?
    assert_equal true, s.get_byte.tainted?
    assert_nil s.get_byte

    $KCODE = 'EUC'
    s = StringScanner.new("\244\242")
    assert_equal "\244", s.get_byte
    assert_equal "\242", s.get_byte
    assert_nil s.get_byte
    $KCODE = 'NONE'
  end

  def test_matched
    s = StringScanner.new('stra strb strc')
    s.scan(/\w+/)
    assert_equal 'stra', s.matched
    assert_equal false, s.matched.tainted?
    s.scan(/\s+/)
    assert_equal ' ', s.matched
    s.scan(/\w+/)
    assert_equal 'strb', s.matched
    s.scan(/\s+/)
    assert_equal ' ', s.matched
    s.scan(/\w+/)
    assert_equal 'strc', s.matched
    s.scan(/\w+/)
    assert_nil s.matched
    s.getch
    assert_nil s.matched

    s = StringScanner.new('stra strb strc')
    s.getch
    assert_equal 's', s.matched
    assert_equal false, s.matched.tainted?
    s.get_byte
    assert_equal 't', s.matched
    assert_equal 't', s.matched
    assert_equal false, s.matched.tainted?

    str = 'test'
    str.taint
    s = StringScanner.new(str)
    s.scan(/\w+/)
    assert_equal true, s.matched.tainted?
    assert_equal true, s.matched.tainted?
  end

  def test_AREF
    s = StringScanner.new('stra strb strc')

    s.scan(/\w+/)
    assert_nil           s[-2]
    assert_equal 'stra', s[-1]
    assert_equal 'stra', s[0]
    assert_nil           s[1]

    assert_equal false,  s[-1].tainted?
    assert_equal false,  s[0].tainted?

    s.skip(/\s+/)
    assert_nil           s[-2]
    assert_equal ' ',    s[-1]
    assert_equal ' ',    s[0]
    assert_nil           s[1]

    s.scan(/(s)t(r)b/)
    assert_nil           s[-100]
    assert_nil           s[-4]
    assert_equal 'strb', s[-3]
    assert_equal 's',    s[-2]
    assert_equal 'r',    s[-1]
    assert_equal 'strb', s[0]
    assert_equal 's',    s[1]
    assert_equal 'r',    s[2]
    assert_nil           s[3]
    assert_nil           s[100]

    s.scan(/\s+/)

    s.getch
    assert_nil           s[-2]
    assert_equal 's',    s[-1]
    assert_equal 's',    s[0]
    assert_nil           s[1]

    s.get_byte
    assert_nil           s[-2]
    assert_equal 't',    s[-1]
    assert_equal 't',    s[0]
    assert_nil           s[1]

    s.scan(/.*/)
    s.scan(/./)
    assert_nil           s[0]
    assert_nil           s[0]


    $KCODE = 'EUC'
    s = StringScanner.new("\244\242")
    s.getch
    assert_equal "\244\242", s[0]
    $KCODE = 'NONE'


    str = 'test'
    str.taint
    s = StringScanner.new(str)
    s.scan(/(t)(e)(s)(t)/)
    assert_equal true, s[0].tainted?
    assert_equal true, s[1].tainted?
    assert_equal true, s[2].tainted?
    assert_equal true, s[3].tainted?
    assert_equal true, s[4].tainted?
  end

  def test_pre_match
    s = StringScanner.new('a b c d e')
    s.scan(/\w/)
    assert_equal '', s.pre_match
    assert_equal false, s.pre_match.tainted?
    s.skip(/\s/)
    assert_equal 'a', s.pre_match
    assert_equal false, s.pre_match.tainted?
    s.scan(/\w/)
    assert_equal 'a ', s.pre_match
    s.scan_until(/c/)
    assert_equal 'a b ', s.pre_match
    s.getch
    assert_equal 'a b c', s.pre_match
    s.get_byte
    assert_equal 'a b c ', s.pre_match
    s.get_byte
    assert_equal 'a b c d', s.pre_match
    s.scan(/never match/)
    assert_nil s.pre_match

    str = 'test string'
    str.taint
    s = StringScanner.new(str)
    s.scan(/\w+/)
    assert_equal true, s.pre_match.tainted?
    s.scan(/\s+/)
    assert_equal true, s.pre_match.tainted?
    s.scan(/\w+/)
    assert_equal true, s.pre_match.tainted?
  end

  def test_post_match
    s = StringScanner.new('a b c d e')
    s.scan(/\w/)
    assert_equal ' b c d e', s.post_match
    s.skip(/\s/)
    assert_equal 'b c d e', s.post_match
    s.scan(/\w/)
    assert_equal ' c d e', s.post_match
    s.scan_until(/c/)
    assert_equal ' d e', s.post_match
    s.getch
    assert_equal 'd e', s.post_match
    s.get_byte
    assert_equal ' e', s.post_match
    s.get_byte
    assert_equal 'e', s.post_match
    s.scan(/never match/)
    assert_nil s.post_match
    s.scan(/./)
    assert_equal '', s.post_match
    s.scan(/./)
    assert_nil s.post_match

    str = 'test string'
    str.taint
    s = StringScanner.new(str)
    s.scan(/\w+/)
    assert_equal true, s.post_match.tainted?
    s.scan(/\s+/)
    assert_equal true, s.post_match.tainted?
    s.scan(/\w+/)
    assert_equal true, s.post_match.tainted?
  end

  def test_terminate
    s = StringScanner.new('ssss')
    s.getch
    s.terminate
    assert_equal true, s.eos?
    s.terminate
    assert_equal true, s.eos?
  end

  def test_reset
    s = StringScanner.new('ssss')
    s.getch
    s.reset
    assert_equal 0, s.pos
    s.scan(/\w+/)
    s.reset
    assert_equal 0, s.pos
    s.reset
    assert_equal 0, s.pos
  end

end


if $0 == __FILE__
  require 'test/unit/ui/console/testrunner'
  Test::Unit::UI::Console::TestRunner.run(TestStringScanner.suite)
end
