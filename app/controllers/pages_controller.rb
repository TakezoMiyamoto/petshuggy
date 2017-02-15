class PagesController < ApplicationController
  def index #views/index.html.erbを表示させるというアクション
    @users = User.all
  end

  def search
    # first commit by takezo
    if params[:search].present?
       session[:address] = params[:search]

      if params["lat"].present? & params["lng"].present?
        @latitude = params["lat"].to_f
        @longitude = params["lng"].to_f
        geolocation = [@latitude,@longitude]
      else
        # Geocoder gemのread meを参照 :searchで場所の取得はできているので、そこから緯度軽度を取り出す
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

    # リスティングデータを配列にしてまとめる
    @arrlistings = @listings.to_a

    # start_date end_dateの間に予約がないことを確認。あれば削除する
    if (!params[:start_date].blank? && !params[:end_date].blank? )

      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      @listings.each do |listing|
        # check the listing is available between start_date to end_date
        unavailable = listing.reservations.where(
            "(? <= start_date AND start_date <= ?)
            OR (? <= end_date AND end_date <= ?)
            OR (start_date < ? AND ? < end_date)",
          start_date, end_date,
          start_date, end_date,
          start_date, end_date
          ).limit(1)

        # delete unavailable room from @listings
        if unavailable.length > 0
          @arrlistings.delete(listing)
        end
      end
    end

  end
end

