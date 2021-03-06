class User < ApplicationRecord
# micropostテーブルとの関連付け、および、DB上の取り残しを防ぐためにdependent: :destroyというオプションでテーブル同士消去動作も紐付ける。
  has_many :microposts, dependent: :destroy

# フォローしている人数のためのモデル作成
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  # ActiveRelationshipモデルを探してしまうので、相互にフォローユーザーを繋ぐRelationshipモデルを見つけることができない。今回のケースではRailsに探して欲しいモデルのクラス名を明示的に伝える必要がある。

  # フォローしているユーザーを自動判別しないため、follower_idという外部キー(foreign_key:)を持って特定しなくてはならない

  # ユーザーを削除したら、ユーザーのリレーションシップも同時に削除される必要があるため,destroyも追加

# フォローされてる人数(フォロワー)のためのモデル作成
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
   # 要は、active_relationshipsをpassive_relationshipsに入れ替えて、 followed_idとfollower_idを入れ替えるだけ。

# 多対多の関連付け
  has_many :following, through: :active_relationships, source: :followed
  # has_many throughという関連付けでは、Railsはfollowedsというシンボルを見て、自動的にfollowed単数形に変え、relationshipsテーブルのfollowed_idを使って対象のユーザーを取得してくる。本来の記載は、=> has_many :followeds, through: :active_relationships

  # followedsという使い方は英語としては不適切なため、followeds => followingという名前にする。そのために、:sourceパラメーターを使って、「following配列の元はfollowed idの集合である」ということを明示的にRailsに伝える。

# 多対多の関連付け
  has_many :followers,  through: :passive_relationships,  source: :follower
  # 注意すべき箇所は:sourceキーを省略してもよかった点。
  # has_many :followers, through: :passive_relationships
  # Railsがfollowersを単数形にして自動的に外部キーfollower_idを探してくれるから。ただ、必要がないがhas_many :followingとの類似性を強調させるために書いている

  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email  # オブジェクトが保存される直前、メールアドレスをすべて小文字にする
  before_create :create_activation_digest  # オブジェクトが作成される直前、有効化トークンとダイジェストを作成および代入する
  # before_save { email.downcase! }
  # いくつかのデータベースのアダプタが、常に大文字小文字を区別するインデックスを使っているとは限らない問題への対処
  # before_createコールバックを使う目的は、トークンとそれに対応するダイジェストを割り当てるため

  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i  #正規表現でemailのフォーマットを策定し、定数に代入
  validates(:email, presence: true, length: { maximum: 255},
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: {case_sensitive: false})
            # validates(format: { with: OOOOOOOOOO }) → メールアドレスのフォーマットを検証
            # validates(uniqueness: ture) → 一意性の検証オプション
            # case_sensitive: → true:大文字小文字を区別する false:大文字小文字を区別しない

  has_secure_password
  # Userモデルにpassword_digest属性を追加し、Gemfileにbcryptを追加したことで、Userモデル内でhas_secure_passwordが使えるようになる
  #password_digestにsaveする際、passwordがハッシュ化され保存する。また、passwordと_confirmation属性に存在性と値が一致するかどうかの検証が追加される(user.authenticate("password"))

  validates :password, presence: true, length: { minimum: 6 },allow_nil: true
  # 略前→validates( :password, :presence => true, :length => {:minimum => 6})
  # Module ActiveModel::SecurePassword に72bytesを超える長さは無視すると記載があったため、72bytesに制限
  #allow_nilオプションは対象の値がnilの場合にvalidationをスキップ
  # has_secure_passwordではDBにレコード(オブジェクト)が生成された時だけ存在性(nilかどうか)のvalidationを行う性質があるので、実際にpasswordを作成する際は、nilかどうかの検証を行ってくれる

  class << self
  #テストのfixture用に、password_digestの文字列をハッシュ化して、ハッシュ値として返す
    def digest(string)
      # def self.digest(string) → def User.digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    def new_token # Userクラスにnew_tokenを渡したクラスメソッドを作成
    # self.new_token → def User.new_tokenの略
      SecureRandom.urlsafe_base64 # SecureRandomモジュールにbase64でランダムな22bytesの文字列を生成
    end
  end
    # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token  # remember_token属性にランダムなトークンを代入
    update_attribute(:remember_digest, User.digest(remember_token)) # DBのremember_digest属性にremember_tokenをBcryptでハッシュ化して更新
  end

  # 引数として受け取った値をrememberに代入して暗号化（remember_digest）し、DBにいるユーザーのremember_digestと比較、同一ならtrue・違えばfelseを返す
  # トークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)  #  def authenticated?(remember_token)
    digest = send("#{attribute}_digest")
    return false if digest.nil? # 記憶ダイジェストがnilの場合、falseを戻り値として返す
    # return false if remember_digest.nil?

    BCrypt::Password.new(digest).is_password?(token) # DBのremember_digestと、受け取った引数をremember_digestにした値を比較し、ture・felseで返す
    # module BCryptで「is_password?」メソッドを定義しており、「==」と同じ意味。参照：https://github.com/codahale/bcrypt-ruby/blob/master/lib/bcrypt/password.rb
    # BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end


  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)  # DBにあるremember_digestをnilにする
  end

  # アカウントを有効にする
  def activate
    update_columns(activated: true, activated_at: Time.zone.now.to_s(:db))
    # update_attribute(:activated,    true)
    # update_attribute(:activated_at, Time.zone.now.to_s(:db))
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token), reset_sent_at: Time.zone.now.to_s(:db))
    # update_attribute(:reset_digest,  User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago  # 2時間以上パスワードが再設定されなかった場合は期限切れとする処理
  end

  # 試作feedの定義
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  # ユーザーのステータスフィードを返す
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)

  end

  # ユーザーをフォローする
  def follow(other_user)
    following << other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = email.downcase
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
