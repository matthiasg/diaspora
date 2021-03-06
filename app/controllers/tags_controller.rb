#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class TagsController < ApplicationController
  skip_before_filter :count_requests
  skip_before_filter :set_invites
  skip_before_filter :which_action_and_user
  skip_before_filter :set_grammatical_gender

  def show
    if current_user
      @posts = StatusMessage.joins(:aspects).where(:pending => false
               ).where(Aspect.arel_table[:user_id].eq(current_user.id).or(StatusMessage.arel_table[:public].eq(true))
               ).select('DISTINCT `posts`.*')
    else
      @posts = StatusMessage.where(:public => true, :pending => false)
    end

    @posts = @posts.tagged_with(params[:name])
    @posts = @posts.includes(:comments, :photos).paginate(:page => params[:page], :per_page => 15, :order => 'created_at DESC')

    profiles = Profile.tagged_with(params[:name]).where(:searchable => true).select('profiles.id, profiles.person_id')
    @people = Person.where(:id => profiles.map{|p| p.person_id}).limit(15)
    @people_count = Person.where(:id => profiles.map{|p| p.person_id}).count

    @fakes = PostsFake.new(@posts)
    @commenting_disabled = true
  end
end
