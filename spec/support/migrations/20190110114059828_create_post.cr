class CreatePost < Jennifer::Migration::Base
  def up
    create_table(:posts) do |t|
      t.string :title, { :null => false }
      t.text :text, { :null => false }
      t.reference :user, options: { :on_delete => :cascade }
      t.float :rating, { :default => 0.0f32 }

      t.timestamps
    end
  end

  def down
    drop_table(:posts)
  end
end
