class CreateMicroposts < ActiveRecord::Migration[5.1]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :microposts, [:user_id, :created_at]
    # user_idとcreated_atカラムにインデックスが付与されていることで、user_idに関連付けられたすべてのマイクロポストを作成時刻の逆順で取り出しやすくなります。
  end
end
