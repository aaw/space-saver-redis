require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SpaceSaver do
  it "returns an empty list when you ask about an empty leaderboard" do
    s = SpaceSaver.new(Redis.new, 10)
    s.leaders('unknown-leaderboard').should be_empty
  end
  it "can store different leaderboards in the same Redis database" do
    s = SpaceSaver.new(Redis.new, 10)
    s.increment('a','a_item')
    s.increment('b','b_item')
    s.leaders('a').should == [["a_item", 1.0]]
    s.leaders('b').should == [["b_item", 1.0]]
  end
  it "uses a Redis sorted set of cardinality K if you pass K to the SpaceSaver constructor" do
    r = Redis.new
    [3,4,5].each do |k|
      s = SpaceSaver.new(r, k)
      30.times do |i| 
        s.increment("leaderboard#{k}", "item#{i}")
        r.zcard("leaderboard#{k}").should <= k
      end
      r.zcard("leaderboard#{k}").should == k
    end
  end
  it "can return less than k leaders" do
    s = SpaceSaver.new(Redis.new, 20)
    100.times { |i| s.increment("leaderboard", "item#{i}") }
    [5,6,7,8].each do |i|
      s.leaders("leaderboard", i).length.should == i
      s.leaders("leaderboard", i+1).should include(*s.leaders("leaderboard", i))
    end
  end
  it "stores any element that occurs at least n/k times" do
    s = SpaceSaver.new(Redis.new, 5)
    200.times { s.increment("leaderboard", "foo") }
    400.times do |i| 
      s.increment("leaderboard", "bar") if i % 2 == 0
      s.increment("leaderboard", "item#{i}")
    end
    200.times { s.increment("leaderboard", "baz") }
    expected_leaders = ['foo','bar','baz']
    s.leaders("leaderboard").map{ |x| x.first }.should include('foo','bar','baz')
  end
  it "can reset leaderboard" do
    s = SpaceSaver.new(Redis.new, 3)
    s.increment("leaderboard", "item")
    s.reset("leaderboard")
    s.leaders("leaderboard").size.should == 0
  end
end
