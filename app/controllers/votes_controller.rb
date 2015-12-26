class VotesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:vote]

  def vote
    begin
      uid = params[:uid]
      vote = params[:vote]

      user = User.find_by_sql(["
                               SELECT *
                               FROM users u
                               WHERE u.uid = ?
                               LIMIT 1",
                              uid
                              ])[0]

      if (user.vote != vote)
        new_vote = Vote.new
        new_vote.vote = vote
        new_vote.user_id= user.id

        user.vote = vote

        if !new_vote.save or !user.save
          render :json => {"status" => "error"}
          return
        end
      end

      render :json => {"status" => "success"}
      return
    rescue
      render :json => {"status" => "error"}
      return
    end
  end

  def get_standings
    begin
      uid = params[:uid]
      query = User.find_by_sql([
                                "SELECT *
                                 FROM users
                                 WHERE uid = ?",
                                uid
                               ])
      user = nil
      my_vote = ""

      if query.count > 0
        user = query[0]
        my_vote = user.vote
      else
        user = User.new
        user.uid = uid
      end

      my_vote ||= ""
      user.last_seen = Time.now

      if !user.save
        render :json => {"status" => "error"}
        return
      end

      standings = User.find_by_sql("
                                    SELECT
                                        vote,
                                        COUNT(*) AS vote_count
                                    FROM users
                                    GROUP BY vote"
                                   )

      votes = {}
      standings.each do |s|
        votes[s.vote] = s.vote_count
      end
      
      
      render :json => {"status" => "success", "standings" => votes, "my_vote" => my_vote}
      return
    rescue
      render :json => {"status" => "error"}
      return
    end
  end
end
