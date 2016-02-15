class Match
  def initialize(user1, user2)
    map = [
      [1,0,0,0,9,0,0,0],
      [0,0,0,9,0,0,0,0],
      [0,0,0,0,0,0,0,0],
      [0,0,9,9,9,9,0,0],
      [0,0,0,0,0,0,0,0],
      [0,0,0,9,9,0,0,0],
      [0,0,0,0,0,0,0,0],
      [0,9,0,0,0,0,0,1]
    ]
    @users = [user1, user2]
  end

  def tick
    @users.each(&:perform) if active?
  end
end
