class CreateComment < Jennifer::Migration::Base
  def up
    create_table(:comments) do |t|
      t.text :text, {:null => false}
      t.reference :post, options: {:on_delete => :cascade}
      t.reference :user, options: {:on_delete => :cascade}

      t.timestamps
    end
  end

  def down
    drop_table(:comments)
  end
end
