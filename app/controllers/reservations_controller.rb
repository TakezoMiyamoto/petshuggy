class ReservationsController < ApplicationController


  def create
    @listing = Listing.find(params[:listing_id])

    # 自分で自分の部屋を予約する場合(つまり預かれへん日を設定したい場合)
    if current_user = @listing.user
      # 選択された日付を","で区切って配列かする
      selectedDates = params[:reservation][:selectedDates].split(",")
      # 自分で予約した予約を取り出して変数に打ち込む
      reservationsByme = @listing.reservations.where(user_id: current_user.id)

      # 以前に自分で予約した日付の配列
      oldSelectedDates = []

      reservationsByme.each do |reservation|
        oldSelectedDates.push(reservation.start_date)
      end

      # 以前に自分で予約した予約を全て一旦消す！
      if oldSelectedDates
        oldSelectedDates.each do |date|
          @reservation = current_user.reservations.where(start_date:date, end_date:date)
          @reservation.destroy_all
        end
      end

      selectedDates
      if selectedDates
        selectedDates.each do |date|
          current_user.reservations.create(:listing_id => @listing.id, :start_date => date, :end_date => date)
        end
      end

      redirect_to :back, notice: "更新しました"
    else
      # 他人のやつに予約したい時。予約をパラメータ付与して作成
      @reservations = current_user.reservations.create(reservation_params)
      redirect_to @reservation.listing, notice: "予約が完了しました。"
    end

  end

  def setdate
    # ajaxで送られてきたlisting_idを元にそのリスティングの予約をjsonで返す
    listing = Listing.find(params[:listing_id])
    today = Date.today
    reservations = listing.reservations.where("start_date >= ? OR end_date >= ?",today,today)

    render json: reservations
  end

  def duplicate
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    result = {
        duplicate: is_duplicate(start_date, end_date)
    }

    render json: result
  end

  private
    def reservation_params
      params.require(:reservation).permit(:start_date, :end_date, :price_pernight, :total_price, :listing_id)
    end

    def is_duplicate(start_date, end_date)
      listing = Listing.find(params[:listing_id])

      check = listing.reservations.where("? < start_date AND end_date < ?",start_date,end_date)
      check.size > 0? true : false 
    end

end
