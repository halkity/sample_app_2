require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do  # 新規登録が失敗（フォーム送信が）した時用のテスト
    get signup_path  # ユーザー登録ページにアクセス
    assert_no_difference 'User.count' do # User.countでユーザー数が変わっていなければ（ユーザー生成失敗していれば）true,変わっていればfalse
      post signup_path, params: { user: { name: "", email: "user@invalid", password: "foo", password_confirmation: "bar" } }  # signup_pathからusers_pathに対してpostリクエスト送信(post /usersへ)しcreateアクションを確認。User.newに送信するデータをparamsでuserハッシュとその下のハッシュで値をまとめている
      end
    assert_template "users/new" #登録失敗時にviews/users/newへ飛んでいません
    assert_select   'div#error_explanation' # divタグの中のid error_explanationをが描画されていれば成功
    assert_select   'div.field_with_errors' # divタグの中のclass field_with_errorsが描画されていれば成功
    assert_select   'form[action="/signup"]'   # formタグの中に`/signup`があれば成功
  end

  test "valid signup information" do # 新規登録が成功（フォーム送信）したかのテスト
      get signup_path # signup_path(/signup)ユーザー登録ページにアクセス
      assert_difference 'User.count', 1 do # User.countでユーザー数をカウント、1とし、ユーザー数が変わったらtrue、変わってなければfalse
        post users_path, params: { user: { name:                  "Example User", # signup_path(/signup)からusers_path(/users)へparamsハッシュのuserハッシュの値を送れるか検証
                                           email:                 "user@example.com",
                                           password:              "password",
                                           password_confirmation: "password" } }
      end
      follow_redirect! # 指定されたリダイレクト先(直後のusers/show)へ飛べるか検証
      assert_template 'users/show'  # users/showが描画されているか確認
      assert_not flash.empty? # flashが空ならfalse,空じゃなければtrue
    end

end
