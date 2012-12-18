class SpaceSaver
  def initialize(redis, k)
    @redis = redis
    @k = k
  end
  
  def increment(leaderboard, value)
    score = @redis.zscore(leaderboard, value)
    if score || @redis.zcard(leaderboard) < @k
      @redis.zincrby(leaderboard, 1, value)
    else
      item, score = @redis.zrange(leaderboard, 0, 0, withscores: true).first
      new_score = score.to_i + 1
      @redis.zadd(leaderboard, new_score, value) if @redis.zrem(leaderboard, item)
      new_score
    end
  end

  def leaders(leaderboard, k=@k)
    @redis.zrevrange(leaderboard, 0, k-1, withscores: true)
  end
end
