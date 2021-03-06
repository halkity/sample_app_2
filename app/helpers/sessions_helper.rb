module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id #ユーザーidをsessionのuser_idに代入（ログインidの保持）。sessionメソッドで作成した一時cookiesは自動的に暗号化され、コードは保護される。
  end

  # ユーザーのセッションを永続的にする
  def remember(user)  # rememberメソッドにuser(ログイン時にユーザーが送ったメールとパスと同一の、DBにいるユーザー)を引数として渡す
    user.remember  # model/User.classのrememberメソッドを使い、DBのremember_digest属性にランダムで生成されたremember_tokenをBcryptでハッシュ化して更新
    cookies.permanent.signed[:user_id] = user.id  # ログイン時のユーザーidを、有効期限(20年)と署名付きの暗号化したユーザーidとしてcookiesに保存
    cookies.permanent[:remember_token] = user.remember_token  # ログイン時のremember_tokenを、有効期限（20年）を設定して新たなremember_tokenに保存。Userモデルにて、ログインユーザーと同一ならtrueを返す
  end

  # remember_token_cookieに対応するユーザーを返す
  def current_user
    if (user_id = session[:user_id]) # user_idにsession[:user_id]を代入した結果、user_idが存在すればtrue
      @current_user ||= User.find_by(id: user_id)   # @current_user(現在のログインユーザー)が存在すればそのまま、なければuser_id(session[:user_id])と同じidを持つユーザーをDBから探して@current_userに代入
    elsif (user_id = cookies.signed[:user_id]) # user_idに署名付きcookieを代入した結果、user_idに著名付きcookiesが存在すればtrue
      # raise  # テストがパスすれば、この部分がテストされていないことがわかる
      user = User.find_by(id: user_id) # user_id(著名な付きcookie)と同じユーザーidをもつユーザーをDBから探し、userに代入
      if user && user.authenticated?(:remember, cookies[:remember_token]) # DBのユーザーがいるかつ、引数として受け取った値をrememberに代入して暗号化（remember_digest）し、DBにいるユーザーのremember_digestと比較、同一ならtrue・違えばfelseを返す
        log_in(user) # session[:user_id]にuserのIDを代入
        @current_user = user  # @current_userにuser(User.find_by(id: user_id))を代入
      end
    end
  end

  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?  # current_user(ログインユーザー)がnil以外ならtrue、nilなzらfalseを返す。「!」は否定演算子。
  end

  #永続的セッションを破棄する
  def forget(user)
    user.forget # 引数に対してforgetメソッドを呼び出し、DBにあるremember_digestをnilにする
    cookies.delete(:user_id)  # cookiesのuser_idを削除
    cookies.delete(:remember_token) # cookiesのremeber_tokenを削除
  end

  # ユーザーをログアウトする
  def log_out
    forget(current_user)  # forgetメソッドを呼び出し、引数@current_userのDBにあるremember_digestをnilにして、cookies[:user_id]とcookies[:remeber_token]を消去する
    session.delete(:user_id) # session[:user_id]を削除する
    @current_user = nil # @current_userをnilする
  end

# /フレンドリーフォワーディングの実装/

  # 記憶したURL (もしくはデフォルト値) にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
    # 転送先のURLを保存する仕組みは、ユーザーをログインさせたときと同じで、session変数をを使う
    # request.original_urlでリクエスト先が取得できる
    # リクエストが送られたURLをsession変数の:forwarding_urlキーに格納、ただし、GETリクエストが送られたときだけ格納する。こうすることで、例えばログインしていないユーザーがフォームを使って送信した場合、転送先のURLを保存させないようにする→if request.get?という条件文を使って対応

  end

end
