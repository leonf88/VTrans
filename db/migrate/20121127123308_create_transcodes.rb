class CreateTranscodes < ActiveRecord::Migration
  def change
    create_table :transcodes do |t|
      # video parameters digest
      t.string :filename, :null => true, :limit => 50
      t.string :gsv_number, :null => false, :limit => 32
      t.string :path, :null => true, :limit => 80
      t.string :video_format, :limit => 5
      t.string :frame_size, :limit => 10
      t.string :duration, :limit => 10
      t.string :vcodec, :limit => 15
      t.string :acodec, :limit => 15
      t.integer :data_size, :null => true

      t.string :aspect, :limit => 15
      t.decimal :frame_rate, :scale => 2, :default => 0.0
      t.integer :video_bitrate, :default => 0
      t.integer :audio_sample_rate, :default => 0
      t.integer :audio_channel, :default => 0
      t.integer :audio_bitrate, :default => 0

      t.datetime :complete_time, :null => true
      t.integer :cost_time, :null => true
      t.string :status, :null => false, :limit => 10
      t.string :pbs_job_id, :null => true, :limit => 50

      t.references :user, :index => true, :null => true
      t.references :video_source, :index => true, :null => true

      t.timestamps
    end

    execute <<-SQL
    ALTER TABLE transcodes
      ADD CONSTRAINT fk_transcode_user FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE SET NULL ON UPDATE CASCADE;
    SQL
  end
end
