class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authorize,:find_user
  protect_from_forgery with: :exception
  before_action :now,:counter, if: :whitelist
  before_action :set_i18n_locale_from_params

  def now
    @t = Time.now
  end

  def counter
    if session[:counter].nil?
      session[:counter] = 1
    else
      session[:counter] += 1
    end
    @counter = session[:counter]
  end

  private

  def find_user
    @user = User.find_by(id: session[:user_id])
  end

  def authorize
    unless find_user
      redirect_to login_url, notice: "ログインしてください"
    end
  end

    def whitelist
      %w{store products}.include?(controller_name)
    end

    def current_cart
      Cart.find(session[:cart_id])
    rescue ActiveRecord::RecordNotFound
      cart = Cart.create
      session[:cart_id] = cart.id
      cart
    end

    def set_i18n_locale_from_params
      if params[:locale]
        if I18n.available_locales.include?(params[:locale].to_sym)
          I18n.locale = params[:locale]
        else
          flash.now[:notice] =
          "#{params[:locale]} translation not available"
          logger.error flash.now[:notice]
        end
      end
    end

    def default_url_options
      { locale: I18n.locale}
    end

end
