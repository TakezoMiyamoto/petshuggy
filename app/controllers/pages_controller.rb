class PagesController < ApplicationController
  def index #views/index.html.erbを表示させるというアクション
    @users = User.all
  end

  def search
    if params[:search].present?
       session[:address] = params[:search]
 
      if params["lat"].present? & params["lng"].present?
        @latitude = params["lat"].to_f
        @longitude = params["lng"].to_f
        geolocation = [@latitude,@longitude]
      else
        geolocation = Geocoder.coordinates(params[:search])
        @latitude = geolocation[0]
        @longitude = geolocation[1]
      end
    @listings = Listing.where(active: true).near(geolocation, 1, :order => 'distance')

  # @locations = Location.near([current_user.latitude, current_user.longitude], 50, :order => :distance)

    # 検索欄が空欄の場合
    else

      @listings = Listing.where(active: true).all
      @latitude = @listings.to_a[0].latitude
      @longitude = @listings.to_a[0].longitude  

    end
  end
end

