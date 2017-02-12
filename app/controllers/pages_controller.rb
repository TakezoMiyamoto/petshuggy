class PagesController < ApplicationController
  def index
    @users = User.all
  end

  def search
    if params[:search].present?
      @latitude = params["lat"]
      @longitude = params["lng"]

      #検索結果が空の場合
    else
      @listings = Listing.where(active: true).all
      @latitude = @listings.to_a[0].latitude
      @longitude = @listings.to_a[0].longitude
    end
  end

end
