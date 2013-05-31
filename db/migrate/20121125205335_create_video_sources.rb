class CreateVideoSources < ActiveRecord::Migration
  def change
    # video source digest
    create_table :video_sources do |t|
      t.string :filename  ,:null=>false,:limit=>50
      t.string :gsv_number, :null => false, :limit => 32
      t.string :path, :null => false, :limit => 80
      t.string :video_format, :limit => 5
      t.string :frame_size, :limit => 10
      t.string :duration, :limit => 10
      t.string :vcodec, :limit => 15
      t.string :acodec, :limit => 15
      t.integer :data_size

      t.timestamps
    end
  end
end
