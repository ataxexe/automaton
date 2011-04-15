require 'automaton'
require 'builder'

require "#{File.dirname(__FILE__)}/test_helper"

class DFA < Test::Unit::TestCase

  def setup
    @fa1 = Automaton.new :initial_state => 1, :final_states => [2]

    @fa1.connect 1, :to => 1, :when => 0
    @fa1.connect 1, :to => 2, :when => 1

    @fa1.connect 2, :to => 3, :when => 0
    @fa1.connect 2, :to => 2, :when => 1

    @fa1.connect 3, :to => 2, :when => 0
    @fa1.connect 3, :to => 2, :when => 1


    alphabet = ('a'..'c').to_a
    @fa2 = Automaton::new :initial_state => 1, :final_states => [10], :connections =>
      { #pre = bca
        1 => {2 => 'b'},
        2 => {3 => 'c'},
        3 => {4 => 'a'},
        #sub = cbb
        4 => {4 => alphabet - ['c'],
              5 => 'c'},
        5 => {4 => 'a',
              6 => 'b',
              5 => 'c'},
        6 => {4 => alphabet - ['b'],
              7 => 'b'},
        #suf = aab
        7 => {7 => alphabet - ['a'],
              8 => 'a'},
        8 => {7 => alphabet - ['a'],
              9 => 'a'},
        9 => {7 => 'c',
              9 => 'a',
              10 => 'b'},
        10 => {8 => 'a',
               7 => alphabet - ['a']}
      }


    @fa3 = Automaton::new :initial_state => 1, :final_states => [9], :connections =>
      { #pre = xx
        1 => {2 => 'x'},
        2 => {3 => 'x'},
        #sub = yzy
        3 => {3 => ['x','z'],
              4 => 'y'},
        4 => {4 => 'y',
              3 => 'x',
              5 => 'z'},
        5 => {3 => ['x','z'],
              7 => 'y'},
        #suf = yxz
        6 => {6 => ['x','z'],
              7 => 'y'},
        7 => {6 => 'z',
              8 => 'x'},
        8 => {7 => 'y',
              6 => 'x',
              9 => 'z'},
        9 => {6 => ['x','z'],
              7 => 'y'}
      }


    jflap = read_test_file 'dfa_with_context.jff'
    @fa4 = Automaton::from_jflap jflap, {:alphabet => ('a'..'z').to_a}

    @fa5 = Automaton::from_jflap read_test_file('dfa.jff')
  end

  def test_acceptance
    assert_accept @fa1, 1101, "00111010011"
    assert_reject @fa1, "0110", "01000"

    assert_accept @fa2, 'bcacbbaab', 'bcaaabcbbbaabcaab', 'bcacbbacbabcaab', 'bcaacbaccbbaab'
    assert_reject @fa2, 'bcacbabaab', 'abcaaabcbbbaabcaab', 'bcacbbacbabcaabc', 'bcaacbaccbabaab',
                  'bcaacgbaccbabaab', 'bcaacbaccxbabaab'

    assert_accept @fa3, "xxyyzyxz","xxzzyxzyzyxxyzxyxz","xxyzyxz","xxxyxxzxzyzyxzzxyxz"
    assert_reject @fa3, "xyxyyzyxz","xxzzyxzyzyxxyzxxz","xxyzyxxz","xxxyxxzxzyzyxzzxyxzz"

    assert_accept @fa4, '','jfx','zxx','xxx','jfxzxxxxx'
    assert_reject @fa4, 'aax','xbx','abc'

    assert_accept @fa5, 'acz', 'bcz', 'ccz', 'dab'
    assert_reject @fa5, 'aczz', 'bczz', 'czzz', 'dabb', 'ACZ', 'ac', 'cc'
  end

  def test_jflap_output
    jflap = @fa5.to_jflap
    fa6 = Automaton::from_jflap jflap

    assert_accept fa6, 'acz', 'bcz', 'ccz', 'dab'
    assert_reject fa6, 'aczz', 'bczz', 'czzz', 'dabb', 'ACZ', 'ac', 'cc'
  end

end

class NFA_JFLAP < Test::Unit::TestCase

  def setup
    @fa = Automaton::from_jflap read_test_file('nfa.jff')
  end

  def test_acceptance
    assert_accept @fa, 'abcbbaa','abccbcbcbaa','cacbbaa','abcccccccbbbbaa'
    assert_reject @fa, 'abcbbbcaa','cacbcba','abcabcbabacabbcabbba'
  end
end

class NFAe_JFLAP < Test::Unit::TestCase

  def setup
    @fa1 = Automaton::from_jflap read_test_file('nfae.jff')
    @fa2 = Automaton::from_jflap read_test_file('nfae2.jff')
  end

  def test_acceptance
    assert_accept @fa1, 'wzwzxyy','xywxyyxwyxywxyxyy','wzwwzxwz'
    assert_reject @fa1, 'wzwzzxyy','xywxyzzxywwz'

    assert_accept @fa2, '', 'a', 'b', 'ab', 'aaab', 'abbb', 'aaabbb', 'bbbb'
    assert_reject @fa2, 'aba', 'aaaba', 'bbbaaa', 'ba'
  end

end
