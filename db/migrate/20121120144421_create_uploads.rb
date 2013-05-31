class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      # video parameters digest
      t.string :filename  ,:null=>false,:limit=>50
      t.string :gsv_number, :null => false, :limit => 40
      t.string :path, :null => false, :limit => 80
      t.string :video_format, :limit => 5
      t.string :frame_size, :limit => 10
      t.string :duration, :limit => 10
      t.string :vcodec, :limit => 15
      t.string :acodec, :limit => 15
      t.integer :data_size

      t.references :user, :index => true, :null => true

      t.timestamps
    end

    execute <<-SQL
    ALTER TABLE uploads
      ADD CONSTRAINT fk_upload_user FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE SET NULL ON UPDATE CASCADE;
    SQL
  end
end
