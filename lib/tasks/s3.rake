# frozen_string_literal: true

task :s3_import do
  storage_folder = Rails.root.join("storage")
  storage_folder.mkpath

  # Ignores sub_folders already created and .keep files
  images = storage_folder.children.select { |file| file.file? && !file.empty? }

  # Formats the file path of each image so ActiveStorage understands them using :local storage
  images.each do |path_name|
    dir, basename = path_name.split
    file_name = basename.to_s
    sub_folders = dir.join(file_name[0..1], file_name[2..3])
    sub_folders.mkpath # Create the subfolder used by active_record
    path_name.rename(dir + sub_folders + basename) # Renames file to be moved into subfolder
  end
end
